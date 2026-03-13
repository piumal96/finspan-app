import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/finspan_theme.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _carouselData = [
    {
      'title': 'Your Financial Future.',
      'subtitle': 'Track your wealth with clarity.',
      'image': 'assets/images/carousel_1_nobg.png',
    },
    {
      'title': 'Intelligent Tracking',
      'subtitle': 'Monitor your assets in one place.',
      'image': 'assets/images/carousel_2_nobg.png',
    },
    {
      'title': 'Plan for Retirement',
      'subtitle': 'Achieve your golden years goals.',
      'image': 'assets/images/carousel_3_nobg.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () {
        // TODO: Open Terms of Service URL
      };
    _privacyTap = TapGestureRecognizer()
      ..onTap = () {
        // TODO: Open Privacy Policy URL
      };
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.white, // Pure white background for minimalist style
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, // Reduced from 28
                    vertical:
                        24.0, // Reduced from 40 to fit better on small screens
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ── Top: Logo Only ───────────────────
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          // Professional Text Logo & Tagline
                          Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                          fontSize: 34,
                                        ),
                                  ),
                                  children: [
                                    const TextSpan(
                                      text: 'Fin',
                                      style: TextStyle(
                                        color: FinSpanTheme.charcoal,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Span',
                                      style: TextStyle(
                                        color: FinSpanTheme.primaryGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Smart. Simple. Secure.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: FinSpanTheme.bodyGray.withOpacity(0.7),
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Centre: Carousel ───────────────────────
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 380, // Fixed height for carousel
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemCount: _carouselData.length,
                              itemBuilder: (context, index) {
                                final data = _carouselData[index];
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      data['image']!,
                                      height: 250,
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ), // Tighter spacing
                                    Text(
                                      data['title']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: FinSpanTheme.charcoal,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Text(
                                        data['subtitle']!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14, // Refined font size
                                          color: FinSpanTheme.bodyGray,
                                          fontWeight: FontWeight.w400,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ── Dot Indicators ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _carouselData.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                height: 6, // Made slightly slimmer
                                width: _currentPage == index ? 20 : 6,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? FinSpanTheme.primaryGreen
                                      : FinSpanTheme.primaryGreen.withValues(
                                          alpha: 0.2,
                                        ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── Bottom: Buttons + Legal ───────────────────
                      Column(
                        children: [
                          // Get Started (Primary Action)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SignUpScreen(returnToLogin: false),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: FinSpanTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14, // Trimmed down for UX
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ), // Smoother border radius
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      15, // Adjusted to match vertical scaling
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Already have account (Secondary Action - changed to TextButton to reduce UI noise)
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: FinSpanTheme
                                    .charcoal, // Make it subtle, not green
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'I already have an account',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Legal text with links
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 12,
                                color: FinSpanTheme.bodyGray,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _termsTap,
                                ),
                                const TextSpan(text: '  •  '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: const TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _privacyTap,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 4,
                          ), // Prevents cutoff on small devices
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
