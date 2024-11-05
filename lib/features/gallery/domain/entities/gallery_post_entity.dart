import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryPost {
  final String id;
  final String userId;
  final String username;
  final String? userProfileUrl;
  final String imageUrl;
  final String location;
  final String description;
  final DateTime createdAt;
  final List<String> likedBy;
  final int likeCount;
  final List<String> comments;

  GalleryPost({
    required this.id,
    required this.userId,
    required this.username,
    this.userProfileUrl,
    required this.imageUrl,
    required this.location,
    required this.description,
    required this.createdAt,
    required this.likedBy,
    required this.likeCount,
    required this.comments,
  });

  factory GalleryPost.fromJson(Map<String, dynamic> json) {
    return GalleryPost(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      userProfileUrl: json['userProfileUrl'] as String?,
      imageUrl: json['imageUrl'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      likedBy: List<String>.from(json['likedBy'] ?? []),
      likeCount: json['likeCount'] as int? ?? 0,
      comments: List<String>.from(json['comments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'userProfileUrl': userProfileUrl,
      'imageUrl': imageUrl,
      'location': location,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedBy': likedBy,
      'likeCount': likeCount,
      'comments': comments,
    };
  }
}
