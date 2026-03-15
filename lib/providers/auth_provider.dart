import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  static const String _nameKey = 'profile_name';
  static const String _avatarKey = 'profile_avatar_b64';

  AuthProvider({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance {
    _loadProfileFromLocal();
    _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  final FirebaseAuth _auth;

  bool _isLoading = false;
  String? _error;
  String? _name;
  String? _avatarBase64;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  String get displayName {
    return (_name?.trim().isNotEmpty ?? false)
        ? _name!.trim()
        : (currentUser?.displayName?.trim().isNotEmpty ?? false)
            ? currentUser!.displayName!.trim()
            : 'Guest User';
  }

  String get email => currentUser?.email ?? 'No email';
  Uint8List? get avatarBytes =>
      _avatarBase64 == null ? null : base64Decode(_avatarBase64!);

  Future<bool> login({required String email, required String password}) async {
    _startLoading();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Login failed';
      return false;
    } catch (_) {
      _error = 'Unexpected login error';
      return false;
    } finally {
      _stopLoading();
    }
  }

  Future<bool> signup({required String email, required String password}) async {
    _startLoading();
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _error = null;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Sign up failed';
      return false;
    } catch (_) {
      _error = 'Unexpected sign up error';
      return false;
    } finally {
      _stopLoading();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<void> updateName(String value) async {
    final String trimmed = value.trim();
    _name = trimmed;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, trimmed);
    notifyListeners();
  }

  Future<void> updateAvatar(Uint8List bytes) async {
    _avatarBase64 = base64Encode(bytes);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarKey, _avatarBase64!);
    notifyListeners();
  }

  Future<void> _loadProfileFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey);
    _avatarBase64 = prefs.getString(_avatarKey);
    notifyListeners();
  }

  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }
}
