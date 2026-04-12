import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// LOGIN
  Future<User?> login(String email, String password) async {
    final res = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return res.user;
  }

  /// REGISTER
  Future<User?> register(String email, String password) async {
    final res = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return res.user;
  }

  /// GOOGLE LOGIN
  Future<User?> signInWithGoogle() async {
    try {
      print("Starting Google Sign-in...");

      // For Web: Use Firebase Auth directly
      // For Mobile: Use Google Sign-In package
      try {
        final result = await _auth.signInWithPopup(GoogleAuthProvider());
        print("Firebase popup sign-in successful: ${result.user?.email}");
        return result.user;
      } catch (webError) {
        print("Web popup failed: $webError, trying app method...");

        // Fallback to GoogleSignIn for Web (if package is available)
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          forceCodeForRefreshToken: true,
        );

        final googleUser = await googleSignIn.signIn();

        // User cancelled the sign-in
        if (googleUser == null) {
          print("Google Sign-in cancelled by user");
          return null;
        }

        print("Google user signed in: ${googleUser.email}");

        final googleAuth = await googleUser.authentication;

        if (googleAuth.accessToken == null) {
          throw Exception("Failed to get access token from Google");
        }

        print("Got authentication tokens from Google");

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print("Signing in to Firebase with credential...");
        final res = await _auth.signInWithCredential(credential);

        print("Firebase user signed in: ${res.user?.email}");
        return res.user;
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      print("Google Sign-in error: $e");
      rethrow;
    }
  }

  /// SAVE USER
  Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _firestore.collection("users").doc(uid).set({
      "uid": uid,
      "name": name,
      "email": email,
    });
  }

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
