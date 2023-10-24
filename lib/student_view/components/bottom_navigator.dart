import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../services/firebase/users_firestore.dart';
import '../../services/theme/change_theme.dart';

class StudentBottomNavigator extends StatefulWidget {
  const StudentBottomNavigator({super.key, required this.callbackFunction});
  final Function callbackFunction;

  @override
  State<StudentBottomNavigator> createState() => _StudentBottomNavigatorState();
}

class _StudentBottomNavigatorState extends State<StudentBottomNavigator> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final TextStyle textStyle = TextStyle(
      color: theme.isDark ? Colors.white : Colors.black,
    );

    return Container(
      decoration: const BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 3,
          ),
        ],
      ),
      child: SalomonBottomBar(
        currentIndex: _selectedIndex,
        selectedColorOpacity: 0.5,
        margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
        items: [
          SalomonBottomBarItem(
            icon: SvgPicture.asset(
              'assets/images/bnav_icons/home.svg',
              width: 25,
              colorFilter: theme.isDark
                  ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                  : null,
            ),
            title: Text(
              'myTeam'.tr(),
              style: textStyle,
            ),
            selectedColor: theme.isDark
                ? const Color(0xFF3700b3)
                : const Color.fromARGB(255, 0, 74, 194),
          ),
          SalomonBottomBarItem(
            icon: SvgPicture.asset(
              'assets/images/bnav_icons/team.svg',
              width: 30,
              colorFilter: theme.isDark
                  ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                  : null,
            ),
            title: Text(
              'teams'.tr(),
              style: textStyle,
            ),
            selectedColor: theme.isDark
                ? const Color(0xFFBC4873)
                : const Color.fromARGB(255, 206, 0, 38),
          ),
          SalomonBottomBarItem(
            icon: SvgPicture.asset(
              'assets/images/bnav_icons/student.svg',
              width: 30,
              colorFilter: theme.isDark
                  ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                  : null,
            ),
            title: Text(
              'students'.tr(),
              style: textStyle,
            ),
            selectedColor: theme.isDark
                ? const Color(0xff735F32)
                : const Color.fromARGB(255, 167, 105, 0),
          ),
          SalomonBottomBarItem(
            icon: Badge(
              isLabelVisible: user.student?.alerts?.isNotEmpty ?? false,
              label: Text(
                '${user.student?.alerts?.length.toString()}',
                style: const TextStyle(fontSize: 12),
              ),
              largeSize: 20,
              child: SvgPicture.asset(
                'assets/images/bnav_icons/ring.svg',
                width: 25,
                colorFilter: theme.isDark
                    ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : null,
              ),
            ),
            title: Text(
              'alerts'.tr(),
              style: textStyle,
            ),
            selectedColor: theme.isDark
                ? const Color(0xFF1E5128)
                : const Color.fromARGB(255, 36, 136, 0),
          ),
          SalomonBottomBarItem(
            icon: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 3,
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(255, 48, 48, 1),
                    Color.fromRGBO(255, 197, 95, 1),
                    Color.fromRGBO(86, 255, 184, 1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Align(
                child: user.student?.profilePicture == null ||
                        user.student?.profilePicture == ''
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(53),
                        child: Image.asset(
                          'assets/images/defaultAvatar.png',
                          width: 53,
                          height: 53,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(53),
                        child: Image.network(
                          user.student?.profilePicture ?? '',
                          width: 53,
                          height: 53,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            title: const Text(''),
            selectedColor:
                theme.isDark ? const Color(0xFF121212) : Colors.white,
          ),
        ],
        backgroundColor: theme.isDark ? Colors.black : Colors.white,
        onTap: (value) {
          widget.callbackFunction(value);
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
    );
  }
}
