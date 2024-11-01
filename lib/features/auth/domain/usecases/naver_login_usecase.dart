import 'package:travel_on_final/features/auth/data/models/user_model.dart';
import 'package:travel_on_final/features/auth/domain/repositories/auth_repository.dart';

class NaverLoginUsecase {
  final AuthRepository authRepository;

  NaverLoginUsecase(this.authRepository);

  Future<UserModel?> execute() async {
    
  }
}