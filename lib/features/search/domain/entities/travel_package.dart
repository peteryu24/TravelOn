import 'package:travel_on_final/features/map/domain/entities/travel_point.dart';

class TravelPackage {
  final String id;
  final String title;      // 한국어 (기본)
  final String titleEn;    // 영어
  final String titleJa;    // 일본어
  final String titleZh;    // 중국어
  final String description;      // 한국어 (기본)
  final String descriptionEn;    // 영어
  final String descriptionJa;    // 일본어
  final String descriptionZh;    // 중국어
  final String region;
  final double price;
  final String? mainImage;
  final List<String> descriptionImages;
  final String guideName;
  final String guideId;
  final int minParticipants;
  final int maxParticipants;
  final int nights;
  final int totalDays;
  final List<int> departureDays;
  List<String> likedBy;
  int likesCount;
  final double averageRating;
  final int reviewCount;
  final List<TravelPoint> routePoints;

  String getTitle(String langCode) {
    switch(langCode) {
      case 'en': return titleEn.isNotEmpty ? titleEn : title;
      case 'ja': return titleJa.isNotEmpty ? titleJa : title;
      case 'zh': return titleZh.isNotEmpty ? titleZh : title;
      default: return title;
    }
  }

  String getDescription(String langCode) {
    switch(langCode) {
      case 'en': return descriptionEn.isNotEmpty ? descriptionEn : description;
      case 'ja': return descriptionJa.isNotEmpty ? descriptionJa : description;
      case 'zh': return descriptionZh.isNotEmpty ? descriptionZh : description;
      default: return description;
    }
  }

  bool hasTranslation(String langCode) {
    switch(langCode) {
      case 'en':
        return titleEn.isNotEmpty && descriptionEn.isNotEmpty;
      case 'ja':
        return titleJa.isNotEmpty && descriptionJa.isNotEmpty;
      case 'zh':
        return titleZh.isNotEmpty && descriptionZh.isNotEmpty;
      default:
        return true; // 한국어는 항상 있음
    }
  }

  String getPriceSymbol(String langCode) {
    switch(langCode) {
      case 'ja': return '￥';
      case 'zh': return '¥';
      default: return '₩';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TravelPackage &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  // 디버깅을 위한 toString
  @override
  String toString() => 'TravelPackage('
      'id: $id, '
      'title: $title, '
      'price: $price, '
      'guideName: $guideName)';

  TravelPackage({
    required this.id,
    required this.title,
    this.titleEn = '',
    this.titleJa = '',
    this.titleZh = '',
    required this.description,
    this.descriptionEn = '',
    this.descriptionJa = '',
    this.descriptionZh = '',
    required this.region,
    required this.price,
    this.mainImage,
    this.descriptionImages = const [],
    required this.guideName,
    required this.guideId,
    required this.minParticipants,
    required this.maxParticipants,
    required this.nights,
    var totalDays,
    required this.departureDays,
    List<String>? likedBy,
    this.likesCount = 0,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.routePoints = const [],
  })  : this.totalDays = totalDays ?? nights + 1,
        this.likedBy = likedBy ?? [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'titleEn': titleEn,
    'titleJa': titleJa,
    'titleZh': titleZh,
    'region': region,
    'price': price,
    'description': description,
    'descriptionEn': descriptionEn,
    'descriptionJa': descriptionJa,
    'descriptionZh': descriptionZh,
    'mainImage': mainImage,
    'descriptionImages': descriptionImages,
    'guideName': guideName,
    'guideId': guideId,
    'minParticipants': minParticipants,
    'maxParticipants': maxParticipants,
    'nights': nights,
    'totalDays': totalDays,
    'departureDays': departureDays,
    'likedBy': likedBy,
    'likesCount': likesCount,
    'averageRating': averageRating,
    'reviewCount': reviewCount,
    'routePoints': routePoints.map((point) => point.toJson()).toList(),
  };

  factory TravelPackage.fromJson(Map<String, dynamic> json) => TravelPackage(
    id: json['id'] as String,
    title: json['title'] as String,
    titleEn: json['titleEn'] as String? ?? '',
    titleJa: json['titleJa'] as String? ?? '',
    titleZh: json['titleZh'] as String? ?? '',
    description: json['description'] as String,
    descriptionEn: json['descriptionEn'] as String? ?? '',
    descriptionJa: json['descriptionJa'] as String? ?? '',
    descriptionZh: json['descriptionZh'] as String? ?? '',
    price: (json['price'] as num).toDouble(),
    region: json['region'] as String,
    mainImage: json['mainImage'] as String?,
    descriptionImages: List<String>.from(json['descriptionImages'] ?? []),
    guideName: json['guideName'] as String,
    guideId: json['guideId'] as String,
    minParticipants: (json['minParticipants'] as num?)?.toInt() ?? 4,
    maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 8,
    nights: (json['nights'] as num?)?.toInt() ?? 0,
    totalDays: (json['totalDays'] as num?)?.toInt() ?? 0,
    departureDays: List<int>.from(json['departureDays'] ?? []),
    likedBy: List<String>.from(json['likedBy'] ?? []),
    likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
    averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    routePoints: (json['routePoints'] as List<dynamic>?)
        ?.map((point) => TravelPoint.fromJson(point as Map<String, dynamic>))
        .toList() ?? [],
  );

  TravelPackage copyWith({
    String? id,
    String? title,
    String? titleEn,
    String? titleJa,
    String? titleZh,
    String? description,
    String? descriptionEn,
    String? descriptionJa,
    String? descriptionZh,
    List<String>? likedBy,
    int? likesCount,
    double? averageRating,
    int? reviewCount,
    List<TravelPoint>? routePoints,
    int? totalDays,
  }) {
    return TravelPackage(
      id: id ?? this.id,  // 이 부분 수정
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      titleJa: titleJa ?? this.titleJa,
      titleZh: titleZh ?? this.titleZh,
      region: region,
      price: price,
      description: description ?? this.description,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionJa: descriptionJa ?? this.descriptionJa,
      descriptionZh: descriptionZh ?? this.descriptionZh,
      mainImage: mainImage,
      descriptionImages: descriptionImages,
      guideName: guideName,
      guideId: guideId,
      minParticipants: minParticipants,
      maxParticipants: maxParticipants,
      nights: nights,
      totalDays: totalDays ?? this.totalDays,
      departureDays: departureDays,
      likedBy: likedBy ?? List<String>.from(this.likedBy),
      likesCount: likesCount ?? this.likesCount,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      routePoints: routePoints ?? List<TravelPoint>.from(this.routePoints),
    );
  }
}