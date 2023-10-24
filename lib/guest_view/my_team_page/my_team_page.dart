import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MyTeamPage extends StatelessWidget {
  const MyTeamPage({super.key});
  static bool hasTeam = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: hasTeam
          ? const Center(
              child: Text(
                'Team information page',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            )
          : Center(
              child: const Text(
                'loginToHaveTeam',
              ).tr(),
            ),
    );
  }
}
