import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';
import 'package:travel_on_final/features/auth/domain/repositories/auth_repository.dart';

class KakaoLoginUseCase {
  final AuthRepository authRepository;

  KakaoLoginUseCase(this.authRepository);

  Future<UserModel?> execute() async {
    try {
      await authRepository.loginWithKakao();
      User kakaoUser = await UserApi.instance.me();
      return UserModel(
        id: kakaoUser.id.toString(),
        name: kakaoUser.kakaoAccount?.profile?.nickname ?? 'Unknown',
        email: kakaoUser.kakaoAccount?.email ?? 'Unknown',
        profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl ?? '',
      );
    } catch (error) {
      print('카카오톡 로그인 에러: $error');
      return null;
    }
  }
}
