import 'package:cloud_firestore/cloud_firestore.dart';

class MessageEntity {
  final String text;
  final String uId;
  final Timestamp createdAt;
  final String? profileImageUrl;
  final String? imageUrl;
  Map<String, dynamic>? sharedUser;

  MessageEntity({
    required this.text,
    required this.uId,
    required this.createdAt,
    this.profileImageUrl,
    this.imageUrl,
    this.sharedUser,
  });
}
