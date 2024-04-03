import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagingScreen extends StatefulWidget {
  final String currentUserEmail;
  final String recipientEmail;

  MessagingScreen({
    required this.currentUserEmail,
    required this.recipientEmail,
  });

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _messagesCollection;

  @override
  void initState() {
    super.initState();
    _initializeMessagesCollection();
  }

  void _initializeMessagesCollection() {
    String chatRoomId = _getChatRoomId(widget.currentUserEmail, widget.recipientEmail);
    _messagesCollection = _firestore.collection('chatrooms').doc(chatRoomId).collection('messages');
  }

  String _getChatRoomId(String email1, String email2) {
    return email1.compareTo(email2) < 0
        ? '${email1}_${email2}'
        : '${email2}_${email1}';
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      await _messagesCollection?.add({
        'sender': widget.currentUserEmail,
        'recipient': widget.recipientEmail,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }

  Widget _buildMessageBubble(String message, bool isSentMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: isSentMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.blue, // Set the background color to blue for both sent and received messages
            borderRadius: isSentMessage
                ? BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
          ),
          child: Text(
            message,
            style: TextStyle(
              color: Colors.white, // Set the text color to white for better contrast
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientEmail),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messagesCollection?.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    String sender = messageData['sender'];
                    String message = messageData['message'];
                    bool isCurrentUser = sender == widget.currentUserEmail;

                    return _buildMessageBubble(message, isCurrentUser);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
