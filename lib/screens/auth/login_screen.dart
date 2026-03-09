import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/finspan_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/response_utils.dart';
import 'signup_screen.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ─── Email / Password Sign-In ─────────────────────────────────────────────

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

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
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (context.mounted) {
        // Pop LoginScreen back to root so AuthGate can render the dashboard.
        Navigator.of(context).popUntil((route) => route.isFirst);
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

  // ─── Google Sign-In ───────────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    if (!_authService.isAvailable) {
      ResponseUtils.showPremiumSnackBar(
        context,
        'Firebase is not configured. Please add the required config files.',
        isError: true,
      );
      return;
    }

    setState(() => _isGoogleLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result != null && context.mounted) {
        // Pop LoginScreen back to root so AuthGate renders the dashboard.
        Navigator.of(context).popUntil((route) => route.isFirst);
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

  // ─── Forgot Password ──────────────────────────────────────────────────────

  void _handleForgotPassword() {
    showDialog(
      context: context,
      builder: (ctx) => _ForgotPasswordDialog(
        initialEmail: _emailController.text.trim(),
        authService: _authService,
        parentContext: context,
      ),
    );
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
            // Back button
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, size: 22),
                  color: FinSpanTheme.charcoal,
                  onPressed: anyLoading
                      ? null
                      : () => Navigator.maybePop(context),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),

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
                        const SizedBox(height: 28),

                        // Title
                        const Text(
                          'Sign in to your account',
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
                              // Email
                              _fieldLabel('Email Address'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !anyLoading,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_passwordFocus),
                                decoration: _inputDecoration(
                                    'Enter your email address'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                  ).hasMatch(v.trim())) {
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
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) =>
                                    anyLoading ? null : _handleEmailSignIn(),
                                decoration: _inputDecoration(
                                  'Enter your password',
                                  isPassword: true,
                                ),
                                validator: (v) =>
                                    (v == null || v.isEmpty)
                                        ? 'Password is required'
                                        : null,
                              ),
                              const SizedBox(height: 12),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: anyLoading
                                      ? null
                                      : _handleForgotPassword,
                                  style: TextButton.styleFrom(
                                    foregroundColor: FinSpanTheme.primaryGreen,
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Sign In Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed:
                                      anyLoading ? null : _handleEmailSignIn,
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
                                          'Sign In',
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
                                  'or sign in with',
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
                                      "Don't have an account?  ",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 13),
                                    ),
                                    GestureDetector(
                                      onTap: anyLoading
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                _fadeSlideRoute(const SignUpScreen(
                                                  returnToLogin: true,
                                                )),
                                              );
                                            },
                                      child: const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          color: Color(0xFF004D40),
                                          fontWeight: FontWeight.bold,
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

  InputDecoration _inputDecoration(String hint, {bool isPassword = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 20,
                color: Colors.grey.shade600,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
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
        borderSide: const BorderSide(color: Color(0xFF004D40), width: 1.5),
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF004D40)),
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

  Route<T> _fadeSlideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
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
}

// ─── Forgot Password Dialog ────────────────────────────────────────────────

class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({
    required this.initialEmail,
    required this.authService,
    required this.parentContext,
  });

  final String initialEmail;
  final AuthService authService;
  final BuildContext parentContext;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _emailController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Reset Password',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Enter your email address and we'll send you a link to reset your password.",
            style: TextStyle(color: FinSpanTheme.bodyGray, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            enabled: !_isSending,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(LucideIcons.mail, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: FinSpanTheme.bodyGray),
          ),
        ),
        ElevatedButton(
          onPressed: _isSending
              ? null
              : () async {
                  final email = _emailController.text.trim();
                  if (!_isValidEmail(email)) {
                    ResponseUtils.showPremiumSnackBar(
                      context,
                      'Please enter a valid email address.',
                      isError: true,
                    );
                    return;
                  }
                  setState(() => _isSending = true);
                  try {
                    await widget.authService
                        .sendPasswordResetEmail(email: email);
                    if (context.mounted) Navigator.pop(context);
                    if (widget.parentContext.mounted) {
                      ResponseUtils.showPremiumSnackBar(
                        widget.parentContext,
                        'If an account exists for that email, a reset link is on its way.',
                        isSuccess: true,
                      );
                    }
                  } on FirebaseAuthException catch (e) {
                    if (context.mounted) {
                      setState(() => _isSending = false);
                      ResponseUtils.showPremiumSnackBar(
                        context,
                        AuthService.getFriendlyAuthError(e),
                        isError: true,
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      setState(() => _isSending = false);
                      ResponseUtils.showPremiumSnackBar(
                        context,
                        'Something went wrong. Please try again.',
                        isError: true,
                      );
                    }
                  }
                },
          child: _isSending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Send Reset Link'),
        ),
      ],
    );
  }
}
