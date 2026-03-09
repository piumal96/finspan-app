import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/dashboard/main_dashboard.dart';
import 'screens/landing_screen.dart';
import 'screens/onboarding/onboarding_wrapper.dart';
import 'screens/splash_screen.dart';
import 'services/user_service.dart';
import 'screens/onboarding/onboarding_data.dart';
import 'theme/finspan_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) print('Firebase initialization failed: $e');
  }

  runApp(const FinSpanApp());
}

class FinSpanApp extends StatelessWidget {
  const FinSpanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinSpan',
      debugShowCheckedModeBanner: false,
      theme: FinSpanTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

/// Root widget that reacts to Firebase auth state.
/// - Waiting for Firebase   → SplashScreen
/// - Not signed in          → LandingScreen
/// - Signed in              → _OnboardingGate (checks Firestore for profile)
///
/// This is the recommended Flutter + Firebase pattern. Login, signup, and
/// logout all just call the auth API — this widget handles all navigation
/// automatically so there is never a "deactivated ancestor" crash.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Firebase SDK still initialising
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // Not signed in
        if (!snapshot.hasData || snapshot.data == null) {
          return const LandingScreen();
        }

        // Signed in — resolve onboarding / dashboard
        return const _OnboardingGate();
      },
    );
  }
}

/// Fetches the user's Firestore profile once and routes to the correct screen.
/// Uses `late final Future` so the Firestore call is made only once per
/// login session, not on every stream event.
class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate();

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  late final Future<OnboardingData?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = UserService().getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<OnboardingData?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData && snapshot.data != null) {
          return MainDashboardScreen(data: snapshot.data!);
        }
        return const OnboardingWrapper();
      },
    );
  }
}
