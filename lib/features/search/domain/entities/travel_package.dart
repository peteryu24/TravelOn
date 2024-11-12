class TravelPackage {
  final String id;
  final String title;
  final String region;
  final double price;
  final String description;
  final String? mainImage;
  final List<String> descriptionImages;
  final String guideName;
  final String guideId;
  final int minParticipants;
  final int maxParticipants;
  final int nights;
  final List<int> departureDays;
  List<String> likedBy;
  int likesCount;
  final double averageRating;
  final int reviewCount;


  TravelPackage({
    required this.id,
    required this.title,
    required this.region,
    required this.price,
    required this.description,
    this.mainImage,
    this.descriptionImages = const [],
    required this.guideName,
    required this.guideId,
    required this.minParticipants,
    required this.maxParticipants,
    required this.nights,
    required this.departureDays,
    List<String>? likedBy,
    this.likesCount = 0,
    this.averageRating = 0.0,
    this.reviewCount = 0,
  }) : likedBy = likedBy ?? []; // 새로운 리스트로 초기화

  factory TravelPackage.fromJson(Map<String, dynamic> json) {
    return TravelPackage(
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
      nights: (json['nights'] as num).toInt(),
      departureDays: List<int>.from(json['departureDays'] ?? []),
      likedBy: List<String>.from(json['likedBy'] ?? []),  // 수정 가능한 리스트로 변환
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }

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
    'departureDays': departureDays,
    'likedBy': likedBy,
    'likesCount': likesCount,
    'averageRating': averageRating,
    'reviewCount': reviewCount,
  };

  // 복사본 생성 메서드 추가
  TravelPackage copyWith({
    List<String>? likedBy,
    int? likesCount,
    double? averageRating,
    int? reviewCount,
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
      departureDays: departureDays,
      likedBy: likedBy ?? List<String>.from(this.likedBy),
      likesCount: likesCount ?? this.likesCount,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}