import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'theme/finspan_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization failed: $e');
    }
    // Continue — the app still runs but Firebase features will be unavailable.
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
      home: const SplashScreen(),
    );
  }
}
