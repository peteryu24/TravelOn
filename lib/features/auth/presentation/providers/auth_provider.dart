import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/auth/domain/usecases/kakao_login_usecase.dart';
import 'package:travel_on_final/features/search/presentation/providers/travel_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final KakaoLoginUseCase _kakaoLoginUseCase;
  final TravelProvider _travelProvider;  // final로 변경

  UserModel? _currentUser;
  bool isEmailVerified = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // 생성자에서 둘 다 받도록 수정
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
        'likedPackages': [],  // 빈 배열로 초기화
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

        final userData = userDoc.data() ?? {};  // null 체크 추가

        if (!userDoc.exists) {
          // 사용자 문서가 없으면 생성
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

  Future<void> loginWithKakao() async {
    try {
      final userModel = await _kakaoLoginUseCase.execute();
      if (userModel != null) {
        // 파이어베이스에서 사용자 정보 가져오기
        final userDoc = await _firestore
            .collection('users')
            .doc(userModel.id)
            .get();

        _currentUser = UserModel(
          id: userModel.id,
          name: userModel.name,
          email: userModel.email,
          profileImageUrl: userModel.profileImageUrl,
          isGuide: userDoc.exists ? userDoc['isGuide'] ?? false : false,
          likedPackages: userDoc.exists
              ? List<String>.from(userDoc['likedPackages'] ?? [])
              : [], // 찜 목록 로드
        );

        // 찜 목록 로드
        await _travelProvider.loadLikedPackages(_currentUser!.id);

        notifyListeners();
      } else {
        print('카카오톡 로그인 실패');
      }
    } catch (e) {
      print('카카오톡 로그인 에러: $e');
      rethrow;
    }
  }

  Future<void> toggleLikePackage(String packageId) async {
    if (_currentUser == null) throw '로그인이 필요합니다';

    try {
      // 사용자 문서 업데이트
      final userRef = _firestore.collection('users').doc(_currentUser!.id);
      final userDoc = await userRef.get();

      // 패키지 문서 업데이트
      final packageRef = _firestore.collection('packages').doc(packageId);
      final packageDoc = await packageRef.get();

      if (!userDoc.exists || !packageDoc.exists) {
        throw '사용자 또는 패키지를 찾을 수 없습니다';
      }

      List<String> userLikedPackages = List<String>.from(userDoc.data()!['likedPackages'] ?? []);
      List<String> packageLikedBy = List<String>.from(packageDoc.data()!['likedBy'] ?? []);

      // 좋아요 토글
      bool isLiked = userLikedPackages.contains(packageId);
      if (isLiked) {
        userLikedPackages.remove(packageId);
        packageLikedBy.remove(_currentUser!.id);
      } else {
        userLikedPackages.add(packageId);
        packageLikedBy.add(_currentUser!.id);
      }

      // 두 문서 업데이트
      await userRef.update({
        'likedPackages': userLikedPackages
      });

      await packageRef.update({
        'likedBy': packageLikedBy,
        'likesCount': packageLikedBy.length
      });

      // 현재 사용자 모델 업데이트
      _currentUser = _currentUser!.copyWith(
          likedPackages: userLikedPackages
      );

      notifyListeners();
    } catch (e) {
      print('Error toggling like in AuthProvider: $e');
      rethrow;
    }
  }
}