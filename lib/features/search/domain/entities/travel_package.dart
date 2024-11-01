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
  final int maxParticipants;
  final int nights;           // 박 수
  final List<int> departureDays;  // 출발 가능 요일 (1: 월요일 ~ 7: 일요일)

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
    required this.maxParticipants,
    required this.nights,
    required this.departureDays,
  });
}