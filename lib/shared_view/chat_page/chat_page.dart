import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/services/firebase/chats_firestore.dart';
import 'package:graduation_project/services/firebase/user_auth.dart';
import 'package:graduation_project/services/firebase/users_firestore.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      this.personUID,
      this.studentID,
      this.instructorEmail,
      this.firstName,
      this.lastName,
      this.chats});

  final String? personUID;
  final String? studentID;
  final String? instructorEmail;
  final String? firstName;
  final String? lastName;
  final List<dynamic>? chats;
  static const String routeName = 'Chat Page';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    final UserAuth auth = Provider.of<UserAuth>(context);
    final ChatsFirestore chat = Provider.of<ChatsFirestore>(context);
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final personUID = args?['personUID'];
    final firstName = args?['firstName'];
    final lastName = args?['lastName'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          firstName + ' ' + lastName ?? 'aa',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: auth.currentUser.uid.compareTo(personUID) < 0
                    ? chat.getMessagesInChatStream(
                        auth.currentUser.uid + personUID)
                    : chat.getMessagesInChatStream(
                        personUID + auth.currentUser.uid),
                builder: (context, snapshot) {
                  auth.currentUser.uid.compareTo(personUID) < 0
                      ? chat.markMessagesAsRead(
                          auth.currentUser.uid + personUID,
                          auth.currentUser.uid)
                      : chat.markMessagesAsRead(
                          personUID + auth.currentUser.uid,
                          auth.currentUser.uid);
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      final messages = snapshot.data;
                      return ListView(
                        reverse: true,
                        children: messages?.map((doc) {
                              final message =
                                  doc.data() as Map<String, dynamic>;
                              final isMyMessage =
                                  message['senderID'] == auth.currentUser.uid;
                              return ChatBubble(
                                text: message['messageText'],
                                isMyMessage: isMyMessage,
                              );
                            }).toList() ??
                            [],
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading messages'),
                      );
                    }
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    final UserAuth auth = Provider.of<UserAuth>(context);
    final ChatsFirestore chat = Provider.of<ChatsFirestore>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final personUID = args?['personUID'];
    final studentID = args?['studentID'];
    final instructorEmail = args?['instructorEmail'];
    final chats = args?['chats'];
    final TextEditingController messageController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
              ),
              controller: messageController,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              if (messageController.text.isNotEmpty) {
                final messageText = messageController.text;
                messageController.clear();
                final chatID = auth.currentUser.uid.compareTo(personUID) < 0
                    ? auth.currentUser.uid + personUID
                    : personUID + auth.currentUser.uid;
                await chat.createMessage(chatID, {
                  'senderID': auth.currentUser.uid,
                  'receiverID': personUID,
                  'messageText': messageText,
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                  'read': false,
                });
                if (user.isStudent()) {
                  if (!(user.student?.chats?.contains(personUID) ?? true)) {
                    List<dynamic>? newChats = user.student?.chats;
                    newChats?.add(personUID);
                    await user.updateStudentData(chats: newChats);
                  } else {
                    List<dynamic>? newChats = user.student?.chats;
                    newChats?.remove(personUID);
                    newChats?.add(personUID);
                    await user.updateStudentData(chats: newChats);
                  }
                } else {
                  if (!(user.instructor?.chats?.contains(personUID) ?? true)) {
                    List<dynamic>? newChats = user.instructor?.chats;
                    newChats?.add(personUID);
                    await user.updateInstructorData(chats: newChats);
                  } else {
                    List<dynamic>? newChats = user.instructor?.chats;
                    newChats?.remove(personUID);
                    newChats?.add(personUID);
                    await user.updateInstructorData(chats: newChats);
                  }
                }
                if (studentID != null) {
                  if (user.isStudent()) {
                    if (!(chats.contains(user.student?.studentUID) ?? true)) {
                      List<dynamic>? newChats = chats;
                      newChats?.add(user.student?.studentUID);
                      await user.updateStudentByID(
                          studentID: studentID, chats: newChats);
                    } else {
                      List<dynamic>? newChats = chats;
                      newChats?.remove(user.student?.studentUID);
                      newChats?.add(user.student?.studentUID);
                      await user.updateStudentByID(
                          studentID: studentID, chats: newChats);
                    }
                  } else {
                    if (!(chats.contains(user.instructor?.instructorUID) ??
                        true)) {
                      List<dynamic>? newChats = chats;
                      newChats?.add(user.instructor?.instructorUID);
                      await user.updateStudentByID(
                          studentID: studentID, chats: newChats);
                    } else {
                      List<dynamic>? newChats = chats;
                      newChats?.remove(user.instructor?.instructorUID);
                      newChats?.add(user.instructor?.instructorUID);
                      await user.updateStudentByID(
                          studentID: studentID, chats: newChats);
                    }
                  }
                }
                if (instructorEmail != null) {
                  if (user.isStudent()) {
                    if (!(chats.contains(user.student?.studentUID) ?? true)) {
                      List<dynamic>? newChats = chats;
                      newChats?.add(user.student?.studentUID);
                      await user.updateInstructorByEmail(
                          instructorEmail: instructorEmail, chats: newChats);
                    } else {
                      List<dynamic>? newChats = chats;
                      newChats?.remove(user.student?.studentUID);
                      newChats?.add(user.student?.studentUID);
                      await user.updateInstructorByEmail(
                          instructorEmail: instructorEmail, chats: newChats);
                    }
                  } else {
                    if (!(chats.contains(user.instructor?.instructorUID) ??
                        true)) {
                      List<dynamic>? newChats = chats;
                      newChats?.add(user.instructor?.instructorUID);
                      await user.updateInstructorByEmail(
                          instructorEmail: instructorEmail, chats: newChats);
                    } else {
                      List<dynamic>? newChats = chats;
                      newChats?.remove(user.instructor?.instructorUID);
                      newChats?.add(user.instructor?.instructorUID);
                      await user.updateInstructorByEmail(
                          instructorEmail: instructorEmail, chats: newChats);
                    }
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMyMessage;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMyMessage,
  });

  @override
  Widget build(BuildContext context) {
    final align =
        isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bgColor = isMyMessage ? Colors.blue : Colors.grey;
    final textColor = isMyMessage ? Colors.white : Colors.black;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: align,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16), // Add rounded corners.
            ),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16, // Set your desired text size.
              ),
            ),
          ),
        ],
      ),
    );
  }
}
