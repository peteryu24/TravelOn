import 'package:travel_on_final/features/search/domain/entities/travel_package.dart';

abstract class TravelRepository {
  Future<List<TravelPackage>> getPackages();
  Future<void> addPackage(TravelPackage package);  // 추가된 메서드
}
