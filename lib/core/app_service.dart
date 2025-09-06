import 'package:discover/features/gamification/domain/repository/user_repository.dart';
import 'package:discover/features/gamification/domain/use_case/user_service.dart';
import 'package:flutter/foundation.dart';

class AppServices {
  AppServices._();
  static final UserRepository userRepository = UserRepository();
  static final UserService userService = UserService(userRepository);
}


class AppBus {
  // +1 when change avatar or background
  static final ValueNotifier<int> visualsVersion = ValueNotifier<int>(0);
}