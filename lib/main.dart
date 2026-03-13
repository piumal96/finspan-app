import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/dashboard/main_dashboard.dart';
import 'screens/landing_screen.dart';
import 'screens/onboarding/onboarding_wrapper.dart';
import 'screens/splash_screen.dart';
import 'services/local_storage_service.dart';
import 'services/user_service.dart';
import 'screens/onboarding/onboarding_data.dart';
import 'theme/finspan_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Suppress a debug-only Syncfusion charts internal bug.
  // When AuthGate transitions from MainDashboard → LandingScreen on sign-out,
  // Syncfusion's CustomLayoutBuilderElement.unmount() calls markNeedsLayout()
  // on a RenderChartFadeTransition that is already disposed.  Flutter's assert
  // catches this in debug mode and surfaces it as a red-screen error, even
  // though the app recovers correctly.  The assert is stripped in release builds
  // so this never affects users.  We suppress only this specific error so the
  // console stays clean while debugging other issues.
  FlutterError.onError = (FlutterErrorDetails details) {
    final description = details.exceptionAsString();
    final stack = details.stack?.toString() ?? '';
    if (description.contains('disposed RenderObject') &&
        stack.contains('RenderChartFadeTransition')) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ [Syncfusion] Chart dispose warning (suppressed in debug): '
          '${details.exception}',
        );
      }
      return;
    }
    FlutterError.presentError(details);
  };

  // Initialise Hive local cache before anything else so it's available
  // synchronously throughout the app.
  await LocalStorageService.init();

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
/// - Signed in              → _OnboardingGate (checks local cache then Firestore)
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const LandingScreen();
        }
        return const _OnboardingGate();
      },
    );
  }
}

/// Loads the user's financial plan with a Hive-first, Firebase-second strategy:
///
///   1. Immediately check the local Hive cache (zero network, zero latency).
///      If data exists → show MainDashboardScreen right away.
///   2. In the background, fetch from Firebase:
///      a. If no local cache existed → update state with Firebase data.
///      b. Always update the Hive cache with the fresh Firebase copy so the
///         next launch is instant too.
///
/// This means returning users **never** see a loading spinner; they see their
/// dashboard immediately while Firebase silently stays in sync.
class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate();

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  OnboardingData? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // ── Step 1: Hive (instant, no network) ───────────────────────────────
    final cached = LocalStorageService.loadProfile(uid);
    if (cached != null && mounted) {
      setState(() {
        _profile = cached;
        _loading = false;
      });
    }

    // ── Step 2: Firebase (background, keeps Hive up-to-date) ─────────────
    try {
      final remote = await UserService().getUserProfile();
      if (!mounted) return;

      if (remote != null) {
        // Always refresh the local cache with the authoritative Firebase copy.
        await LocalStorageService.saveProfile(uid, remote);

        // Only push a UI update if we had no local cache (first use on device).
        if (cached == null) {
          setState(() {
            _profile = remote;
            _loading = false;
          });
        }
      } else if (cached == null) {
        // No local cache and no Firebase data → first-time user, show onboarding.
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Firebase profile fetch failed: $e');
      // If Firebase fails but we have a local copy, we already showed it → fine.
      if (cached == null && mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SplashScreen();
    if (_profile != null) return MainDashboardScreen(data: _profile!);
    return const OnboardingWrapper();
  }
}
