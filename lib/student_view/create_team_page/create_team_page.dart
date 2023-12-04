import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/services/firebase/chats_firestore.dart';
import 'package:provider/provider.dart';

import '../../services/firebase/projects_firestore.dart';
import '../../services/firebase/users_firestore.dart';
import '../main_scaffold/main_scaffold.dart';

class CreateTeamPage extends StatefulWidget {
  const CreateTeamPage({super.key});

  static const String routeName = 'Create Team Page';
  static final _formKey = GlobalKey<FormState>();

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  String generateRandomString(int lengthOfString) {
    final random = Random();
    const allChars = '123456789';
    final randomString = List.generate(lengthOfString,
        (index) => allChars[random.nextInt(allChars.length)]).join();
    return randomString;
  }

  @override
  Widget build(BuildContext context) {
    final ProjectsFirestore project = Provider.of<ProjectsFirestore>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final ChatsFirestore chats = Provider.of<ChatsFirestore>(context);
    String? name;
    String? bio;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'createTeam',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ).tr(),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: CreateTeamPage._formKey,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'teamName',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ).tr(),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    autofocus: true,
                    onSaved: (newValue) => name = newValue,
                    decoration: InputDecoration(
                      hintText: 'enterTeamName'.tr(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'description',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ).tr(),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    onSaved: (newValue) => bio = newValue,
                    decoration: InputDecoration(
                      hintText: 'enterTeamDescription'.tr(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 32.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        String projectID = generateRandomString(6);
                        // ignore: non_constant_identifier_names
                        final IDs = await project.getAllProjectIDs();
                        while (IDs.contains(projectID)) {
                          projectID = generateRandomString(6);
                        }
                        CreateTeamPage._formKey.currentState?.save();
                        if (await project.createProject(
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                            bio: bio,
                            projectID: projectID,
                            projectName: name,
                            major: user.student?.major,
                            projectLevel: user.student?.projectLevel)) {
                          await project.loadProjectData(projectID: projectID);
                          await user.updateStudentData(
                              hasTeam: true, projectID: projectID);
                          await chats.createChat(projectID);
                          if (!mounted) return;
                          Navigator.pushNamedAndRemoveUntil(context,
                              StudentMainScaffold.routeName, (route) => false);
                        } else {
                          Fluttertoast.showToast(
                            msg: project.errorMessage,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'createTeam',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ).tr(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
