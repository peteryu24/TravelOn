import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = UserModel(
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? 'No Name',
        email: userCredential.user!.email!,
      );
      notifyListeners();
    } catch (e) {
      print('로그인 실패: $e');
    }
  }

  Future<void> signup(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.updateDisplayName(name);
      _currentUser = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: userCredential.user!.email!,
      );
      notifyListeners();
    } catch (e) {
      print('회원가입 실패: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _onAuthStateChanged(User? firebaseUser) {
    if (firebaseUser != null) {
      _currentUser = UserModel(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'No Name',
        email: firebaseUser.email!,
      );
    } else {
      _currentUser = null;
    }
    notifyListeners();
  }
}
