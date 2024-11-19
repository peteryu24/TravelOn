import 'package:easy_localization/easy_localization.dart';
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
    if (name.contains('궁') || name.contains('문'))
      return 'tourist_category.palace'.tr();
    if (name.contains('해수욕장') || name.contains('해변'))
      return 'tourist_category.beach'.tr();
    if (name.contains('산') || name.contains('공원'))
      return 'tourist_category.nature'.tr();
    if (name.contains('타워') || name.contains('전망대'))
      return 'tourist_category.observatory'.tr();
    return 'tourist_category.attraction'.tr();
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