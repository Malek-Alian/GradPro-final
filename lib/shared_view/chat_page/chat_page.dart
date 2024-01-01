import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/models/instructor_model.dart';
import 'package:graduation_project/services/firebase/chats_firestore.dart';
import 'package:graduation_project/services/firebase/user_auth.dart';
import 'package:graduation_project/services/firebase/users_firestore.dart';
import 'package:graduation_project/services/theme/change_theme.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      this.personUID,
      this.studentID,
      this.instructorEmail,
      this.firstName,
      this.lastName,
      this.chats,
      this.teamChat,
      this.projectID});

  final String? personUID;
  final String? studentID;
  final String? instructorEmail;
  final String? firstName;
  final String? lastName;
  final bool? teamChat;
  final String? projectID;
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
    final teamChat = args?['teamChat'];
    final projectID = args?['projectID'];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          title: Text(
            firstName + ' ' + lastName ?? 'Chat Name',
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
                  stream: teamChat
                      ? chat.getMessagesInChatStream(projectID)
                      : auth.currentUser.uid.compareTo(personUID) < 0
                          ? chat.getMessagesInChatStream(
                              auth.currentUser.uid + personUID)
                          : chat.getMessagesInChatStream(
                              personUID + auth.currentUser.uid),
                  builder: (context, snapshot) {
                    teamChat
                        ? chat.markMessagesAsRead(
                            projectID, auth.currentUser.uid)
                        : auth.currentUser.uid.compareTo(personUID) < 0
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
                                  teamChat: teamChat,
                                  sender: message['senderID'],
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
      ),
    );
  }

  Widget _buildInputField() {
    final UserAuth auth = Provider.of<UserAuth>(context);
    final ChatsFirestore chat = Provider.of<ChatsFirestore>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final personUID = args?['personUID'];
    final studentID = args?['studentID'];
    final instructorEmail = args?['instructorEmail'];
    final teamChat = args?['teamChat'];
    final projectID = args?['projectID'];
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
                hintStyle: TextStyle(
                  color: theme.isDark ? Colors.white : Colors.black,
                ),
                filled: true,
                fillColor: theme.isDark ? Colors.black : Colors.white,
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
                final chatID = teamChat
                    ? projectID
                    : auth.currentUser.uid.compareTo(personUID) < 0
                        ? auth.currentUser.uid + personUID
                        : personUID + auth.currentUser.uid;
                await chat.createMessage(chatID, {
                  'senderID': auth.currentUser.uid,
                  'receiverID': personUID,
                  'messageText': messageText,
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                  'read': false,
                });
                if (!teamChat) {
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
                    if (!(user.instructor?.chats?.contains(personUID) ??
                        true)) {
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
  final String sender;
  final bool teamChat;

  const ChatBubble({
    Key? key,
    required this.text,
    required this.isMyMessage,
    required this.sender,
    required this.teamChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final Locale locale = Localizations.localeOf(context);

    void copyToClipboard(String message) {
      Clipboard.setData(ClipboardData(text: message));
      Fluttertoast.showToast(
        msg: 'Message copied to clipboard',
        toastLength: Toast.LENGTH_LONG,
      );
    }

    return FutureBuilder(
      future: user.getPersonByUID(uid: sender),
      builder: (context, personSnapshot) {
        if (personSnapshot.connectionState == ConnectionState.done) {
          final person = personSnapshot.data;
          if (person != null) {
            return _buildChatBubble(
                person, sender, theme, locale, copyToClipboard);
          }
        }
        return Container();
      },
    );
  }

  Widget _buildChatBubble(dynamic person, String uid, ChangeTheme theme,
      Locale locale, copyToClipboard) {
    final align =
        isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final senderHash = generateHash(uid);
    final isSpecialUid = uid == 'V6pFRD8zHaSOUNIqxBkbjYaTrKk1';
    Color textColor = Colors.white;
    BoxDecoration messageDecoration;

    if (isSpecialUid) {
      messageDecoration = BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/529468.jpg'),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      );
    } else {
      final bgColor =
          Color(int.parse(senderHash.substring(0, 6), radix: 16) | 0xFF000000);
      final isDark = bgColor.computeLuminance() < 0.5;
      textColor = isDark ? Colors.white : Colors.black;
      messageDecoration = BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Row(
            textDirection: isMyMessage
                ? locale.languageCode == 'ar'
                    ? TextDirection.ltr
                    : TextDirection.rtl
                : locale.languageCode == 'ar'
                    ? TextDirection.rtl
                    : TextDirection.ltr,
            crossAxisAlignment: align,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    person.profilePicture != '' && person.profilePicture != null
                        ? NetworkImage(person.profilePicture)
                        : const AssetImage('assets/images/defaultAvatar.png')
                            as ImageProvider,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onLongPress: () {
                  copyToClipboard(text);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: messageDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      teamChat
                          ? Text(
                              person is InstructorModel
                                  ? 'Dr. ${person.firstName} ${person.lastName}'
                                  : '${person.firstName} ${person.lastName}',
                              style: TextStyle(
                                color: isSpecialUid
                                    ? !theme.isDark
                                        ? Colors.black
                                        : Colors.white
                                    : textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Container(),
                      teamChat ? const SizedBox(height: 4) : Container(),
                      Text(
                        text,
                        style: TextStyle(
                          color: isSpecialUid
                              ? !theme.isDark
                                  ? Colors.black
                                  : Colors.white
                              : textColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }
}
