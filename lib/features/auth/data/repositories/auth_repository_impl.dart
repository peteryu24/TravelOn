import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:travel_on_final/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> loginWithKakao() async {
    try {
      if (await isKakaoTalkInstalled()) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }
    } catch (e) {
      print('카카오톡 로그인 실패: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getLikedPackages(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return [];
      }

      final data = userDoc.data()!;
      return List<String>.from(data['likedPackages'] ?? []);
    } catch (e) {
      print('Error getting liked packages: $e');
      return [];
    }
  }

   
  @override
  Future<void> loginWithNaver() async {
  }

  @override
  Future<void> loginWithFacebook() async {
  }
}

