import 'package:discover/core/app_service.dart';
import 'package:discover/features/authentication/domain/use_cases/authentication_service.dart';
import 'package:discover/features/gamification/utils.dart';
import 'package:discover/features/maps/domain/entities/rewards_service.dart';


class RewardsAdapter implements RewardsService {
  final int xpPerPoi;
  final int flamingoPerPoi;
  RewardsAdapter({this.xpPerPoi = 50, this.flamingoPerPoi = 50});

  @override
  Future<void> reward({required int xp, required int flamingo}) async {
    final email = getUserEmail();
    if (email == null) return;
    await giveXp(service: AppServices.userService, email: email, xp: xp);
    await giveFlamingo(service: AppServices.userService, email: email, qty: flamingo);
  }
}