abstract class AuthRepository {
  Future<void> loginWithKakao();
  Future<List<String>> getLikedPackages(String userId);
}


