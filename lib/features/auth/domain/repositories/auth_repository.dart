abstract class AuthRepository {
  Future<void> loginWithKakao();
  Future<void> loginWithNaver();
  Future<void> loginWithFacebook();
  Future<List<String>> getLikedPackages(String userId);
}


