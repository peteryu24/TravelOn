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
  });

  factory TravelPackage.fromJson(Map<String, dynamic> json) {


    final minPart = json['minParticipants'];
    print('minParticipants from JSON: $minPart (type: ${minPart.runtimeType})');


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
      minParticipants: (json['minParticipants'] as num).toInt(),
      maxParticipants: (json['maxParticipants'] as num).toInt(),
      nights: (json['nights'] as num).toInt(),
      departureDays: List<int>.from(json['departureDays'] ?? []),
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
  };
}