import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '806780929060-o8v56lii1e559inftmb802hokpvmqspt.apps.googleusercontent.com',
  );

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

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null; // Cancelled

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('🔒 AuthService: Firebase Auth Error (${e.code}): ${e.message}');
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('🚨 AuthService: General error during Google Sign-In: $e');
      }
      rethrow;
    }
  }

  // Sign out
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
