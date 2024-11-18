import 'package:flutter/material.dart';
import '../../domain/repositories/regional_repository.dart';
import '../../domain/entities/regional_spot.dart';
import '../../../../core/error/failures.dart';

class RegionalProvider extends ChangeNotifier {
  final RegionalRepository repository;

  RegionalProvider(this.repository);

  List<RegionalSpot> _spots = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCity;
  String? _selectedDistrict;
  String _selectedCategory = '전체';

  // Getters
  List<RegionalSpot> get spots => _spots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCity => _selectedCity;
  String? get selectedDistrict => _selectedDistrict;
  String get selectedCategory => _selectedCategory;

  // 시/도 선택
  void setCity(String? city) {
    _selectedCity = city;
    _selectedDistrict = null;
    _spots = [];

    // 전체 선택시 바로 데이터 fetch
    if (city == '전체') {
      fetchRegionalSpots();
    }
    notifyListeners();
  }

  // 시/군/구 선택
  void setDistrict(String? district) {
    _selectedDistrict = district;
    if (district != null) {
      fetchRegionalSpots();
    }
    notifyListeners();
  }

  // 카테고리 선택
  void setCategory(String category) {
    _selectedCategory = category;
    if (_selectedCity != null && _selectedDistrict != null) {
      fetchRegionalSpots();
    }
    notifyListeners();
  }

  // 데이터 fetch
  Future<void> fetchRegionalSpots() async {
    if (_selectedCity == null || _selectedDistrict == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final spots = await repository.getRegionalSpots(
        cityCode: getCityCode(_selectedCity!),
        districtCode: getDistrictCode(_selectedDistrict!),
        category: _selectedCategory == '전체' ? null : _selectedCategory,
      );

      _spots = spots;
      _error = null;
    } catch (e) {
      _error = e is ServerFailure ? e.message : '데이터를 불러오는데 실패했습니다.';
      _spots = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods for codes
  String getCityCode(String city) {
    if (city == '전체') return 'all';

    const Map<String, String> cities = {
      '서울특별시': '11',
      '부산광역시': '26',
      '대구광역시': '27',
      '인천광역시': '28',
      '광주광역시': '29',
      '대전광역시': '30',
      '울산광역시': '31',
      '세종특별자치시': '36',
      '경기도': '41',
      '강원특별자치도': '42',
      '충청북도': '43',
      '충청남도': '44',
      '전라북도': '45',
      '전라남도': '46',
      '경상북도': '47',
      '경상남도': '48',
      '제주특별자치도': '50'
    };
    return cities[city] ?? '';
  }

  String getDistrictCode(String district) {
    const Map<String, Map<String, String>> districts = {
      '11': {
        '종로구': '11110',
        '중구': '11140',
        '용산구': '11170',
        '성동구': '11200',
        '광진구': '11215',
        '동대문구': '11230',
        '중랑구': '11260',
        '성북구': '11290',
        '강북구': '11305',
        '도봉구': '11320',
        '노원구': '11350',
        '은평구': '11380',
        '서대문구': '11410',
        '마포구': '11440',
        '양천구': '11470',
        '강서구': '11500',
        '구로구': '11530',
        '금천구': '11545',
        '영등포구': '11560',
        '동작구': '11590',
        '관악구': '11620',
        '서초구': '11650',
        '강남구': '11680',
        '송파구': '11710',
        '강동구': '11740',
      },
      '26': {
        '중구': '26110',
        '서구': '26140',
        '동구': '26170',
        '영도구': '26200',
        '부산진구': '26230',
        '동래구': '26260',
        '남구': '26290',
        '북구': '26320',
        '해운대구': '26350',
        '사하구': '26380',
        '금정구': '26410',
        '강서구': '26440',
        '연제구': '26470',
        '수영구': '26500',
        '사상구': '26530',
        '기장군': '26710',
      },
      // ... 다른 도시의 구/군 코드도 추가
    };

    final cityCode = getCityCode(_selectedCity!);
    final districtCodes = districts[cityCode];
    return districtCodes?[district] ?? '';
  }
}
