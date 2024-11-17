import 'package:travel_on_final/features/map/domain/entities/travel_point.dart';

class TravelPackage {
  final String id;
  final String title;
  final String description;
  final double price;
  final String region;
  final String? mainImage;
  final List<String> descriptionImages;
  final String guideName;
  final String guideId;
  final int minParticipants;
  final int maxParticipants;
  final int nights;
  final List<int> departureDays;
  final int totalDays;
  final List<String> likedBy;
  final int likesCount;
  final double rating;
  final double averageRating;
  final int reviewCount;
  final List<TravelPoint> routePoints;

  TravelPackage({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.region,
    this.mainImage,
    required this.descriptionImages,
    required this.guideName,
    required this.guideId,
    required this.minParticipants,
    required this.maxParticipants,
    required this.nights,
    required this.departureDays,
    required this.totalDays,
    List<String>? likedBy,
    int? likesCount,
    double? rating,
    double? averageRating,
    int? reviewCount,
    required this.routePoints,
  })  : likedBy = likedBy ?? [],
        likesCount = likesCount ?? 0,
        rating = rating ?? 0.0,
        averageRating = averageRating ?? 0.0,
        reviewCount = reviewCount ?? 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'region': region,
        'price': price,
        'description': description,
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
        'rating': rating,
        'averageRating': averageRating,
        'reviewCount': reviewCount,
        'routePoints': routePoints.map((point) => point.toJson()).toList(),
      };

  factory TravelPackage.fromJson(Map<String, dynamic> json) => TravelPackage(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
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
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        routePoints: (json['routePoints'] as List<dynamic>?)
                ?.map((point) =>
                    TravelPoint.fromJson(point as Map<String, dynamic>))
                .toList() ??
            [],
      );

  TravelPackage copyWith({
    List<String>? likedBy,
    int? likesCount,
    double? rating,
    double? averageRating,
    int? reviewCount,
    List<TravelPoint>? routePoints,
    int? totalDays,
  }) {
    return TravelPackage(
      id: id,
      title: title,
      region: region,
      price: price,
      description: description,
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
      rating: rating ?? this.rating,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      routePoints: routePoints ?? List<TravelPoint>.from(this.routePoints),
    );
  }
}
