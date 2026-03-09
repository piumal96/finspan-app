import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/finspan_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/response_utils.dart';
import 'login_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

const String _kGoogleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.08 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-3.58-13.46-8.71l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>
''';

class SignUpScreen extends StatefulWidget {
  /// Set to true when pushed from [LoginScreen] so that the "Sign In" footer
  /// link pops back to Login instead of pushing a new LoginScreen instance.
  final bool returnToLogin;

  const SignUpScreen({super.key, this.returnToLogin = false});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  // ─── Sign-Up ──────────────────────────────────────────────────────────────

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      setState(() => _showTermsError = true);
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_authService.isAvailable) {
      ResponseUtils.showPremiumSnackBar(
        context,
        'Firebase is not configured.',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (context.mounted) {
        ResponseUtils.showPremiumSnackBar(
          context,
          'Account created! Welcome to FinSPAN.',
          isSuccess: true,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ResponseUtils.showPremiumSnackBar(
          context,
          AuthService.getFriendlyAuthError(e),
          isError: true,
        );
      }
    } catch (_) {
      if (context.mounted) {
        ResponseUtils.showPremiumSnackBar(
          context,
          'Something went wrong. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Google Sign-Up ───────────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    if (!_authService.isAvailable) {
      ResponseUtils.showPremiumSnackBar(
        context,
        'Firebase is not configured.',
        isError: true,
      );
      return;
    }

    setState(() => _isGoogleLoading = true);
    try {
      await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ResponseUtils.showPremiumSnackBar(
          context,
          AuthService.getFriendlyAuthError(e),
          isError: true,
        );
      }
    } catch (e) {
      if (context.mounted) {
        final msg = e.toString();
        if (!msg.contains('canceled') && !msg.contains('cancelled')) {
          ResponseUtils.showPremiumSnackBar(
            context,
            'Google Sign-In failed. Please try again.',
            isError: true,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool anyLoading = _isLoading || _isGoogleLoading;
    final double screenH = MediaQuery.of(context).size.height;

    // Adaptive spacing: tight on small screens (< 700px), normal otherwise
    final bool compact = screenH < 700;
    final double gap = compact ? 12.0 : 16.0;
    final double sectionGap = compact ? 16.0 : 24.0;
    final double fieldHeight = compact ? 48.0 : 52.0;
    final double logoSize = compact ? 22.0 : 26.0;
    final double titleSize = compact ? 18.0 : 22.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button
            SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, size: 20),
                  color: FinSpanTheme.charcoal,
                  onPressed: anyLoading ? null : () => Navigator.maybePop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: compact ? 4.0 : 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo
                        Hero(
                          tag: 'finspan_logo',
                          child: Material(
                            color: Colors.transparent,
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text: 'Fin',
                                  style: TextStyle(
                                    fontSize: logoSize,
                                    fontWeight: FontWeight.w900,
                                    color: FinSpanTheme.charcoal,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                TextSpan(
                                  text: 'SPAN',
                                  style: TextStyle(
                                    fontSize: logoSize,
                                    fontWeight: FontWeight.w900,
                                    color: FinSpanTheme.primaryGreen,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                        SizedBox(height: compact ? 12 : 16),

                        // Title
                        Text(
                          'Create new account',
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF004D40),
                            letterSpacing: -0.4,
                          ),
                        ),
                        SizedBox(height: sectionGap),

                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email
                              _label('Email Address'),
                              SizedBox(height: 6),
                              _field(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                hint: 'Enter your email',
                                keyboardType: TextInputType.emailAddress,
                                action: TextInputAction.next,
                                height: fieldHeight,
                                enabled: !anyLoading,
                                onSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_passwordFocus),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                  ).hasMatch(v.trim())) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: gap),

                              // Password
                              _label('Password'),
                              SizedBox(height: 6),
                              _field(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                hint: 'Min 8 characters',
                                obscure: _obscurePassword,
                                action: TextInputAction.next,
                                height: fieldHeight,
                                enabled: !anyLoading,
                                onSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_confirmPasswordFocus),
                                onToggleObscure: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 8) {
                                    return 'At least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: gap),

                              // Confirm Password
                              _label('Confirm Password'),
                              SizedBox(height: 6),
                              _field(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocus,
                                hint: 'Re-enter password',
                                obscure: _obscureConfirmPassword,
                                action: TextInputAction.done,
                                height: fieldHeight,
                                enabled: !anyLoading,
                                onSubmitted: (_) =>
                                    FocusScope.of(context).unfocus(),
                                onToggleObscure: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (v != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: gap),

                              // Terms checkbox
                              _buildTermsCheckbox(),
                              if (_showTermsError)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, left: 4),
                                  child: Text(
                                    'You must agree to the terms',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              SizedBox(height: sectionGap),

                              // Sign Up button
                              SizedBox(
                                width: double.infinity,
                                height: compact ? 50 : 54,
                                child: ElevatedButton(
                                  onPressed:
                                      anyLoading ? null : _handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        FinSpanTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<
                                                    Color>(Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(height: sectionGap),

                              // Social divider
                              const Center(
                                child: Text(
                                  'or sign up with',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                              SizedBox(height: compact ? 12 : 16),

                              // Social buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildGoogleCircle(anyLoading),
                                  const SizedBox(width: 20),
                                  _buildFacebookComingSoon(),
                                ],
                              ),
                              SizedBox(height: sectionGap),

                              // Footer
                              Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Already have an account?  ',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13),
                                    ),
                                    GestureDetector(
                                      onTap: anyLoading
                                          ? null
                                          : () {
                                              if (widget.returnToLogin) {
                                                // Came from LoginScreen — just pop back to it.
                                                Navigator.maybePop(context);
                                              } else {
                                                // Came from LandingScreen — replace this
                                                // screen with LoginScreen so the stack
                                                // becomes [Landing → Login] not [Landing → Login → Login].
                                                Navigator.pushReplacement(
                                                  context,
                                                  _fadeSlideRoute(
                                                      const LoginScreen()),
                                                );
                                              }
                                            },
                                      child: const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          color: Color(0xFF004D40),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: compact ? 12 : 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Widget helpers ───────────────────────────────────────────────────────

  Route<T> _fadeSlideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: FinSpanTheme.charcoal,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required bool enabled,
    required double height,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    ValueChanged<String>? onSubmitted,
    FormFieldValidator<String>? validator,
  }) {
    return SizedBox(
      height: height + 24, // account for error text
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscure,
        textInputAction: action,
        enabled: enabled,
        onFieldSubmitted: onSubmitted,
        validator: validator,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: (height - 14) / 2,
          ),
          suffixIcon: onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: onToggleObscure,
                  visualDensity: VisualDensity.compact,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFF004D40), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.shade400),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          errorStyle: const TextStyle(fontSize: 11, height: 1.2),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() {
        _agreedToTerms = !_agreedToTerms;
        if (_agreedToTerms) _showTermsError = false;
      }),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: _agreedToTerms,
              onChanged: (v) => setState(() {
                _agreedToTerms = v ?? false;
                if (_agreedToTerms) _showTermsError = false;
              }),
              activeColor: FinSpanTheme.primaryGreen,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                children: [
                  const TextSpan(text: "I agree to the "),
                  TextSpan(
                    text: 'User Agreement',
                    style: const TextStyle(
                      color: Color(0xFF004D40),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' & '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: Color(0xFF004D40),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleCircle(bool disabled) {
    return SizedBox(
      width: 52,
      height: 52,
      child: _isGoogleLoading
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF004D40)),
                  ),
                ),
              ),
            )
          : IconButton.outlined(
              onPressed: disabled ? null : _handleGoogleSignIn,
              style: IconButton.styleFrom(
                shape: const CircleBorder(),
                side: BorderSide(color: Colors.grey.shade200),
                backgroundColor: Colors.white,
              ),
              icon: SvgPicture.string(_kGoogleSvg, width: 20, height: 20),
            ),
    );
  }

  Widget _buildFacebookComingSoon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: IconButton.outlined(
            onPressed: null,
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
              side: BorderSide(color: Colors.grey.shade200),
              backgroundColor: Colors.grey.shade50,
            ),
            icon: Icon(
              LucideIcons.facebook,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        Positioned(
          top: -4,
          right: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Soon',
              style: TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
