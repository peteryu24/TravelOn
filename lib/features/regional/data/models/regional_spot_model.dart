import '../../domain/entities/regional_spot.dart';

class RegionalSpotModel extends RegionalSpot {
  const RegionalSpotModel({
    required super.name,
    required super.address,
    required super.category,
    required super.rank,
    required super.cityCode,
    required super.districtCode,
    required super.baseMonth,
  });

  factory RegionalSpotModel.fromJson(Map<String, dynamic> json) {
    print('Parsing spot: ${json['rlteTatsNm']}'); // 디버그용
    return RegionalSpotModel(
      name: json['rlteTatsNm'] ?? '',
      address: json['rlteBsicAdres'] ?? '',
      category: json['rlteCtgryLclsNm'] ?? '',
      rank: int.tryParse(json['rlteRank']?.toString() ?? '0') ?? 0,
      cityCode: json['areaCd'] ?? '',
      districtCode: json['signguCd'] ?? '',
      baseMonth: json['baseYm'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rlteTatsNm': name,
      'rlteBsicAdres': address,
      'rlteCtgryLclsNm': category,
      'rlteRank': rank.toString(),
      'areaCd': cityCode,
      'signguCd': districtCode,
      'baseYm': baseMonth,
    };
  }
}
