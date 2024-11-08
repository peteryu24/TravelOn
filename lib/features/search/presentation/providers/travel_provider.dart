import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_on_final/features/auth/data/models/user_model.dart';
import '../../domain/repositories/travel_repositories.dart';
import '../../domain/entities/travel_package.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

enum SortOption {
  latest,        // 최신순
  priceHigh,     // 가격높은순
  priceLow,      // 가격낮은순
  popular,       // 인기순
  highRating,    // 별점높은순
  mostReviews    // 리뷰많은순
}

class TravelProvider extends ChangeNotifier {
  final TravelRepository _repository;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // 추가
  List<TravelPackage> _packages = [];
  Set<String> _likedPackageIds = {}; // 찜한 패키지 ID 목록
  String _selectedRegion = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  SortOption _currentSort = SortOption.latest;
  SortOption get currentSort => _currentSort;



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

  Future<void> toggleLikePackage(String packageId, String userId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final packageRef = _firestore.collection('packages').doc(packageId);

      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final packageDoc = await transaction.get(packageRef);

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
          userLikedPackages.remove(packageId);
          packageLikedBy.remove(userId);
          currentLikesCount = math.max(0, currentLikesCount - 1);
          _likedPackageIds.remove(packageId);
        } else {
          userLikedPackages.add(packageId);
          packageLikedBy.add(userId);
          currentLikesCount++;
          _likedPackageIds.add(packageId);
        }

        // Firestore 업데이트
        transaction.update(userRef, {'likedPackages': userLikedPackages});
        transaction.update(packageRef, {
          'likedBy': packageLikedBy,
          'likesCount': currentLikesCount,
        });

        // 로컬 상태 업데이트
        final packageIndex = _packages.indexWhere((p) => p.id == packageId);
        if (packageIndex != -1) {
          _packages[packageIndex] = _packages[packageIndex].copyWith(
            likedBy: packageLikedBy,
            likesCount: currentLikesCount,
          );
        }
      });

      // 정렬이 필요한 경우에만 정렬 수행
      if (_currentSort == SortOption.popular) {
        _packages.sort((a, b) => b.likesCount.compareTo(a.likesCount));
      }

      notifyListeners();
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // 좋아요 수에 따른 정렬 메서드 추가
  void _sortPackagesByLikes() {
    _packages.sort((a, b) => b.likesCount.compareTo(a.likesCount));
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

      // 패키지 리스트 정렬
      _sortPackagesByLikes();

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

      final likedPackages =
          List<String>.from(userDoc.data()!['likedPackages'] ?? []);
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
      final snapshot =
          await _firestore.collection('packages').doc(packageId).get();
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
    return _packages
        .where((package) => _likedPackageIds.contains(package.id))
        .toList();
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

  // 인기 패키지 getter - 찜(좋아요) 수 기준 상위 5개
  List<TravelPackage> getPopularPackages() {
    // 패키지 리스트를 복사하여 정렬 (원본 리스트는 변경하지 않음)
    final sortedPackages = List<TravelPackage>.from(_packages);

    // 좋아요 수를 기준으로 정렬
    sortedPackages.sort((a, b) => b.likesCount.compareTo(a.likesCount));

    // 상위 5개만 반환
    return sortedPackages.take(5).toList();
  }

  List<TravelPackage> get sortedPackages {  // 이름을 sortedPackages로 변경
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

    // 정렬
    switch (_currentSort) {
      case SortOption.latest:
        filteredPackages.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortOption.priceHigh:
        filteredPackages.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.priceLow:
        filteredPackages.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.popular:
        filteredPackages.sort((a, b) => b.likesCount.compareTo(a.likesCount));
        break;
      case SortOption.highRating:
        filteredPackages.sort((a, b) => b.averageRating.compareTo(a.averageRating));
        break;
      case SortOption.mostReviews:
        filteredPackages.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }

    return filteredPackages;
  }

  // 정렬 옵션 변경 메서드
  void sortPackages(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }

  Future<bool> checkPackageExists(String packageId) async {
    try {
      final doc = await _firestore.collection('packages').doc(packageId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking package existence: $e');
      return false;
    }
  }
}
