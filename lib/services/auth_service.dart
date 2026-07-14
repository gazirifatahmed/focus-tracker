import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '858173166018-q7dpnd40t3vi8b788t01atlvsd5mudtd.apps.googleusercontent.com'
        : null,
  );

  Stream<User?> get user => _auth.authStateChanges();

  // 🟢 গুগল দিয়ে সাইন-ইন মেথড
  Future<User?> signInWithGoogle() async {
    print("🔵 [AUTH] signInWithGoogle called");
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signIn()
          .timeout(
            const Duration(seconds: 20),
            onTimeout: () =>
                throw TimeoutException('Google Sign-In timeout. Try again.'),
          );

      if (googleUser == null) {
        print("🟡 [AUTH] Google Sign-In canceled by user");
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result =
          await _auth.signInWithCredential(credential);
      print("🟢 [AUTH] Google Sign-In successful for ${result.user?.email}");

      return result.user;
    } on TimeoutException catch (e) {
      print("🔴 [AUTH] Google Timeout: ${e.message}");
      throw 'Network timeout! Please check your internet connection.';
    } on FirebaseAuthException catch (e) {
      print("🔴 [AUTH] FirebaseAuthException (Google): ${e.code} - ${e.message}");
      throw _getFriendlyErrorMessage(e);
    } catch (e) {
      print("🔴 [AUTH] Unknown Google Sign-In error: $e");
      if (e.toString().contains('sign_in_failed') ||
          e.toString().contains('popup_closed')) {
        throw 'Google Sign-In failed. Please ensure your device has internet and proper Google Services setup.';
      }
      throw 'An error occurred during Google Sign-In. Please try again.';
    }
  }

  // 🔵 সাইন-আপ মেথড (ফ্রিজিং ইস্যু ফিক্সড)
  Future<User?> signUp(String email, String password) async {
    print("🔵 [AUTH] signUp called for $email");
    try {
      final result = await _auth
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException(
            'Firebase authentication timeout. Check your internet connection.');
      });

      print("🟢 [AUTH] User created successfully");

      if (!kIsWeb) {
        await result.user?.sendEmailVerification();
        print("🟢 [AUTH] Verification email sent (mobile)");
      } else {
        print("⚠️ [AUTH] Skipping email verification on Web");
      }

      // এখানে অটোমেটিক signOut কল করা যাবে না, কারণ এটি authStateChanges স্ট্রিমকে ট্রিগার করে 
      // উইজেট ট্রি রি-বিল্ড করে দেয় যার ফলে UI স্পিনার ফ্রিজ হয়ে যেত।
      return result.user;
    } on TimeoutException catch (e) {
      print("🔴 [AUTH] Timeout: ${e.message}");
      throw 'Network timeout! Please check your internet connection.';
    } on FirebaseAuthException catch (e) {
      print("🔴 [AUTH] FirebaseAuthException: ${e.code} - ${e.message}");
      throw _getFriendlyErrorMessage(e);
    } catch (e) {
      print("🔴 [AUTH] Unknown error: $e");
      throw 'An unknown error occurred. Please try again later.';
    }
  }

  // 🟡 সাইন-ইন মেথড
  Future<User?> signIn(String email, String password) async {
    print("🔵 [AUTH] signIn called for $email");
    try {
      final result = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
          .timeout(const Duration(seconds: 10));
      final user = result.user;

      if (!kIsWeb && user != null && !user.emailVerified) {
        print("🟡 [AUTH] Email not verified");
        // লগইন স্ক্রিনে এরর হ্যান্ডেল করার জন্য সাইন আউট করে থ্রো করা হচ্ছে
        await _auth.signOut();
        throw 'Your email is not verified yet. Please check your inbox.';
      }
      print("🟢 [AUTH] Sign in successful");
      return user;
    } on TimeoutException {
      throw 'Network timeout! Please check your internet connection.';
    } on FirebaseAuthException catch (e) {
      print("🔴 [AUTH] FirebaseAuthException: ${e.code}");
      throw _getFriendlyErrorMessage(e);
    } catch (e) {
      print("🔴 [AUTH] Other error: $e");
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    } else {
      throw Exception('Email already verified or no user logged in.');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _getFriendlyErrorMessage(e);
    }
  }

  Future<void> reauthenticateAndChangePassword(
      String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No user logged in');
    final cred = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(cred);
    await user.updatePassword(newPassword);
  }

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'email-already-in-use':
        return 'This email address is already in use by another account. Please log in.';
      case 'weak-password':
        return 'The password is too weak. Must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection detected.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please check Firebase console.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      default:
        return e.message ?? 'An unexpected error occurred.';
    }
  }
}