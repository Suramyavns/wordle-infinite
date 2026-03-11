import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? get currentUser => auth.currentUser;

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (kDebugMode) {
        print('Failed to authenticate $e');
      }
      return null;
    }
  }

  Future<void> signOutWithGoogle() async {
    await Future.wait([auth.signOut(), googleSignIn.signOut()]);
  }
}
