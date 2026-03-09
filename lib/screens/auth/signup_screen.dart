import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/finspan_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/response_utils.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Official Google "G" SVG
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
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  // ─── Email / Password Sign-Up ─────────────────────────────────────────────

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
        displayName: _nameController.text.trim(),
      );

      if (context.mounted) {
        ResponseUtils.showPremiumSnackBar(
          context,
          'Account created! Welcome to FinSPAN.',
          isSuccess: true,
        );
        // AuthGate's StreamBuilder detects the new user and navigates automatically.
      }
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
      // AuthGate's StreamBuilder navigates automatically on success.
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Back button row
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, size: 22),
                  color: FinSpanTheme.charcoal,
                  onPressed: anyLoading ? null : () => Navigator.maybePop(context),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 24.0,
                      right: 24.0,
                      bottom: 40.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // Logo
                        Hero(
                          tag: 'finspan_logo',
                          child: Material(
                            color: Colors.transparent,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'Fin',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: FinSpanTheme.charcoal,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'SPAN',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: FinSpanTheme.primaryGreen,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Title
                        const Text(
                          'Create new account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF004D40),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 28),

                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username
                              _fieldLabel('Username'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                enabled: !anyLoading,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).requestFocus(_emailFocus),
                                decoration:
                                    _inputDecoration('Enter your username'),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Username is required'
                                    : null,
                              ),
                              const SizedBox(height: 20),

                              // Email
                              _fieldLabel('Email Address'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !anyLoading,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).requestFocus(_passwordFocus),
                                decoration: _inputDecoration('Enter your email'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  final emailRegex = RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                  );
                                  if (!emailRegex.hasMatch(v.trim())) {
                                    return 'Enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Password
                              _fieldLabel('Password'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: _obscurePassword,
                                enabled: !anyLoading,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_confirmPasswordFocus),
                                decoration: _inputDecoration(
                                  'Min 8 characters',
                                  isPassword: true,
                                  obscure: _obscurePassword,
                                  onToggle: () => setState(
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Confirm Password
                              _fieldLabel('Confirm Password'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _confirmPasswordController,
                                focusNode: _confirmPasswordFocus,
                                obscureText: _obscureConfirmPassword,
                                enabled: !anyLoading,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) =>
                                    FocusScope.of(context).unfocus(),
                                decoration: _inputDecoration(
                                  'Re-enter your password',
                                  isPassword: true,
                                  obscure: _obscureConfirmPassword,
                                  onToggle: () => setState(() =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword),
                                ),
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
                              const SizedBox(height: 20),

                              // Terms Checkbox
                              _buildTermsCheckbox(),
                              if (_showTermsError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6, left: 4),
                                  child: Text(
                                    'You must agree to the terms to continue',
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 28),

                              // Sign Up Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: anyLoading ? null : _handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: FinSpanTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
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
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Social divider
                              const Center(
                                child: Text(
                                  'or sign up with',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Social Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildGoogleCircle(anyLoading),
                                  const SizedBox(width: 24),
                                  _buildFacebookComingSoon(),
                                ],
                              ),
                              const SizedBox(height: 40),

                              // Footer
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Already have an account?  ',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                    GestureDetector(
                                      onTap: anyLoading
                                          ? null
                                          : () => Navigator.maybePop(context),
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
                              const SizedBox(height: 24),
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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: FinSpanTheme.charcoal,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    bool isPassword = false,
    bool obscure = true,
    VoidCallback? onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      suffixIcon: isPassword && onToggle != null
          ? IconButton(
              icon: Icon(
                obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 20,
                color: Colors.grey.shade600,
              ),
              onPressed: onToggle,
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF004D40), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _agreedToTerms = !_agreedToTerms;
          if (_agreedToTerms) _showTermsError = false;
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _agreedToTerms,
              onChanged: (v) {
                setState(() {
                  _agreedToTerms = v ?? false;
                  if (_agreedToTerms) _showTermsError = false;
                });
              },
              activeColor: FinSpanTheme.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.grey),
                children: [
                  const TextSpan(text: "I've read and agreed to the "),
                  TextSpan(
                    text: 'User Agreement',
                    style: const TextStyle(
                      color: Color(0xFF004D40),
                      fontWeight: FontWeight.bold,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                  const TextSpan(text: ' and '),
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
      width: 56,
      height: 56,
      child: _isGoogleLoading
          ? Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004D40)),
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
              icon: SvgPicture.string(
                _kGoogleSvg,
                width: 22,
                height: 22,
              ),
            ),
    );
  }

  Widget _buildFacebookComingSoon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: IconButton.outlined(
            onPressed: null,
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
              side: BorderSide(color: Colors.grey.shade200),
              backgroundColor: Colors.grey.shade50,
            ),
            icon: Icon(
              LucideIcons.facebook,
              size: 22,
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
