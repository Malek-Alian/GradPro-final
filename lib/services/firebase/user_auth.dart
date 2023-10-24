import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';

class UserAuth extends ChangeNotifier {
  // * Create user
  UserModel userData = UserModel();

  set setUserEmail(String? email) => userData.email = email ?? '';
  set setUserPassword(String? password) => userData.password = password ?? '';

  // * Create Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  String errorMessage = '';

  set setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  set setMessage(String value) {
    errorMessage = value;
    notifyListeners();
  }

  Future<User?>? get activate async {
    try {
      isLoading = true;
      UserCredential authResult = await _auth.signInWithEmailAndPassword(
        email: userData.email,
        password: userData.password,
      );
      late User user;
      if (authResult.user?.uid.isNotEmpty ?? false) {
        user = authResult.user!;
        setLoading = false;
      }
      return user;
    } on SocketException {
      setLoading = false;
      setMessage = 'No Internet';
    } on FirebaseAuthException catch (error) {
      setLoading = false;
      setMessage = error.message ?? '';
    } catch (e) {
      setLoading = false;
      setMessage = e.toString();
    }
    return null;
  }

  Future<void> resetPassword(String? email) async {
    try {
      await _auth.sendPasswordResetEmail(email: '$email');
    } on SocketException {
      setLoading = false;
      setMessage = 'No Internet';
    } on FirebaseAuthException catch (error) {
      setLoading = false;
      setMessage = error.message ?? '';
    } catch (e) {
      setLoading = false;
      setMessage = e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User get currentUser => _auth.currentUser!;

  Stream<User?> get userStream => _auth.authStateChanges();
}
