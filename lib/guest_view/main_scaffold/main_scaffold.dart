import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_bar.dart';
import '../../services/theme/change_theme.dart';
import '../../shared_view/alerts_page/alerts_page.dart';
import '../../shared_view/settings_page/settings_page.dart';
import '../../shared_view/teams_page/teams_page.dart';
import '../components/bottom_navigator.dart';
import '../my_team_page/my_team_page.dart';
import '../students_page/students_page.dart';

class GuestMainScaffold extends StatefulWidget {
  const GuestMainScaffold({super.key});

  static const String routeName = 'Guest Page';

  @override
  State<GuestMainScaffold> createState() => _GuestMainScaffoldState();
}

class _GuestMainScaffoldState extends State<GuestMainScaffold> {
  int pageIndex = 0;

  final List<Widget> _bodies = [
    const MyTeamPage(),
    const TeamsPage(createTeam: false),
    const StudentsPage(),
    const AlertsPage(),
    const SettingsPage(),
  ];

  // * Take index from TheBottomNavigator
  callback(index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final List<Color> appBarColors = [
      theme.isDark ? const Color(0xFF3700b3) : const Color(0xFF537EC5),
      theme.isDark ? const Color(0xFFBC4873) : const Color(0xFFCF6679),
      theme.isDark ? const Color(0xff735F32) : const Color(0xFFAA8B56),
      theme.isDark ? const Color(0xFF1E5128) : const Color(0xFF5F8D4E),
      theme.isDark ? Colors.black : Colors.white,
    ];

    // * To make TabBar in FindPage work
    return Scaffold(
      appBar: TheAppBar(
        color: appBarColors[pageIndex],
      ),
      body: _bodies[pageIndex],
      bottomNavigationBar: TheAppBottomNavigator(callbackFunction: callback),
    );
  }
}
