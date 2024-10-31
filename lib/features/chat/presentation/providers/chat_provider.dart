import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_on_final/features/chat/data/models/message_model.dart';
import 'package:travel_on_final/features/chat/domain/entities/message_entity.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<MessageEntity> _messages = [];
  List<MessageEntity> get messages => _messages;

  // 메시지 수신 및 구독
  void startListeningToMessages(String chatId) {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      _messages = querySnapshot.docs.map((doc) => MessageModel.fromDocument(doc).toEntity()).toList();
      notifyListeners();
    });
  }

  // 채팅방 생성 확인 및 생성
  Future<void> _ensureChatRoomExists(String chatId, BuildContext context, String otherUserId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    DocumentReference chatRef = _firestore.collection('chats').doc(chatId);
    DocumentSnapshot chatSnapshot = await chatRef.get();

    if (!chatSnapshot.exists && authProvider.currentUser != null) {
      String otherUserName = await _getOtherUserNickname(otherUserId);
      String otherUserProfileImage = await _getOtherUserProfileImage(otherUserId);

      await chatRef.set({
        'participants': [authProvider.currentUser!.id, otherUserId],
        'lastActivityTime': Timestamp.now(),
        'lastMessage': '',
        'usernames': {
          authProvider.currentUser!.id: authProvider.currentUser!.name,
          otherUserId: otherUserName,
        },
        'userProfileImages': {
          authProvider.currentUser!.id: authProvider.currentUser!.profileImageUrl,
          otherUserId: otherUserProfileImage,
        }
      });
    }
  }

  // 텍스트 및 이미지 메시지 전송
  Future<void> sendMessageToChat({
    required String chatId,
    required String text,
    required String otherUserId,
    XFile? imageFile,
    required BuildContext context,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    await _ensureChatRoomExists(chatId, context, otherUserId);
    final chatRef = _firestore.collection('chats').doc(chatId);

    String imageUrl = '';
    if (imageFile != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = _storage.ref().child('chat_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(imageFile.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      imageUrl = await taskSnapshot.ref.getDownloadURL();
    }

    await chatRef.collection('messages').add({
      'text': imageFile != null ? '[Image]' : text,
      'uId': authProvider.currentUser!.id,
      'username': authProvider.currentUser!.name,
      'createdAt': Timestamp.now(),
      if (imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      'profileImageUrl': authProvider.currentUser!.profileImageUrl,
    });

    await chatRef.update({
      'lastActivityTime': Timestamp.now(),
      'lastMessage': imageFile != null ? '[Image]' : text,
    });

    notifyListeners();
  }


  // Firestore에서 사용자 닉네임 가져오기
  Future<String> _getOtherUserNickname(String uid) async {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(uid).get();
    return userSnapshot.exists ? userSnapshot['nickname'] ?? 'Unknown User' : 'Unknown User';
  }

  // Firestore에서 사용자 프로필 이미지 가져오기
  Future<String> _getOtherUserProfileImage(String uid) async {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(uid).get();
    return userSnapshot.exists ? userSnapshot['userProfileImage'] ?? '' : '';
  }
}