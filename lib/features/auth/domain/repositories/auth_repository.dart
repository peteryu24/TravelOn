abstract class AuthRepository {
  Future<void> loginWithKakao();
  Future<void> loginWithNaver();
  Future<void> loginWithGoogle();
  Future<void> loginWithFacebook();
  // 다른 로그인 메서드들도 여기에 추가
}
