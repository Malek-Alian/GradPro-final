import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/services/firebase/announcements_firestore.dart';
import 'package:graduation_project/services/firebase/users_firestore.dart';
import 'package:provider/provider.dart';

class Announcements extends StatefulWidget {
  const Announcements({super.key});

  @override
  State<Announcements> createState() => _AnnouncementsState();
}

class _AnnouncementsState extends State<Announcements> {
  final TextEditingController textController = TextEditingController();
  bool isImportant = false;

  @override
  Widget build(BuildContext context) {
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final AnnouncementsFirestore announcementsFirestore =
        Provider.of<AnnouncementsFirestore>(context);

    return AlertDialog(
      scrollable: true,
      title: const Text(
        'Announcements',
        style: TextStyle(
          color: Colors.black,
        ),
      ).tr(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          !user.isStudent()
              ? TextField(
                  controller: textController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Type your announcement'.tr(),
                    labelStyle: const TextStyle(color: Colors.red),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                )
              : const SizedBox(
                  width: 0,
                  height: 0,
                ),
          !user.isStudent()
              ? Row(
                  children: [
                    Checkbox(
                      value: isImportant,
                      onChanged: (value) {
                        setState(() {
                          isImportant = value ?? false;
                        });
                      },
                    ),
                    const Text(
                      'Important',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ).tr(),
                  ],
                )
              : const SizedBox(
                  width: 0,
                  height: 0,
                ),
          !user.isStudent() ? const SizedBox(height: 16) : Container(),
          Expanded(
            flex: 0,
            child: SizedBox(
              width: 300,
              height: 350,
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: announcementsFirestore.streamAllAnnouncements(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  List<DocumentSnapshot> announcements = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      var announcement = announcements[index];
                      var text = announcement['text'] as String;
                      var sender = announcement['sender'] as String;
                      var senderId = announcement['senderId'] as String;
                      return ListTile(
                        leading: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: announcement['important']
                                ? Colors.red
                                : Colors.green,
                          ),
                          width: 10,
                          height: 10,
                        ),
                        contentPadding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 0, vertical: 10),
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: text));
                          Fluttertoast.showToast(
                            msg: 'Announcement copied to clipboard',
                            toastLength: Toast.LENGTH_LONG,
                          );
                        },
                        title: Text(
                          '$text\nDr. $sender',
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        trailing: !user.isStudent()
                            ? senderId == user.instructor?.instructorUID
                                ? ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    onPressed: () {
                                      announcementsFirestore.deleteAnnouncement(
                                          announcement['announcementId']);
                                    },
                                    child: const Text('delete').tr(),
                                  )
                                : const SizedBox(
                                    width: 0,
                                    height: 0,
                                  )
                            : const SizedBox(
                                width: 0,
                                height: 0,
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: const Text(
                'Long press on announcement to copy',
                style: TextStyle(color: Colors.black),
              ).tr(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    textController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close').tr(),
                ),
                !user.isStudent()
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          if (textController.text.isNotEmpty) {
                            announcementsFirestore.createAnnouncement(
                                text: textController.text,
                                senderId: user.instructor?.instructorUID ?? '',
                                sender:
                                    '${user.instructor?.firstName} ${user.instructor?.lastName}',
                                important: isImportant);
                            textController.clear();
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Announcement must not be empty',
                              toastLength: Toast.LENGTH_LONG,
                            );
                          }
                        },
                        child: const Text('Add Announcement').tr(),
                      )
                    : const SizedBox(
                        width: 0,
                        height: 0,
                      ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
