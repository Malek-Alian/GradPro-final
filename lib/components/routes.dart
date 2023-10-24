import 'package:flutter/widgets.dart';
import 'package:graduation_project/material_app/activate_page.dart';
import 'package:graduation_project/shared_view/chats_page/chats_page.dart';

import '../guest_view/main_scaffold/main_scaffold.dart';
import '../instructor_view/main_scaffold/main_scaffold.dart';
import '../material_app/login_page.dart';
import '../material_app/choose.dart';
import '../shared_view/chat_page/chat_page.dart';
import '../shared_view/my_team_page/my_team_page.dart';
import '../shared_view/settings_page/components/about_us.dart';
import '../shared_view/settings_page/components/profile_page.dart';
import '../shared_view/settings_page/settings_page.dart';
import '../student_view/create_team_page/create_team_page.dart';
import '../student_view/main_scaffold/main_scaffold.dart';
import 'wrapper.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    ChatPage.routeName: (context) => const ChatPage(),
    SettingsPage.routeName: (context) => const SettingsPage(),
    InstructorMainScaffold.routeName: (context) =>
        const InstructorMainScaffold(),
    StudentMainScaffold.routeName: (context) => const StudentMainScaffold(),
    GuestMainScaffold.routeName: (context) => const GuestMainScaffold(),
    Choose.routeName: (context) => const Choose(),
    LoginPage.routeName: (context) => const LoginPage(),
    Wrapper.routeName: (context) => const Wrapper(),
    CreateTeamPage.routeName: (context) => const CreateTeamPage(),
    MyTeamPage.routeName: (context) => const MyTeamPage(),
    AboutUsPage.routeName: (context) => const AboutUsPage(),
    ProfilePage.routeName: (context) => const ProfilePage(),
    ActivatePage.routeName: (context) => const ActivatePage(),
    ChatsPage.routeName: (context) => const ChatsPage(),
  };
}
