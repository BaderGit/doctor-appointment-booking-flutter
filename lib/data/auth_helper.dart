// ignore_for_file: body_might_complete_normally_nullable

import 'dart:developer';

// import 'package:final_project/utils/app_router.dart';

import 'package:final_project/l10n/app_localizations.dart';
import 'package:final_project/utils/custom_dialog.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthHelper {
  AuthHelper._();

  static AuthHelper authHelper = AuthHelper._();

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // Sign in method with email and password
  Future<UserCredential?> signIn(
    String emailAddress,
    String password,
    AppLocalizations localizations,
  ) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        CustomShowDialog.showDialogFunction(
          localizations.userNotFound,
          localizations,
        );
      } else if (e.code == 'wrong-password') {
        CustomShowDialog.showDialogFunction(
          localizations.wrongPassword,
          localizations,
        );
      }
    }

    return null;
  }

  // Get current user's ID
  String? getUserId() {
    return firebaseAuth.currentUser?.uid;
  }

  // Check if there's a user signed in
  Future<User?> checkUser() async {
    User? user = firebaseAuth.currentUser;
    return user;
  }

  // Sign up method with email and password

  Future<UserCredential?> signUp(
    String emailAddress,
    String password,
    AppLocalizations localization,
  ) async {
    try {
      // Attempt to create a new user with email and password
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        // Show dialog if password is too weak
        CustomShowDialog.showDialogFunction(
          localization.weakPassword,
          localization,
        );
      } else if (e.code == 'email-already-in-use') {
        CustomShowDialog.showDialogFunction(
          localization.emailInUse,
          localization,
        );
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // Sign out the current user
  signOut() async {
    await firebaseAuth.signOut();
  }

  // Send password reset email
  forgetPassword(String email, AppLocalizations localization) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);

      CustomShowDialog.showDialogFunction(
        localization.resetPasswordRequest,
        localization,
      );
    } catch (e) {
      CustomShowDialog.showDialogFunction(e.toString(), localization);
    }
  }
}
