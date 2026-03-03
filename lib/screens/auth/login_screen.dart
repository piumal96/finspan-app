import 'package:flutter/material.dart';
import '../../theme/finspan_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/finspan_card.dart';
import '../onboarding/onboarding_wrapper.dart';
import '../dashboard/main_dashboard.dart';
import '../../services/user_service.dart';
import '../../utils/response_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (!_authService.isAvailable) {
      ResponseUtils.showPremiumSnackBar(
        context,
        'Firebase is not configured. Please add the required config files.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential != null) {
        if (mounted) {
          setState(() => _isLoading = true); // Keep loading while checking data

          final UserService userService = UserService();
          final hasData = await userService.hasCompletedOnboarding();
          final userData = hasData ? await userService.getUserProfile() : null;

          if (mounted) {
            ResponseUtils.showPremiumSnackBar(
              context,
              'Welcome back, ${userCredential.user?.displayName ?? "User"}!',
              isSuccess: true,
            );

            if (hasData && userData != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainDashboardScreen(data: userData),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnboardingWrapper(),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ResponseUtils.showPremiumSnackBar(
          context,
          'Authentication failed: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    FinSpanTheme.primaryGreen.withValues(alpha: 0.05),
                    FinSpanTheme.backgroundLight,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const BackButton(color: FinSpanTheme.charcoal),
                  pinned: true,
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Hero(
                          tag: 'login_title',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              'Welcome Back',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: FinSpanTheme.charcoal,
                                    letterSpacing: -1,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Securely sync your financial roadmap across all your devices.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: FinSpanTheme.bodyGray,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 40),
                        FinSpanCard(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              _buildGoogleButton(),
                              const SizedBox(height: 28),
                              _buildDivider(),
                              const SizedBox(height: 28),
                              _buildEmailFields(),
                              const SizedBox(height: 32),
                              _buildSignInButton(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildFooter(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: FinSpanTheme.primaryGreen.withValues(alpha: 0.3),
            width: 1.5,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      FinSpanTheme.primaryGreen,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.login, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: FinSpanTheme.charcoal,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(
          child: Divider(thickness: 1, color: FinSpanTheme.dividerColor),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'OR',
            style: TextStyle(
              color: FinSpanTheme.bodyGray,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
          child: Divider(thickness: 1, color: FinSpanTheme.dividerColor),
        ),
      ],
    );
  }

  Widget _buildEmailFields() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'name@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          ResponseUtils.showPremiumSnackBar(
            context,
            'Email authentication will be enabled after backend migration.',
          );
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text('Sign In Securely'),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(color: FinSpanTheme.bodyGray),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingWrapper(),
                    ),
                  );
                },
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    color: FinSpanTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Protected by 256-bit encryption',
            style: TextStyle(
              color: FinSpanTheme.bodyGray,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
