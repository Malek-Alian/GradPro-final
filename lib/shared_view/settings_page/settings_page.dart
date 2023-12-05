import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import '../../material_app/login_page.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';

import '../../models/student_model.dart';
import '../../services/firebase/user_auth.dart';
import '../../services/firebase/users_firestore.dart';
import '../../services/theme/change_theme.dart';
import 'components/about_us.dart';
import 'components/languages_dialog.dart';
import 'components/profile_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String routeName = 'Setting Page';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  StudentModel userData = StudentModel();

  @override
  Widget build(BuildContext context) {
    final UserAuth auth = Provider.of<UserAuth>(context);
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(
            'profile',
            style: TextStyle(
              color: theme.isDark ? Colors.white : Colors.black,
            ),
          ).tr(),
          onTap: () {
            user.student == null && user.instructor == null
                ? showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: const Text(
                        'loginToHaveProfile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ).tr(),
                    ),
                  )
                : Navigator.pushNamed(context, ProfilePage.routeName);
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(
            'language',
            style: TextStyle(
              color: theme.isDark ? Colors.white : Colors.black,
            ),
          ).tr(),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const LanguagesDialog(),
            );
          },
        ),
        const Divider(),
        SwitchListTile.adaptive(
          secondary: const Icon(Icons.dark_mode),
          title: Text(
            'darkMode',
            style: TextStyle(
              color: theme.isDark ? Colors.white : Colors.black,
            ),
          ).tr(),
          value: theme.isDark,
          onChanged: (value) {
            theme.changeTheme = value;
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(
            'aboutUs',
            style: TextStyle(
              color: theme.isDark ? Colors.white : Colors.black,
            ),
          ).tr(),
          onTap: () {
            Navigator.pushNamed(context, AboutUsPage.routeName);
          },
        ),
        const Divider(),
        user.student == null && user.instructor == null
            ? ListTile(
                leading: const Icon(Icons.logout),
                title: const Text(
                  'login',
                  style: TextStyle(color: Color(0xFFEA5455)),
                ).tr(),
                onTap: () async {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginPage.routeName, (route) => false);
                },
              )
            : ListTile(
                leading: const Icon(Icons.logout),
                title: const Text(
                  'logOut',
                  style: TextStyle(color: Color(0xFFEA5455)),
                ).tr(),
                onTap: () async {
                  PanaraConfirmDialog.show(
                    context,
                    color: Colors.red,
                    textColor: Colors.black,
                    title: "areYouSure".tr(),
                    message: "logOut?".tr(),
                    confirmButtonText: "confirm".tr(),
                    cancelButtonText: "cancel".tr(),
                    onTapCancel: () {
                      Navigator.pop(context);
                    },
                    onTapConfirm: () async {
                      await auth.signOut();
                      if (context.mounted) {
                        Phoenix.rebirth(context);
                      }
                    },
                    panaraDialogType: PanaraDialogType.custom,
                  );
                },
              ),
      ],
    );
  }
}
