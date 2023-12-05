import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';

import '../../models/project_model.dart';
import '../../services/firebase/projects_firestore.dart';
import '../../services/firebase/users_firestore.dart';
import '../../services/theme/change_theme.dart';
import '../../student_view/create_team_page/create_team_page.dart';
import 'components/team_dialog.dart';

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key, required this.createTeam});
  final bool createTeam;

  @override
  Widget build(BuildContext context) {
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final ProjectsFirestore project = Provider.of<ProjectsFirestore>(context);
    final navigator = Navigator.of(context);

    return Scaffold(
      body: StreamBuilder(
        stream: user.student == null && user.instructor == null
            ? project.getProjectsForGuest
            : user.isStudent()
                ? project.getProjectsForGuest
                : project.getProjectsForGuest,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<ProjectModel> projectData = snapshot.data ?? [];
            return ListView.builder(
              itemCount: projectData.length,
              itemBuilder: (context, index) {
                // ! Guest
                return user.student == null && user.instructor == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 4),
                        child: ListTile(
                          leading: const Icon(Icons.groups),
                          title: Text(
                            '${projectData[index].projectName}',
                            style: TextStyle(
                              color: theme.isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => TeamDialog(
                                projectData: projectData,
                                index: index,
                              ),
                            );
                          },
                        ),
                      )
                    // ! Student
                    : user.isStudent()
                        ? projectData[index].projectID !=
                                user.student?.projectID
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 4),
                                child: ListTile(
                                  leading: const Icon(Icons.groups),
                                  title: Text(
                                    '${projectData[index].projectName}',
                                    style: TextStyle(
                                      color: theme.isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  trailing: !(user.student?.hasTeam ?? false) &&
                                          projectData[index].major ==
                                              user.student?.major &&
                                          projectData[index].projectLevel ==
                                              user.student?.projectLevel
                                      ? OutlinedButton(
                                          onPressed: () {
                                            PanaraConfirmDialog.show(
                                              context,
                                              color: Colors.red,
                                              textColor: Colors.black,
                                              title: "areYouSure".tr(),
                                              message:
                                                  "${'joinRequest?'.tr()} ${projectData[index].projectName}${'?'.tr()}",
                                              confirmButtonText: "confirm".tr(),
                                              cancelButtonText: "cancel".tr(),
                                              onTapCancel: () {
                                                Navigator.pop(context);
                                              },
                                              onTapConfirm: () async {
                                                if (projectData[index]
                                                        .members!
                                                        .length <
                                                    3) {
                                                  var members =
                                                      projectData[index]
                                                          .members;
                                                  for (var member
                                                      in members ?? []) {
                                                    await user
                                                        .updateStudentByID(
                                                      studentID: member,
                                                      alert: {
                                                        'studentID':
                                                            '${user.student?.studentID}',
                                                        'title':
                                                            '${user.student?.firstName} ${user.student?.lastName}',
                                                        'body':
                                                            'Can i join your team ?',
                                                        'picture':
                                                            '${user.student?.profilePicture}',
                                                        'type': 'join',
                                                      },
                                                    );
                                                  }
                                                  navigator.pop();
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'Join request sent to ${projectData[index].projectName}',
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                  );
                                                } else {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        'The team has reached maximum number of members',
                                                    toastLength:
                                                        Toast.LENGTH_LONG,
                                                  );
                                                }
                                              },
                                              panaraDialogType:
                                                  PanaraDialogType.custom,
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              width: 2,
                                              color: theme.isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          child: const Text('join').tr(),
                                        )
                                      : null,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => TeamDialog(
                                        projectData: projectData,
                                        index: index,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container()
                        // ! Instructor
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 4),
                            child: ListTile(
                              leading: const Icon(Icons.groups),
                              title: Text(
                                '${projectData[index].projectName}',
                                style: TextStyle(
                                  color: theme.isDark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              trailing: projectData[index].major ==
                                      user.instructor?.major
                                  ? OutlinedButton(
                                      onPressed: () {
                                        PanaraConfirmDialog.show(
                                          context,
                                          color: Colors.red,
                                          textColor: Colors.black,
                                          title: "areYouSure".tr(),
                                          message:
                                              "${'supervisionRequest?'.tr()} ${projectData[index].projectName}${'?'.tr()}",
                                          confirmButtonText: "confirm".tr(),
                                          cancelButtonText: "cancel".tr(),
                                          onTapCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onTapConfirm: () async {
                                            if (projectData[index]
                                                    .supervisorName ==
                                                '') {
                                              if (user.instructor!.teams!
                                                      .length <
                                                  3) {
                                                var members =
                                                    projectData[index].members;
                                                for (var member
                                                    in members ?? []) {
                                                  await user.updateStudentByID(
                                                    studentID: member,
                                                    alert: {
                                                      'instructorEmail':
                                                          '${user.instructor?.instructorEmail}',
                                                      'title':
                                                          'Dr. ${user.instructor?.firstName} ${user.instructor?.lastName}',
                                                      'body':
                                                          'Can i be your team supervisor ?',
                                                      'picture':
                                                          '${user.instructor?.profilePicture}',
                                                      'type': 'request',
                                                    },
                                                  );
                                                }
                                                navigator.pop();
                                                Fluttertoast.showToast(
                                                  msg:
                                                      'Supervision request sent to ${projectData[index].projectName}',
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                );
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      'You cannot have more than 3 teams',
                                                  toastLength:
                                                      Toast.LENGTH_LONG,
                                                );
                                              }
                                            } else {
                                              Fluttertoast.showToast(
                                                msg:
                                                    'The team already has supervisor',
                                                toastLength: Toast.LENGTH_LONG,
                                              );
                                            }
                                          },
                                          panaraDialogType:
                                              PanaraDialogType.custom,
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          width: 2,
                                          color: theme.isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      child: const Text('request').tr(),
                                    )
                                  : null,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => TeamDialog(
                                    projectData: projectData,
                                    index: index,
                                  ),
                                );
                              },
                            ),
                          );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: createTeam
          ? !(user.student?.hasTeam ?? false)
              ? FloatingActionButton.extended(
                  icon: const Icon(Icons.add),
                  label: const Text('createTeam').tr(),
                  onPressed: () {
                    Navigator.pushNamed(context, CreateTeamPage.routeName);
                  },
                )
              : null
          : null,
    );
  }
}
