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
      density: double.tryParse(json['cnctrRate'] ?? '0') ?? 0.0,
      location: json['areaNm'] ?? '',
      category: json['signguNm'] ?? '',
    );
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
