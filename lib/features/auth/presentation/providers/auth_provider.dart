import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _currentUser;
  bool isEmailVerified = false;

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

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        print('이메일 인증이 필요합니다. 인증 메일이 발송되었습니다.');
        return;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).get();
      _currentUser = UserModel(
        id: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? 'No Name',
        email: userCredential.user!.email!,
        profileImageUrl: userDoc['profileImageUrl'],
        isGuide: userDoc['isGuide'] ?? false,
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

      final userDoc = {
        'id': userCredential.user!.uid,
        'name': name,
        'email': email,
        'profileImageUrl': '',
        'isGuide': false,
      };
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(userDoc);
      _currentUser = UserModel.fromJson(userDoc);

      await userCredential.user!.sendEmailVerification();
      print('이메일 인증 메일 발송 시도');
      
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        print('이메일 인증 미완료: 다시 확인 필요');
      }
      notifyListeners();
    } catch (e) {
      print('회원가입 실패: $e');
    }
  }

  Future<void> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      isEmailVerified = user.emailVerified;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null && firebaseUser.emailVerified) {
      isEmailVerified = true;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (userSnapshot.exists) {
        _currentUser = UserModel(
          id: firebaseUser.uid,
          name: userSnapshot['name'] ?? firebaseUser.displayName ?? 'No Name',
          email: userSnapshot['email'] ?? firebaseUser.email!,
          profileImageUrl: userSnapshot['profileImageUrl'] as String?,
          isGuide: userSnapshot['isGuide'] as bool? ?? false,
        );
      }
    } else {
      isEmailVerified = false;
      _currentUser = null;
    }
    notifyListeners();
  }
}
