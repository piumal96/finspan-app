import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/onboarding/onboarding_data.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save the complete financial profile for the current user
  Future<void> saveUserProfile(OnboardingData data) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .set(data.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('Error saving user profile: $e');
      rethrow;
    }
  }

  // Fetch the complete financial profile for the current user
  Future<OnboardingData?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return OnboardingData.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return null;
  }

  // Check if the user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
