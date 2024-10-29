// lib/features/search/presentation/providers/travel_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/repositories/travel_repositories.dart';
import '../../domain/entities/travel_package.dart';

class TravelProvider extends ChangeNotifier {
  final TravelRepository _repository;
  List<TravelPackage> _packages = [];
  String _selectedRegion = 'all';
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedRegion => _selectedRegion;

  TravelProvider(this._repository) {
    loadPackages();
  }

  List<TravelPackage> get packages => _selectedRegion == 'all'
      ? _packages
      : _packages.where((package) => package.region == _selectedRegion).toList();

  Future<void> loadPackages() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _packages = await _repository.getPackages();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error loading packages: $e');
    }
  }

  void filterByRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  Future<void> addPackage(TravelPackage package) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.addPackage(package);
      await loadPackages();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error adding package: $e');
      rethrow;
    }
  }
}