import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  bool isLoading = false;
  bool isLoggedIn = false;
  String? error;
  User? user;

  /// LOGIN
  Future<void> login(String email, String password) async {
    try {
      _setLoading(true);

      user = await _service.login(email, password);

      if (user != null) {
        isLoggedIn = true;
        error = null;
        notifyListeners();
      } else {
        error = "Login failed";
      }
    } on FirebaseAuthException catch (e) {
      error = _getMessage(e);
      isLoggedIn = false;
    } catch (e) {
      error = "Something went wrong: $e";
      isLoggedIn = false;
    }

    _setLoading(false);
  }

  /// REGISTER
  Future<void> register(String name, String email, String password) async {
    try {
      _setLoading(true);

      user = await _service.register(email, password);

      if (user != null) {
        await _service.saveUser(uid: user!.uid, name: name, email: email);
        isLoggedIn = true;
        error = null;
        notifyListeners();
      } else {
        error = "Registration failed";
        isLoggedIn = false;
      }
    } on FirebaseAuthException catch (e) {
      error = _getMessage(e);
      isLoggedIn = false;
    } catch (e) {
      error = "Registration error: $e";
      isLoggedIn = false;
    }

    _setLoading(false);
  }

  /// GOOGLE LOGIN
  Future<void> googleLogin() async {
    _setLoading(true);

    try {
      error = null;
      isLoggedIn = false;
      notifyListeners();

      user = await _service.signInWithGoogle();

      // User cancelled the sign-in
      if (user == null) {
        error = null; // User cancelled, don't show error
        _setLoading(false);
        return;
      }

      // Save user data to Firestore
      try {
        await _service.saveUser(
          uid: user!.uid,
          name: user!.displayName ?? "User",
          email: user!.email ?? "",
        );
      } catch (e) {
        print("Error saving user to Firestore: $e");
        // Continue even if save fails - user is authenticated
      }

      isLoggedIn = true;
      error = null;
      _setLoading(false);
    } on FirebaseAuthException catch (e) {
      error = _getMessage(e);
      isLoggedIn = false;
      _setLoading(false);
    } catch (e) {
      // Extract meaningful error message
      String errorMsg = e.toString();
      if (errorMsg.contains('popup')) {
        error = "Pop-ups blocked. Please allow pop-ups and try again.";
      } else if (errorMsg.contains('network')) {
        error = "Network error. Check your connection.";
      } else if (errorMsg.contains('CONFIGURATION_NOT_FOUND')) {
        error = "Google Sign-In not configured. Check Firebase Console.";
      } else {
        error = "Authentication failed: $errorMsg";
      }
      isLoggedIn = false;
      _setLoading(false);
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _service.logout();
    user = null;
    isLoggedIn = false;
    notifyListeners();
  }

  /// ERROR MESSAGES
  String _getMessage(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        return "User not found";
      case "wrong-password":
        return "Wrong password";
      case "email-already-in-use":
        return "Email already exists";
      case "weak-password":
        return "Weak password";
      default:
        return e.message ?? "Auth error";
    }
  }

  void _setLoading(bool value) {
    isLoading = value;
    error = null;
    notifyListeners();
  }
}
