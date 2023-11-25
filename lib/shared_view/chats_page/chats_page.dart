import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/models/student_model.dart';
import 'package:graduation_project/services/firebase/chats_firestore.dart';
import 'package:graduation_project/services/firebase/user_auth.dart';
import 'package:graduation_project/services/firebase/users_firestore.dart';
import 'package:graduation_project/shared_view/chat_page/chat_page.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  static const String routeName = 'Chats Page';

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  Widget build(BuildContext context) {
    final UserAuth auth = Provider.of<UserAuth>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final ChatsFirestore chat = Provider.of<ChatsFirestore>(context);

    List<dynamic> chatUserIds = [];

    if (auth.currentUser.email != '') {
      if (user.isStudent()) {
        chatUserIds = user.student?.chats ?? [];
      } else {
        chatUserIds = user.instructor?.chats ?? [];
      }
    }

    Future<dynamic> getPersonByUID({required String uid}) async {
      try {
        final personData = await user.getPersonByUID(uid: uid);
        return personData;
      } catch (error) {
        // ignore: avoid_print
        print("Error fetching person data: $error");
        return null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
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
      body: SafeArea(
        child: auth.currentUser.email == ''
            ? Center(
                child: const Text('youMustHaveAccount').tr(),
              )
            : ListView.builder(
                itemCount: chatUserIds.length,
                itemBuilder: (BuildContext context, int index) {
                  final chatUserId =
                      chatUserIds[chatUserIds.length - 1 - index];
                  return FutureBuilder(
                    future: getPersonByUID(uid: chatUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          final person = snapshot.data;
                          return FutureBuilder(
                            future:
                                auth.currentUser.uid.compareTo(chatUserId) < 0
                                    ? chat.getLastMessageInChat(
                                        auth.currentUser.uid + chatUserId)
                                    : chat.getLastMessageInChat(
                                        chatUserId + auth.currentUser.uid),
                            builder: (context, messageSnapshot) {
                              if (messageSnapshot.connectionState ==
                                  ConnectionState.done) {
                                return Card(
                                  color: Colors.blueGrey[900],
                                  elevation: 4,
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(8),
                                    leading: Stack(
                                      children: [
                                        person?.profilePicture != null &&
                                                person?.profilePicture != ''
                                            ? CircleAvatar(
                                                radius: 32,
                                                backgroundImage: NetworkImage(
                                                  person.profilePicture,
                                                ),
                                              )
                                            : const CircleAvatar(
                                                radius: 32,
                                                backgroundImage: AssetImage(
                                                  'assets/images/defaultAvatar.png',
                                                ),
                                              ),
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: FutureBuilder(
                                            future: auth.currentUser.uid
                                                        .compareTo(chatUserId) <
                                                    0
                                                ? chat
                                                    .calculateUnreadMessagesCount(
                                                        auth.currentUser.uid +
                                                            chatUserId,
                                                        auth.currentUser.uid)
                                                : chat
                                                    .calculateUnreadMessagesCount(
                                                        chatUserId +
                                                            auth.currentUser
                                                                .uid,
                                                        auth.currentUser.uid),
                                            builder:
                                                (context, unreadCountSnapshot) {
                                              if (unreadCountSnapshot
                                                      .connectionState ==
                                                  ConnectionState.done) {
                                                final unreadMessagesCount =
                                                    unreadCountSnapshot.data
                                                        as int;
                                                return unreadMessagesCount > 0
                                                    ? Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(6),
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              Colors.red[300],
                                                        ),
                                                        child: Text(
                                                          unreadMessagesCount
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      )
                                                    : Container();
                                              } else {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: Shimmer(
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Colors.grey,
                                                        Colors.white
                                                      ],
                                                    ),
                                                    child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      person.firstName + ' ' + person.lastName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: FutureBuilder(
                                      future: auth.currentUser.uid
                                                  .compareTo(chatUserId) <
                                              0
                                          ? chat.getLastMessageInChat(
                                              auth.currentUser.uid + chatUserId)
                                          : chat.getLastMessageInChat(
                                              chatUserId +
                                                  auth.currentUser.uid),
                                      builder: (context, messageSnapshot) {
                                        if (messageSnapshot.connectionState ==
                                            ConnectionState.done) {
                                          final lastMessage =
                                              messageSnapshot.data;
                                          return Text(
                                            lastMessage != null
                                                ? lastMessage['messageText']
                                                    .toString()
                                                : 'No messages',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          );
                                        } else if (messageSnapshot.hasError) {
                                          return const Text(
                                              'Error loading chat data');
                                        } else {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Shimmer(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Colors.grey,
                                                  Colors.white
                                                ],
                                              ),
                                              child: Container(
                                                height: 16,
                                                width: 300,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        ChatPage.routeName,
                                        arguments: person is StudentModel
                                            ? {
                                                'personUID': person.studentUID,
                                                'studentID': person.studentID,
                                                'firstName': person.firstName,
                                                'lastName': person.lastName,
                                                'chats': person.chats,
                                              }
                                            : {
                                                'personUID':
                                                    person.instructorUID,
                                                'instructorEmail':
                                                    person.instructorEmail,
                                                'firstName': person.firstName,
                                                'lastName': person.lastName,
                                                'chats': person.chats,
                                              },
                                      );
                                    },
                                  ),
                                );
                              } else if (messageSnapshot.hasError) {
                                return const ListTile(
                                  title: Text('Error loading chat data'),
                                );
                              } else {
                                return ListTile(
                                  title: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Shimmer(
                                      gradient: const LinearGradient(
                                        colors: [Colors.grey, Colors.white],
                                      ),
                                      child: Container(
                                        height: 16,
                                        width: 300,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        } else if (snapshot.hasError) {
                          return const ListTile(
                            title: Text('Error loading chat data'),
                          );
                        }
                      }
                      return ListTile(
                        title: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Shimmer(
                            gradient: const LinearGradient(
                              colors: [Colors.grey, Colors.white],
                            ),
                            child: Container(
                              height: 80,
                              width: 300,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
