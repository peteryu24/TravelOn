import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/auth/domain/usecases/kakao_login_usecase.dart';
import 'package:travel_on_final/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:travel_on_final/features/auth/domain/usecases/naver_login_usecase.dart';
import 'package:travel_on_final/features/auth/domain/usecases/facebook_login_usecase.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final KakaoLoginUseCase _kakaoLoginUseCase;
  final GoogleLoginUseCase _googleLoginUseCase = GoogleLoginUseCase();
  final FacebookLoginUseCase _facebookLoginUseCase = FacebookLoginUseCase();
  final NaverLoginUseCase _naverLoginUseCase = NaverLoginUseCase();

  UserModel? _currentUser;
  bool isEmailVerified = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Firebase 인증 상태가 변경되면 onAuthStateChanged 메서드 호출
  AuthProvider(this._kakaoLoginUseCase) {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // 로그인 하는 메서드, 이메일 인증이 안되어 있다면 인증 메일을 보내고 인증을 기다린다.
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

  // 계정 회원가입 메서드, 인증을 보낸다
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

  // 인증 상태 확인
  Future<void> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      isEmailVerified = user.emailVerified;
      notifyListeners();
    }
  }

  // 로그아웃 메서드
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // 가이드 인증 메서드
  Future<void> certifyAsGuide(File certificateImage) async {
    try {
      if (_currentUser == null) throw '로그인이 필요합니다';

      final storageRef = _storage
          .ref()
          .child('guide_certificates')
          .child('${_currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(certificateImage);
      final imageUrl = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(_currentUser!.id).update({
        'isGuide': true,
        'certificateImageUrl': imageUrl,
        'certifiedAt': FieldValue.serverTimestamp(),
      });

      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        profileImageUrl: _currentUser!.profileImageUrl,
        isGuide: true,
      );

      notifyListeners();
    } catch (e) {
      print('가이드 인증 실패: $e');
      throw '가이드 인증에 실패했습니다';
    }
  }

  // 인증 상태 변경 핸들러, 인증 상태가 변경될 때 호출
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

  /////////////////////////////////////////////////////////////////////
  /// 소셜 로그인
  // Future<void> loginWithKakao() async {
  //   try {
  //     final userModel = await _kakaoLoginUseCase.execute();
  //     if (userModel != null) {
  //       await _firestore.collection('users').doc(userModel.id).set({
  //         'id': userModel.id,
  //         'name': userModel.name,
  //         'email': userModel.email,
  //         'profileImageUrl': userModel.profileImageUrl,
  //         'isGuide': userModel.isGuide,
  //       }, SetOptions(merge: true));

  //       _currentUser = userModel;
  //       notifyListeners();
  //     } else {
  //       print('카카오톡 로그인 실패');
  //     }
  //   } catch (e) {
  //     print('카카오톡 로그인 에러: $e');
  //   }
  // }

  // Future<void> loginWithGoogle() async {
  //   final userModel = await _googleLoginUseCase.execute();
  //   if (userModel != null) {
  //     await _firestore.collection('users').doc(userModel.id).set({
  //       'id': userModel.id,
  //       'name': userModel.name,
  //       'email': userModel.email,
  //       'profileImageUrl': userModel.profileImageUrl ?? '',
  //       'isGuide': userModel.isGuide ?? false,
  //     }, SetOptions(merge: true));

  //     _currentUser = userModel;
  //     notifyListeners();
  //   } else {
  //     print('Google 로그인 실패');
  //   }
  // }



  // // Facebook 로그인 메서드
  // Future<void> loginWithFacebook() async {
  //   try {
  //     final userModel = await _facebookLoginUseCase.execute();
  //     if (userModel != null) {
  //       await _firestore.collection('users').doc(userModel.id).set({
  //         'id': userModel.id,
  //         'name': userModel.name,
  //         'email': userModel.email,
  //         'profileImageUrl': userModel.profileImageUrl ?? '',
  //         'isGuide': userModel.isGuide ?? false,
  //       }, SetOptions(merge: true));

  //       _currentUser = userModel;
  //       notifyListeners();
  //     } else {
  //       print('Facebook 로그인 실패');
  //     }
  //   } catch (e) {
  //     print('Facebook 로그인 에러: $e');
  //   }
  // }

  // Future<void> loginWithNaver() async {
  //   try {
  //     final userModel = await _naverLoginUseCase.execute();
  //     if (userModel != null) {
  //       await _firestore.collection('users').doc(userModel.id).set({
  //         'id': userModel.id,
  //         'name': userModel.name,
  //         'email': userModel.email,
  //         'profileImageUrl': userModel.profileImageUrl ?? '',
  //         'isGuide': userModel.isGuide ?? false,
  //       }, SetOptions(merge: true));

  //       _currentUser = userModel;
  //       notifyListeners();
  //     } else {
  //       print('Naver 로그인 실패');
  //     }
  //   } catch (e) {
  //     print('Naver 로그인 에러: $e');
  //   }
  // }
}
