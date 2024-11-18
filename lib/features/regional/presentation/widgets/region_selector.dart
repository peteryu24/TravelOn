import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/regional_provider.dart';

class RegionSelector extends StatelessWidget {
  const RegionSelector({super.key});

  static const Map<String, String> cities = {
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

  static const Map<String, Map<String, String>> districts = {
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
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<RegionalProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '시/도 선택',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                value: provider.selectedCity,
                items: cities.keys.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: provider.setCity,
              ),
              const SizedBox(height: 16),
              if (provider.selectedCity != null &&
                  provider.selectedCity != '전체')
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: '시/군/구 선택',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: provider.selectedDistrict,
                  items: districts[cities[provider.selectedCity]]
                      ?.keys
                      .map((String district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: provider.setDistrict,
                ),
            ],
          ),
        );
      },
    );
  }
}
