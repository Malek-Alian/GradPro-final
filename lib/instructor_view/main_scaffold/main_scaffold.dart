import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar.dart';
import '../../services/firebase/users_firestore.dart';
import '../../services/theme/change_theme.dart';
import '../../shared_view/alerts_page/alerts_page.dart';
import '../../shared_view/settings_page/settings_page.dart';
import '../../shared_view/teams_page/teams_page.dart';
import '../../student_view/students_page/students_page.dart';
import '../components/bottom_navigator.dart';
import '../my_teams_page/teams_page.dart';

class InstructorMainScaffold extends StatefulWidget {
  const InstructorMainScaffold({super.key});

  static const String routeName = 'Instructor Page';

  @override
  State<InstructorMainScaffold> createState() => _InstructorMainScaffold();
}

class _InstructorMainScaffold extends State<InstructorMainScaffold> {
  int pageIndex = 0;

  Future<bool> loadAllData() async {
    final UsersFirestore user =
        Provider.of<UsersFirestore>(context, listen: false);
    await user.loadInstructorData();
    return true;
  }

  callback(index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final List<Widget> bodies = [
      const TeamPage(),
      const TeamsPage(createTeam: false),
      const StudentsPage(),
      const AlertsPage(),
      const SettingsPage(),
    ];
    final List<Color> appBarColors = [
      theme.isDark ? const Color(0xFF3700b3) : const Color(0xFF537EC5),
      theme.isDark ? const Color(0xFFBC4873) : const Color(0xFFCF6679),
      theme.isDark ? const Color(0xff735F32) : const Color(0xFFAA8B56),
      theme.isDark ? const Color(0xFF1E5128) : const Color(0xFF5F8D4E),
      theme.isDark ? Colors.black : Colors.white,
    ];

    return FutureBuilder(
      future: loadAllData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          FlutterNativeSplash.remove();
          return Scaffold(
            appBar: TheAppBar(
              color: appBarColors[pageIndex],
            ),
            body: bodies[pageIndex],
            bottomNavigationBar:
                InstructorBottomNavigator(callbackFunction: callback),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          );
        }
      },
    );
  }
}
