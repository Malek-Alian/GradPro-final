import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/announcements.dart';
import 'package:graduation_project/shared_view/chats_page/chats_page.dart';
import 'package:provider/provider.dart';

import '../services/firebase/users_firestore.dart';

class TheAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TheAppBar({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final UsersFirestore user = Provider.of<UsersFirestore>(context);

    // * HomePage app bar
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.announcement,
        ),
        onPressed: () {
          if (user.student != null || user.instructor != null) {
            showDialog(
              context: context,
              builder: (context) {
                return const Announcements();
              },
            );
          }
        },
      ),
      title: Text(
        user.student == null && user.instructor == null
            ? 'welcome'.tr()
            : user.isStudent()
                ? '${'welcome'.tr()}, ${user.student?.firstName} ${user.student?.lastName}'
                : '${'welcome'.tr()}, Dr. ${user.instructor?.firstName} ${user.instructor?.lastName}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.chat,
          ),
          onPressed: () {
            if (user.student != null || user.instructor != null) {
              Navigator.pushNamed(context, ChatsPage.routeName);
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);
}
