import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/finspan_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/finspan_card.dart';
import '../../utils/response_utils.dart';
import 'signup_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

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
        email: _emailController.text,
        password: _passwordController.text,
      );
      // AuthGate's StreamBuilder detects the new user and navigates automatically.
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
      await _authService.signInWithGoogle();
      // Null return means user cancelled the picker — no error to show.
      // On success, AuthGate's StreamBuilder navigates automatically.
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ResponseUtils.showPremiumSnackBar(
          context,
          AuthService.getFriendlyAuthError(e),
          isError: true,
        );
      }
    } on PlatformException catch (e) {
      // Covers Google Sign-In SDK errors (e.g., network, Play Services, SHA mismatch)
      if (context.mounted) {
        final msg = e.code == 'sign_in_canceled'
            ? 'Sign-in cancelled.'
            : 'Google Sign-In failed (${e.code}). '
                'Make sure Google Play Services is up to date and try again.';
        ResponseUtils.showPremiumSnackBar(context, msg, isError: true);
      }
    } catch (e) {
      if (context.mounted) {
        ResponseUtils.showPremiumSnackBar(
          context,
          'Google Sign-In failed. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────

  void _handleForgotPassword() {
    final emailController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reset Password',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(color: FinSpanTheme.bodyGray, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: FinSpanTheme.bodyGray),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ResponseUtils.showPremiumSnackBar(
                  ctx,
                  'Please enter a valid email address.',
                  isError: true,
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                await _authService.sendPasswordResetEmail(email: email);
                if (context.mounted) {
                  ResponseUtils.showPremiumSnackBar(
                    context,
                    'Password reset email sent! Check your inbox.',
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
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool anyLoading = _isLoading || _isGoogleLoading;

    return Scaffold(
      backgroundColor: FinSpanTheme.backgroundLight,
      body: Stack(
        children: [
          // Subtle background gradient
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
                        const SizedBox(height: 8),
                        // Title
                        Hero(
                          tag: 'auth_title',
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
                        const SizedBox(height: 10),
                        Text(
                          'Securely sync your financial roadmap across all your devices.',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: FinSpanTheme.bodyGray,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 32),

                        // Main card
                        FinSpanCard(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Google button
                                _buildGoogleButton(anyLoading),
                                const SizedBox(height: 24),
                                _buildDivider(),
                                const SizedBox(height: 24),

                                // Email field
                                TextFormField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  textInputAction: TextInputAction.next,
                                  enabled: !anyLoading,
                                  onFieldSubmitted: (_) => FocusScope.of(
                                    context,
                                  ).requestFocus(_passwordFocus),
                                  decoration: const InputDecoration(
                                    labelText: 'Email Address',
                                    hintText: 'name@example.com',
                                    prefixIcon: Icon(
                                      LucideIcons.mail,
                                      size: 20,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Email is required.';
                                    }
                                    final emailRegex = RegExp(
                                      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                                    );
                                    if (!emailRegex.hasMatch(value.trim())) {
                                      return 'Enter a valid email address.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password field
                                TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [AutofillHints.password],
                                  textInputAction: TextInputAction.done,
                                  enabled: !anyLoading,
                                  onFieldSubmitted: (_) => _handleEmailSignIn(),
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: '••••••••',
                                    prefixIcon: const Icon(
                                      LucideIcons.lock,
                                      size: 20,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 20,
                                        color: FinSpanTheme.bodyGray,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required.';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: anyLoading
                                        ? null
                                        : _handleForgotPassword,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: FinSpanTheme.primaryGreen,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Sign-In button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: anyLoading
                                        ? null
                                        : _handleEmailSignIn,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              key: ValueKey('loading'),
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              key: ValueKey('label'),
                                              'Sign In Securely',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),
                        _buildFooter(anyLoading),
                        const SizedBox(height: 24),
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

  Widget _buildGoogleButton(bool disabled) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: disabled ? null : _handleGoogleSignIn,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
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
          child: _isGoogleLoading
              ? const SizedBox(
                  key: ValueKey('gload'),
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
                  key: const ValueKey('gbtn'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                      width: 20,
                      height: 20,
                      errorBuilder: (c, e, s) =>
                          const Icon(LucideIcons.logIn, size: 20),
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

  Widget _buildFooter(bool disabled) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account?",
                style: TextStyle(color: FinSpanTheme.bodyGray, fontSize: 14),
              ),
              TextButton(
                onPressed: disabled
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpScreen(),
                          ),
                        );
                      },
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    color: FinSpanTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.lock,
                size: 12,
                color: FinSpanTheme.bodyGray.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Protected by 256-bit encryption',
                style: TextStyle(
                  color: FinSpanTheme.bodyGray.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
