import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:travel_on_final/features/chat/domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe && message.profileImageUrl != null)
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(message.profileImageUrl!),
            radius: 15,
          ),
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          decoration: BoxDecoration(
            color: isMe ? Colors.blue.shade100 : Colors.blueAccent,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: message.imageUrl != null && message.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: message.imageUrl!,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )
              : Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.black : Colors.white,
                  ),
                ),
        ),
      ],
    );
  }
}

