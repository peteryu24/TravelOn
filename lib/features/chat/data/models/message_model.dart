import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/chat/domain/entities/message_entity.dart';

class MessageModel {
  final String id;
  final String text;
  final String uId;
  final Timestamp createdAt;
  String? profileImageUrl;
  String? imageUrl;

  MessageModel({
    required this.id,
    required this.text,
    required this.uId,
    required this.createdAt,
    this.profileImageUrl,
    this.imageUrl,
  });

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return MessageModel(
      id: doc.id,
      text: data?['text'] ?? '',
      uId: data?['uId'] ?? '',
      createdAt: data?['createdAt'] ?? Timestamp.now(),
      profileImageUrl: data?['profileImageUrl'],
      imageUrl: data?['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'uId': uId,
      'createdAt': createdAt,
      'profileImageUrl': profileImageUrl,
      'imageUrl': imageUrl,
    };
  }

  MessageEntity toEntity() {
    return MessageEntity(
      text: text,
      uId: uId,
      createdAt: createdAt,
      profileImageUrl: profileImageUrl,
      imageUrl: imageUrl,
    );
  }
}
