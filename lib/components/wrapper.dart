import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../instructor_view/main_scaffold/main_scaffold.dart';
import '../material_app/intro.dart';
import '../services/firebase/user_auth.dart';
import '../student_view/main_scaffold/main_scaffold.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  static const String routeName = 'wrapper';
  final String role = 'student';

  @override
  Widget build(BuildContext context) {
    final UserAuth auth = Provider.of<UserAuth>(context);

    return StreamBuilder<User?>(
      stream: UserAuth().userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return snapshot.hasData
            ? auth.currentUser.email?.contains('std') ?? false
                ? const StudentMainScaffold()
                : const InstructorMainScaffold()
            : const AppIntro();
      },
    );
  }
}
