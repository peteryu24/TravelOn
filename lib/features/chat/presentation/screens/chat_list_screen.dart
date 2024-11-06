import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/auth/presentation/providers/auth_provider.dart';
import 'package:travel_on_final/features/chat/presentation/providers/chat_provider.dart';

class ChatListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.currentUser == null) {
      return Scaffold(
        body: Center(child: Text('로그인이 필요합니다')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("대화 목록")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('lastActivityTime', descending: true)
            .snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final chatDocs = chatSnapshot.data!.docs.where((doc) {
            final participants = List<String>.from(doc['participants']);
            return participants.contains(authProvider.currentUser!.id);
          }).toList();

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (ctx, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: chatData['userProfileImages'] != null &&
                          chatData['userProfileImages'][authProvider.currentUser!.id == chatData['participants'][0]
                              ? chatData['participants'][1]
                              : chatData['participants'][0]] != null &&
                          chatData['userProfileImages'][authProvider.currentUser!.id == chatData['participants'][0]
                              ? chatData['participants'][1]
                              : chatData['participants'][0]].isNotEmpty
                      ? NetworkImage(chatData['userProfileImages'][authProvider.currentUser!.id == chatData['participants'][0]
                          ? chatData['participants'][1]
                          : chatData['participants'][0]])
                      : AssetImage('assets/images/default_profile.png') as ImageProvider,
                ),
                title: Text(
                  chatData['usernames'][authProvider.currentUser!.id == chatData['participants'][0]
                          ? chatData['participants'][1]
                          : chatData['participants'][0]]
                      ?.substring(
                          0,
                          chatData['usernames'][authProvider.currentUser!.id == chatData['participants'][0]
                                      ? chatData['participants'][1]
                                      : chatData['participants'][0]]
                                  .length >
                              15
                          ? 15
                          : chatData['usernames'][authProvider.currentUser!.id == chatData['participants'][0]
                                  ? chatData['participants'][1]
                                  : chatData['participants'][0]]
                              .length) ??
                      'Unknown User',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  (chatData['lastMessage'] != null && chatData['lastMessage'].length > 65)
                      ? '${chatData['lastMessage'].substring(0, 65)}...'
                      : chatData['lastMessage'] ?? '',
                ),
                onTap: () {
                  Provider.of<ChatProvider>(context, listen: false).startListeningToMessages(chatDocs[index].id);
                  GoRouter.of(context).push('/chat/${chatDocs[index].id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
