import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';

class GoogleLoginUseCase {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> execute() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // 로그인 취소
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

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
    } catch (error) {
      print('Google 로그인 에러: $error');
    }
    return null;
  }
}
