import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: true,
          title: const Text('채팅 목록'),
        ),
        body: const Center(child: Text('로그인이 필요합니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: const Text('채팅 목록'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('lastActivityTime', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatDocs = chatSnapshot.data!.docs.where((doc) {
            final participants = List<String>.from(doc['participants']);
            return participants.contains(authProvider.currentUser!.id);
          }).toList();

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;
              final chatId = chatDocs[index].id;
              final otherUserId =
                  authProvider.currentUser!.id == chatData['participants'][0]
                      ? chatData['participants'][1]
                      : chatData['participants'][0];

              chatProvider.updateOtherUserInfo(chatId, otherUserId);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: chatData['userProfileImages'] != null &&
                          chatData['userProfileImages'][otherUserId] != null &&
                          chatData['userProfileImages'][otherUserId].isNotEmpty
                      ? NetworkImage(chatData['userProfileImages'][otherUserId])
                      : const AssetImage('assets/images/default_profile.png')
                          as ImageProvider,
                ),
                title: Text(
                  chatData['usernames'][otherUserId]?.substring(
                          0,
                          chatData['usernames'][otherUserId].length > 15
                              ? 15
                              : chatData['usernames'][otherUserId].length) ??
                      'Unknown User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  (chatData['lastMessage'] != null &&
                          chatData['lastMessage'].length > 65)
                      ? '${chatData['lastMessage'].substring(0, 65)}...'
                      : chatData['lastMessage'] ?? '',
                ),
                onTap: () {
                  chatProvider.startListeningToMessages(chatId);
                  GoRouter.of(context).push('/chat/$chatId');
                },
              );
            },
          );
        },
      ),
    );
  }
}
