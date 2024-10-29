import 'package:flutter/foundation.dart';
import 'package:travel_on_final/features/search/domain/repositories/travel_repositories.dart';
import '../../domain/entities/travel_package.dart';

class TravelProvider extends ChangeNotifier {
  final TravelRepository? _repository;
  List<TravelPackage> _packages = [];
  String _selectedRegion = 'all';

  TravelProvider([this._repository]);

  List<TravelPackage> get packages => _selectedRegion == 'all'
      ? _packages
      : _packages.where((package) => package.region == _selectedRegion).toList();

  Future<void> loadPackages() async {
    if (_repository != null) {
      _packages = await _repository.getPackages();
      notifyListeners();
    }
  }

  void filterByRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  void addPackage(TravelPackage package) {
    _packages.add(package);
    if (_repository != null) {
      _repository.addPackage(package);
    }
    notifyListeners();
  }
}