import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';
import '../../domain/repositories/travel_repositories.dart';
import '../../domain/entities/travel_package.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class TravelProvider extends ChangeNotifier {
  final TravelRepository _repository;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  // 추가
  List<TravelPackage> _packages = [];
  Set<String> _likedPackageIds = {};  // 찜한 패키지 ID 목록
  String _selectedRegion = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  TravelProvider(this._repository, {required FirebaseAuth auth})
      : _auth = auth {
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
      filteredPackages = filteredPackages
          .where((package) => package.region == _selectedRegion)
          .toList();
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

  Future<void> toggleLike(String packageId, UserModel user) async {
    try {
      // 패키지와 유저 문서 참조
      final userRef = _firestore.collection('users').doc(user.id);
      final packageRef = _firestore.collection('packages').doc(packageId);

      // 현재 상태 확인
      final userDoc = await userRef.get();
      final packageDoc = await packageRef.get();

      if (!userDoc.exists || !packageDoc.exists) {
        throw '사용자 또는 패키지를 찾을 수 없습니다';
      }

      // 현재 상태 가져오기
      List<String> userLikedPackages = List<String>.from(userDoc.data()!['likedPackages'] ?? []);
      List<String> packageLikedBy = List<String>.from(packageDoc.data()!['likedBy'] ?? []);
      int currentLikesCount = packageDoc.data()!['likesCount'] ?? 0;

      // 좋아요 토글
      bool isLiked = userLikedPackages.contains(packageId);
      if (isLiked) {
        // 좋아요 취소
        userLikedPackages.remove(packageId);
        packageLikedBy.remove(user.id);
        currentLikesCount = math.max(0, currentLikesCount - 1);
        _likedPackageIds.remove(packageId);
      } else {
        // 좋아요 추가
        userLikedPackages.add(packageId);
        packageLikedBy.add(user.id);
        currentLikesCount++;
        _likedPackageIds.add(packageId);
      }

      // 각각 업데이트
      await userRef.update({
        'likedPackages': userLikedPackages,
      });

      await packageRef.update({
        'likedBy': packageLikedBy,
        'likesCount': currentLikesCount,
      });

      // 로컬 상태 업데이트
      final packageIndex = _packages.indexWhere((p) => p.id == packageId);
      if (packageIndex != -1) {
        final package = _packages[packageIndex];
        package.likedBy = packageLikedBy;
        package.likesCount = currentLikesCount;
      }

      notifyListeners();
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }
  // 패키지 목록 로드
  Future<void> loadPackages() async {
    try {
      _isLoading = true;
      notifyListeners();

      _packages = await _repository.getPackages();

      // 현재 로그인한 사용자가 있다면 찜 상태 업데이트
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await loadLikedPackages(currentUser.uid);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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

  // 패키지 삭제
  Future<void> deletePackage(String packageId) async {
    try {
      await _repository.deletePackage(packageId);
      await loadPackages();
      notifyListeners();
    } catch (e) {
      print('Error deleting package: $e');
      rethrow;
    }
  }

  // 패키지 업데이트
  Future<void> updatePackage(TravelPackage package) async {
    try {
      await _repository.updatePackage(package);
      await loadPackages();
      notifyListeners();
    } catch (e) {
      print('Error updating package: $e');
      rethrow;
    }
  }

  Future<void> loadLikedPackages(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final likedPackages = List<String>.from(userDoc.data()!['likedPackages'] ?? []);
      _likedPackageIds = Set.from(likedPackages);

      // 로컬 패키지 상태 업데이트
      for (var package in _packages) {
        package.likedBy.clear(); // 기존 상태 초기화
        if (_likedPackageIds.contains(package.id)) {
          package.likedBy.add(userId);
        }
      }

      notifyListeners();
    } catch (e) {
      print('Error loading liked packages: $e');
    }
  }

  Future<void> refreshPackage(String packageId) async {
    try {
      final snapshot = await _firestore.collection('packages').doc(packageId).get();
      if (snapshot.exists) {
        final index = _packages.indexWhere((p) => p.id == packageId);
        if (index != -1) {
          final data = snapshot.data()!;
          _packages[index] = TravelPackage.fromJson({
            'id': snapshot.id,
            ...data,
          });
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error refreshing package: $e');
    }
  }

  List<TravelPackage> getLikedPackages() {
    return _packages.where((package) => _likedPackageIds.contains(package.id)).toList();
  }

  // 특정 패키지 검색
  TravelPackage? getPackageById(String id) {
    try {
      return _packages.firstWhere((package) => package.id == id);
    } catch (e) {
      return null;
    }
  }

  // 패키지 좋아요 상태 확인
  bool isPackageLiked(String packageId) {
    return _likedPackageIds.contains(packageId);
  }

  // 에러 상태 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 찜 목록 초기화
  void clearLikedPackages() {
    _likedPackageIds.clear();
    for (var package in _packages) {
      package.likedBy.clear();
    }
    notifyListeners();
  }

  // 최신 패키지 5개 조회
  List<TravelPackage> get recentPackages {
    return _packages.take(5).toList();
  }
}