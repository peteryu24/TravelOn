import '../../domain/entities/tourism_density.dart';

class TourismDensityModel extends TourismDensity {
  TourismDensityModel({
    required super.name,
    required super.density,
    required super.location,
    required super.category,
  });

  factory TourismDensityModel.fromJson(Map<String, dynamic> json) {
    return TourismDensityModel(
      name: json['tAtsNm'] ?? '',
      density: double.parse(json['cnctrRate'] ?? '0'),
      location: json['location'] ?? json['areaNm'] ?? '',
      category: _determineCategory(json['tAtsNm'] ?? ''),
    );
  }

  static String _determineCategory(String name) {
    if (name.contains('궁') || name.contains('문')) return '고궁';
    if (name.contains('해수욕장') || name.contains('해변')) return '해변';
    if (name.contains('산') || name.contains('공원')) return '자연';
    if (name.contains('타워') || name.contains('전망대')) return '전망대';
    return '관광지';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'density': density,
      'location': location,
      'category': category,
    };
  }
}
