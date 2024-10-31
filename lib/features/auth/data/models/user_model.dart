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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      isGuide: json['isGuide'] as bool? ?? false,
    );
  }

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
