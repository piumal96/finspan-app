import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AuthService {
  // Access instance lazily to avoid crash if Firebase initialization failed
  FirebaseAuth get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      throw Exception(
        'Firebase is not initialized. Please check your configuration.',
      );
    }
  }

  // Do NOT pass serverClientId here — on Android, Firebase reads the web
  // client ID from google-services.json automatically.  Passing it explicitly
  // causes getTokenWithDetails UNKNOWN errors on some Play Services versions.
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Check if Firebase is successfully initialized
  bool get isAvailable {
    try {
      FirebaseAuth.instance;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get current user
  User? get currentUser => isAvailable ? _auth.currentUser : null;

  // Auth state changes stream
  Stream<User?> get authStateChanges =>
      isAvailable ? _auth.authStateChanges() : Stream.value(null);

  // ─── Google Sign-In ────────────────────────────────────────────────────────

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out first to force the account picker to appear every time
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled the picker

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // idToken should always be present when google-services.json is correct
      if (googleAuth.idToken == null) {
        throw Exception(
          'Google Sign-In did not return an ID token. '
          'Check that the SHA-1 fingerprint is registered in Firebase console '
          'and google-services.json is up to date.',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('🔒 AuthService: Firebase Auth Error (${e.code}): ${e.message}');
      }
      rethrow;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('🚨 AuthService: Google Sign-In platform error: ${e.code} — ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('🚨 AuthService: General error during Google Sign-In: $e');
      }
      rethrow;
    }
  }

  // ─── Email / Password Sign-In ──────────────────────────────────────────────

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('🔒 AuthService: Sign-in error (${e.code}): ${e.message}');
      }
      rethrow;
    }
  }

  // ─── Email / Password Register ────────────────────────────────────────────

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Set display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
        await credential.user?.reload();
      }

      // Send email verification
      await credential.user?.sendEmailVerification();

      return credential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('🔒 AuthService: Register error (${e.code}): ${e.message}');
      }
      rethrow;
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('🔒 AuthService: Password reset error (${e.code}): ${e.message}');
      }
      rethrow;
    }
  }

  // ─── Friendly error messages ──────────────────────────────────────────────

  static String getFriendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Email or password is incorrect. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Contact support.';
      default:
        return e.message ?? 'An unexpected error occurred. Please try again.';
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await Future.wait([
        if (isAvailable) _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      if (kDebugMode) {
        print('🚪 AuthService: Logout error: $e');
      }
      rethrow;
    }
  }
}
