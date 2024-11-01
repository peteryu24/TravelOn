import 'package:travel_on_final/features/auth/domain/entities/user_entity.dart';

class UserModel extends User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final bool isGuide;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.isGuide = false,
  }) : super(id: id, name: name, email: email);

  // JSON 데이터를 UserModel 객체로 변환하는 fromJson 메서드
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      isGuide: json['isGuide'] as bool? ?? false,
    );
  }

  // UserModel 객체를 JSON 형식으로 변환하는 toJson 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'isGuide': isGuide,
    };
  }
}
