import 'package:discover/features/gamification/domain/repository/user_repository.dart';
import 'package:discover/features/gamification/domain/use_case/user_service.dart';

class AppServices {
  AppServices._();
  static final UserRepository userRepository = UserRepository();
  static final UserService userService = UserService(userRepository);
}
