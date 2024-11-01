import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:travel_on_final/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
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
  Future<void> loginWithNaver() async {
  }

  @override
  Future<void> loginWithGoogle() async {
  }

  @override
  Future<void> loginWithFacebook() async {
  }
}
