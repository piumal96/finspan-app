import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/finspan_theme.dart';
import '../../widgets/finspan_card.dart';
import '../onboarding/onboarding_data.dart';

class ProfileScreen extends StatelessWidget {
  final OnboardingData? data;

  const ProfileScreen({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: FinSpanTheme.charcoal,
                ),
              ),
              const SizedBox(height: 32),

              // User Info Card
              FinSpanCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: FinSpanTheme.primaryGreen.withOpacity(
                        0.1,
                      ),
                      backgroundImage: user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                      child: user?.photoURL == null
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: FinSpanTheme.primaryGreen,
                            )
                          : null,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Valuable User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: FinSpanTheme.charcoal,
                            ),
                          ),
                          Text(
                            user?.email ?? 'No email associated',
                            style: const TextStyle(
                              fontSize: 14,
                              color: FinSpanTheme.bodyGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Simulation Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: FinSpanTheme.charcoal,
                ),
              ),
              const SizedBox(height: 16),

              _buildPreferenceItem(
                icon: Icons.calendar_month_rounded,
                title: 'Current Age',
                value: '${data?.currentAge ?? "Not set"} years',
              ),
              _buildPreferenceItem(
                icon: Icons.beach_access_rounded,
                title: 'Retirement Age',
                value: 'Age ${data?.retirementAge ?? 65}',
              ),
              _buildPreferenceItem(
                icon: Icons.favorite_rounded,
                title: 'Life Expectancy',
                value: 'Age ${data?.lifeExpectancy ?? 90}',
              ),

              const SizedBox(height: 32),

              const Text(
                'Security & Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: FinSpanTheme.charcoal,
                ),
              ),
              const SizedBox(height: 16),

              _buildActionItem(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                onTap: () {},
              ),
              _buildActionItem(
                icon: Icons.security_rounded,
                title: 'Data & Privacy',
                onTap: () {},
              ),
              _buildActionItem(
                icon: Icons.logout_rounded,
                title: 'Log Out',
                color: Colors.redAccent,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FinSpanCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FinSpanTheme.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: FinSpanTheme.primaryGreen),
            ),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(color: FinSpanTheme.bodyGray)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: FinSpanTheme.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: FinSpanCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 24, color: color ?? FinSpanTheme.charcoal),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: color ?? FinSpanTheme.charcoal,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color:
                    color?.withValues(alpha: 0.5) ??
                    Colors.grey.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
