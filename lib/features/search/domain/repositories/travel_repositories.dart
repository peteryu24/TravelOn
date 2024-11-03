import 'package:travel_on_final/features/search/domain/entities/travel_package.dart';

abstract class TravelRepository {
  Future<List<TravelPackage>> getPackages();
  Future<void> addPackage(TravelPackage package);
  Future<void> updatePackage(TravelPackage package); // 추가
  Future<void> deletePackage(String packageId); // 추가
}
