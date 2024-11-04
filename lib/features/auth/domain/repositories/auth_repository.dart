abstract class AuthRepository {
  Future<void> loginWithKakao();
  Future<void> loginWithNaver();
  Future<void> loginWithFacebook();
}
