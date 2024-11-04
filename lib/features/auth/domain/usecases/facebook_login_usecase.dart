import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';

class FacebookLoginUseCase {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> execute() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success && result.accessToken != null) {
        final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          return UserModel(
            id: user.uid,
            name: user.displayName ?? 'No Name',
            email: user.email ?? 'No Email',
            profileImageUrl: user.photoURL,
          );
        }
      } else {
        print('Facebook 로그인 취소 또는 실패');
      }
    } catch (error) {
      print('Facebook 로그인 에러: $error');
    }
    return null;
  }
}
