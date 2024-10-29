class TravelPackage {
  final String id;
  final String title;
  final String region;
  final double price;
  final String description;
  final String? mainImage;  // 메인 이미지 URL
  final List<String> descriptionImages;  // 설명 이미지 URL 리스트

  TravelPackage({
    required this.id,
    required this.title,
    required this.region,
    required this.price,
    required this.description,
    this.mainImage,
    this.descriptionImages = const [],
  });
}
