import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';

import '../../models/student_model.dart';
import '../../services/firebase/projects_firestore.dart';
import '../../services/firebase/user_auth.dart';
import '../../services/firebase/users_firestore.dart';
import '../../services/theme/change_theme.dart';
import 'components/student_dialog.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final UsersFirestore student = Provider.of<UsersFirestore>(context);
    final ProjectsFirestore project = Provider.of<ProjectsFirestore>(context);
    final UserAuth user = Provider.of<UserAuth>(context);
    final navigator = Navigator.of(context);

    return StreamBuilder(
      stream: student.getStudents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<StudentModel> studentData = snapshot.data ?? [];
          return ListView.builder(
            itemCount: studentData.length,
            itemBuilder: (context, index) {
              if (studentData[index].studentUID == user.currentUser.uid) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: ListTile(
                  leading: studentData[index].profilePicture != null &&
                          studentData[index].profilePicture != ''
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(53),
                          child: Image.network(
                            studentData[index].profilePicture!,
                            width: 53,
                            height: 53,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(53),
                          child: Image.asset(
                            'assets/images/defaultAvatar.png',
                            width: 53,
                            height: 53,
                            color: theme.isDark ? Colors.white : Colors.black,
                            fit: BoxFit.cover,
                          ),
                        ),
                  title: Text(
                    '${studentData[index].firstName} ${studentData[index].lastName}',
                    style: TextStyle(
                      color: theme.isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: (student.student?.hasTeam ?? false) &&
                          studentData[index].projectLevel ==
                              student.student?.projectLevel &&
                          studentData[index].major == student.student?.major
                      ? OutlinedButton(
                          onPressed: () {
                            PanaraConfirmDialog.show(
                              context,
                              color: Colors.red,
                              textColor: Colors.black,
                              title: "areYouSure".tr(),
                              message:
                                  "${'invitation?'.tr()} ${studentData[index].firstName} ${studentData[index].lastName}${'?'.tr()}",
                              confirmButtonText: "confirm".tr(),
                              cancelButtonText: "cancel".tr(),
                              onTapCancel: () {
                                Navigator.pop(context);
                              },
                              onTapConfirm: () async {
                                await student.updateStudentByID(
                                  studentID: studentData[index].studentID,
                                  alert: {
                                    'projectID':
                                        '${project.projectData?.projectID}',
                                    'title':
                                        '${project.projectData?.projectName}',
                                    'body':
                                        'Hi, I\'m ${student.student?.firstName} ${student.student?.lastName}, Would you join our team !',
                                    'picture':
                                        '${student.student?.profilePicture}',
                                    'type': 'invite',
                                  },
                                );
                                navigator.pop();
                                Fluttertoast.showToast(
                                  msg:
                                      'Invitation sent to ${studentData[index].firstName} ${studentData[index].lastName}',
                                  toastLength: Toast.LENGTH_LONG,
                                );
                              },
                              panaraDialogType: PanaraDialogType.custom,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              width: 2,
                              color: theme.isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          child: const Text('invite').tr(),
                        )
                      : null,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          StudentDialog(studentData: studentData, index: index),
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
    );
  }
}
