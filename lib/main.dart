import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:graduation_project/services/firebase/announcements_firestore.dart';
import 'package:graduation_project/services/firebase/chats_firestore.dart';
import 'package:provider/provider.dart';

import 'material_app/material_app.dart';
import 'services/firebase/projects_firestore.dart';
import 'services/firebase/user_auth.dart';
import 'services/firebase/users_firestore.dart';
import 'services/theme/change_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en', 'US'), Locale('ar', 'JO')],
      path: 'assets/languages',
      fallbackLocale: const Locale('en', 'US'),
      child: const GPMS(),
    ),
  );
}

class GPMS extends StatelessWidget {
  const GPMS({super.key});

  @override
  Widget build(BuildContext context) {
    return Phoenix(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => UserAuth(),
          ),
          ChangeNotifierProvider(
            create: (context) => ChangeTheme(),
          ),
          ChangeNotifierProvider(
            create: (context) => UsersFirestore(),
          ),
          ChangeNotifierProvider(
            create: (context) => ChatsFirestore(),
          ),
          ChangeNotifierProvider(
            create: (context) => AnnouncementsFirestore(),
          ),
          ChangeNotifierProxyProvider<UsersFirestore, ProjectsFirestore>(
            create: (context) => ProjectsFirestore(),
            update: (context, value, previous) {
              var projectsInstance = previous ?? ProjectsFirestore();
              projectsInstance.update(value);
              return projectsInstance;
            },
          ),
        ],
        child: const TheMaterialApp(),
      ),
    );
  }
}
