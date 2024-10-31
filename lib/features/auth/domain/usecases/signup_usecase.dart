import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';

class SignupUseCase {
  final AuthProvider authProvider;

  SignupUseCase(this.authProvider);

  Future<void> execute(String email, String password, String name) async {
    await authProvider.signup(email, password, name);
  }
}
