import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/auth/domain/usecases/kakao_login_usecase.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';
import 'package:travel_on_final/features/auth/domain/usecases/google_login_usecase.dart';
import 'package:travel_on_final/features/auth/domain/usecases/naver_login_usecase.dart';
import 'package:travel_on_final/features/auth/domain/usecases/facebook_login_usecase.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final KakaoLoginUseCase _kakaoLoginUseCase;
  final TravelProvider _travelProvider;
  final GoogleLoginUseCase _googleLoginUseCase = GoogleLoginUseCase();
  final FacebookLoginUseCase _facebookLoginUseCase = FacebookLoginUseCase();
  final NaverLoginUseCase _naverLoginUseCase = NaverLoginUseCase();

  UserModel? _currentUser;
  bool isEmailVerified = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider(this._kakaoLoginUseCase, this._travelProvider) {
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
        throw '이메일 인증이 필요합니다. 인증 메일이 발송되었습니다.';
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final userData = userDoc.data() ?? {};

      if (!userDoc.exists) {
        final newUserDoc = {
          'id': userCredential.user!.uid,
          'name': userCredential.user!.displayName ?? 'No Name',
          'email': userCredential.user!.email!,
          'profileImageUrl': '',
          'isGuide': false,
          'likedPackages': [],
        };
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUserDoc);

        _currentUser = UserModel.fromJson(newUserDoc);
      } else {
        _currentUser = UserModel(
          id: userCredential.user!.uid,
          name: userData['name'] ?? userCredential.user!.displayName ?? 'No Name',
          email: userData['email'] ?? userCredential.user!.email!,
          profileImageUrl: userData['profileImageUrl'] as String?,
          isGuide: userData['isGuide'] as bool? ?? false,
          likedPackages: List<String>.from(userData['likedPackages'] ?? []),
        );
      }

      await _travelProvider.loadLikedPackages(_currentUser!.id);
      notifyListeners();
    } catch (e) {
      print('로그인 실패: $e');
      rethrow;
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
        'likedPackages': [],
      };
      await _firestore.collection('users').doc(userCredential.user!.uid).set(userDoc);
      _currentUser = UserModel.fromJson(userDoc);

      await userCredential.user!.sendEmailVerification();
      print('이메일 인증 메일 발송 시도');

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        print('이메일 인증 미완료: 다시 확인 필요');
      }
      notifyListeners();
    } catch (e) {
      print('회원가입 실패: $e');
      rethrow;
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

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null && firebaseUser.emailVerified) {
      isEmailVerified = true;
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        final userData = userDoc.data() ?? {};

        if (!userDoc.exists) {
          final newUserDoc = {
            'id': firebaseUser.uid,
            'name': firebaseUser.displayName ?? 'No Name',
            'email': firebaseUser.email!,
            'profileImageUrl': '',
            'isGuide': false,
            'likedPackages': [],
          };
          await _firestore
              .collection('users')
              .doc(firebaseUser.uid)
              .set(newUserDoc);

          _currentUser = UserModel.fromJson(newUserDoc);
        } else {
          _currentUser = UserModel(
            id: firebaseUser.uid,
            name: userData['name'] ?? firebaseUser.displayName ?? 'No Name',
            email: userData['email'] ?? firebaseUser.email!,
            profileImageUrl: userData['profileImageUrl'] as String?,
            isGuide: userData['isGuide'] as bool? ?? false,
            likedPackages: List<String>.from(userData['likedPackages'] ?? []),
          );
        }

        if (_currentUser != null) {
          await _travelProvider.loadLikedPackages(_currentUser!.id);
        }
      } catch (e) {
        print('Error in _onAuthStateChanged: $e');
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

  Future<void> toggleLikePackage(String packageId) async {
    if (_currentUser == null) throw '로그인이 필요합니다';

    try {
      final userRef = _firestore.collection('users').doc(_currentUser!.id);
      final userDoc = await userRef.get();

      final packageRef = _firestore.collection('packages').doc(packageId);
      final packageDoc = await packageRef.get();

      if (!userDoc.exists || !packageDoc.exists) {
        throw '사용자 또는 패키지를 찾을 수 없습니다';
      }

      List<String> userLikedPackages = List<String>.from(userDoc.data()!['likedPackages'] ?? []);
      List<String> packageLikedBy = List<String>.from(packageDoc.data()!['likedBy'] ?? []);

      bool isLiked = userLikedPackages.contains(packageId);
      if (isLiked) {
        userLikedPackages.remove(packageId);
        packageLikedBy.remove(_currentUser!.id);
      } else {
        userLikedPackages.add(packageId);
        packageLikedBy.add(_currentUser!.id);
      }

      await userRef.update({
        'likedPackages': userLikedPackages
      });

      await packageRef.update({
        'likedBy': packageLikedBy,
        'likesCount': packageLikedBy.length
      });

      _currentUser = _currentUser!.copyWith(
        likedPackages: userLikedPackages,
      );

      notifyListeners();
    } catch (e) {
      print('Error toggling like in AuthProvider: $e');
      rethrow;
    }
  }
}
