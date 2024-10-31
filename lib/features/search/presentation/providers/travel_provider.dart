import 'package:flutter/foundation.dart';
import '../../domain/repositories/travel_repositories.dart';
import '../../domain/entities/travel_package.dart';

class TravelProvider extends ChangeNotifier {
  final TravelRepository _repository;
  List<TravelPackage> _packages = [];
  String _selectedRegion = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  TravelProvider(this._repository) {
    loadPackages();
  }

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedRegion => _selectedRegion;
  String get searchQuery => _searchQuery;

  // 패키지 목록 getter - 검색어와 지역 필터 모두 적용
  List<TravelPackage> get packages {
    List<TravelPackage> filteredPackages = _packages;

    // 검색어 필터링
    if (_searchQuery.isNotEmpty) {
      filteredPackages = filteredPackages.where((package) {
        final query = _searchQuery.toLowerCase();
        return package.title.toLowerCase().contains(query) ||
            package.description.toLowerCase().contains(query);
      }).toList();
    }

    // 지역 필터링
    if (_selectedRegion != 'all') {
      filteredPackages = filteredPackages.where(
              (package) => package.region == _selectedRegion
      ).toList();
    }

    return filteredPackages;
  }

  // 검색 기능
  void search(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  // 검색어 초기화
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // 지역 필터링
  void filterByRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  // 모든 필터 초기화
  void clearFilters() {
    _selectedRegion = 'all';
    _searchQuery = '';
    notifyListeners();
  }

  // 패키지 목록 로드
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

  // 패키지 추가
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

  // 특정 패키지 검색
  TravelPackage? getPackageById(String id) {
    try {
      return _packages.firstWhere((package) => package.id == id);
    } catch (e) {
      return null;
    }
  }

  // 에러 상태 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}