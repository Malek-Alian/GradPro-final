import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar.dart';
import '../../services/firebase/projects_firestore.dart';
import '../../services/firebase/users_firestore.dart';
import '../../services/theme/change_theme.dart';
import '../../shared_view/alerts_page/alerts_page.dart';
import '../../shared_view/my_team_page/my_team_page.dart';
import '../../shared_view/settings_page/settings_page.dart';
import '../../shared_view/teams_page/teams_page.dart';
import '../components/bottom_navigator.dart';
import '../students_page/students_page.dart';

class StudentMainScaffold extends StatefulWidget {
  const StudentMainScaffold({super.key});

  static const String routeName = 'Student Page';

  @override
  State<StudentMainScaffold> createState() => _StudentMainScaffoldState();
}

class _StudentMainScaffoldState extends State<StudentMainScaffold> {
  int pageIndex = 0;

  Future<bool> loadAllData() async {
    final UsersFirestore user =
        Provider.of<UsersFirestore>(context, listen: false);
    final ProjectsFirestore project =
        Provider.of<ProjectsFirestore>(context, listen: false);
    await user.loadStudentData();
    if (user.student?.projectID != null && user.student?.projectID != '') {
      await project.loadProjectData(projectID: user.student?.projectID);
    }
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
      const MyTeamPage(),
      const TeamsPage(createTeam: true),
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
                StudentBottomNavigator(callbackFunction: callback),
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
