import 'package:flutter/material.dart';
import 'theme/finspan_theme.dart';
import 'screens/splash_screen.dart';

void main() {
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
