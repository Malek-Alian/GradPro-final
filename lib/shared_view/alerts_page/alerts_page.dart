import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../instructor_view/main_scaffold/main_scaffold.dart';
import '../../models/instructor_model.dart';
import '../../services/firebase/projects_firestore.dart';
import '../../services/firebase/users_firestore.dart';
import '../../services/theme/change_theme.dart';
import '../../student_view/main_scaffold/main_scaffold.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final ProjectsFirestore project = Provider.of<ProjectsFirestore>(context);
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final navigator = Navigator.of(context);
    final RefreshController refreshController =
        RefreshController(initialRefresh: false);

    return user.student == null && user.instructor == null
        // ! Guest
        ? Center(
            child: const Text('youMustHaveAccount').tr(),
          )
        : user.isStudent()
            // ! Student
            ? SmartRefresher(
                controller: refreshController,
                onRefresh: () async {
                  await user.loadStudentData();
                  refreshController.refreshCompleted();
                },
                header: WaterDropMaterialHeader(
                  backgroundColor: theme.isDark
                      ? const Color(0xFF1E5128)
                      : const Color(0xFF5F8D4E),
                  color: Colors.white,
                  distance: 40.0,
                ),
                child: user.student?.alerts?.isNotEmpty ?? false
                    ? ListView.builder(
                        itemCount: user.student?.alerts?.length,
                        itemBuilder: (BuildContext context, int index) {
                          final reversedIndex =
                              (user.student?.alerts?.length)! - 1 - index;
                          return Card(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: user.student?.alerts![reversedIndex]
                                                  ['picture'] !=
                                              null &&
                                          user.student?.alerts![reversedIndex]
                                                  ['picture'] !=
                                              ''
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(53),
                                          child: Image.network(
                                            user.student?.alerts![reversedIndex]
                                                ['picture'],
                                            width: 53,
                                            height: 53,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(53),
                                          child: Image.asset(
                                            'assets/images/defaultAvatar.png',
                                            width: 53,
                                            height: 53,
                                            color: theme.isDark
                                                ? Colors.white
                                                : Colors.black,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  title: Text(
                                    user.student?.alerts![reversedIndex]
                                        ['title'],
                                  ),
                                  subtitle: Text(
                                    user.student?.alerts![reversedIndex]
                                        ['body'],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFFEA5455),
                                            ),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () async {
                                            user.student?.alerts
                                                ?.removeAt(reversedIndex);
                                            await user.updateStudentData(
                                                alerts: user.student?.alerts);
                                          },
                                          child: Text(
                                            'reject',
                                            style: TextStyle(
                                              color: theme.isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ).tr(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            // ! Invite
                                            if (user.student
                                                        ?.alerts![reversedIndex]
                                                    ['type'] ==
                                                'invite') {
                                              await project.loadProjectData(
                                                  projectID:
                                                      user.student?.alerts![
                                                              reversedIndex]
                                                          ['projectID']);
                                              project.projectData?.members?.add(
                                                  user.student?.studentID);
                                              await project.updateProjectData(
                                                  members: project
                                                      .projectData?.members,
                                                  projectID: project
                                                      .projectData?.projectID);
                                              await user.updateStudentData(
                                                  hasTeam: true,
                                                  projectID: project
                                                      .projectData?.projectID);
                                              user.student?.alerts
                                                  ?.removeAt(reversedIndex);
                                              await user.updateStudentData(
                                                  alerts: user.student?.alerts);
                                              navigator.pushNamedAndRemoveUntil(
                                                StudentMainScaffold.routeName,
                                                (route) => false,
                                              );
                                            }
                                            // ! Join
                                            else if (user.student
                                                        ?.alerts![reversedIndex]
                                                    ['type'] ==
                                                'join') {
                                              project.projectData?.members?.add(
                                                  user.student?.alerts![
                                                          reversedIndex]
                                                      ['studentID']);
                                              await project.updateProjectData(
                                                  members: project
                                                      .projectData?.members,
                                                  projectID: project
                                                      .projectData?.projectID);
                                              await project.loadProjectData(
                                                  projectID: project
                                                      .projectData?.projectID);
                                              await user.updateStudentByID(
                                                  studentID:
                                                      user.student?.alerts![
                                                              reversedIndex]
                                                          ['studentID'],
                                                  hasTeam: true,
                                                  projectID: project
                                                      .projectData?.projectID);
                                              user.student?.alerts
                                                  ?.removeAt(reversedIndex);
                                              await user.updateStudentData(
                                                  alerts: user.student?.alerts);
                                            }
                                            // ! Request
                                            else if (user.student
                                                        ?.alerts![reversedIndex]
                                                    ['type'] ==
                                                'request') {
                                              InstructorModel? instructor =
                                                  await user.getInstructorByEmail(
                                                      user.student?.alerts![
                                                              reversedIndex]
                                                          ['instructorEmail']);
                                              await user.updateInstructorByEmail(
                                                  instructorEmail:
                                                      user.student?.alerts![
                                                              reversedIndex]
                                                          ['instructorEmail'],
                                                  projectID: project
                                                      .projectData?.projectID);
                                              await project.updateProjectData(
                                                supervisorName:
                                                    '${instructor?.firstName} ${instructor?.lastName}',
                                                projectID: project
                                                    .projectData?.projectID,
                                              );
                                              await project.loadProjectData(
                                                  projectID: project
                                                      .projectData?.projectID);
                                              user.student?.alerts
                                                  ?.removeAt(reversedIndex);
                                              await user.updateStudentData(
                                                  alerts: user.student?.alerts);
                                            }
                                          },
                                          child: const Text('accept').tr(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: const Text('youDontHaveAlert').tr(),
                      ),
              )
            // ! Instructor
            : SmartRefresher(
                controller: refreshController,
                onRefresh: () async {
                  await user.loadInstructorData();
                  refreshController.refreshCompleted();
                },
                header: WaterDropMaterialHeader(
                  backgroundColor: theme.isDark
                      ? const Color(0xFF1E5128)
                      : const Color(0xFF5F8D4E),
                  color: Colors.white,
                  distance: 40.0,
                ),
                child: user.instructor?.alerts?.isNotEmpty ?? false
                    ? ListView.builder(
                        itemCount: user.instructor?.alerts?.length,
                        itemBuilder: (BuildContext context, int index) {
                          final reversedIndex =
                              (user.instructor?.alerts?.length)! - 1 - index;
                          return Card(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: user.instructor
                                                      ?.alerts![reversedIndex]
                                                  ['picture'] !=
                                              null &&
                                          user.instructor
                                                      ?.alerts![reversedIndex]
                                                  ['picture'] !=
                                              ''
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(53),
                                          child: Image.network(
                                            user.instructor
                                                    ?.alerts![reversedIndex]
                                                ['picture'],
                                            width: 53,
                                            height: 53,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(53),
                                          child: Image.asset(
                                            'assets/images/defaultAvatar.png',
                                            width: 53,
                                            height: 53,
                                            color: theme.isDark
                                                ? Colors.white
                                                : Colors.black,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                  title: Text(
                                    user.instructor?.alerts![reversedIndex]
                                        ['title'],
                                  ),
                                  subtitle: Text(
                                    user.instructor?.alerts![reversedIndex]
                                        ['body'],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(
                                              color: Color(0xFFEA5455),
                                            ),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () async {
                                            user.instructor?.alerts
                                                ?.removeAt(reversedIndex);
                                            await user.updateInstructorData(
                                                alerts:
                                                    user.instructor?.alerts);
                                          },
                                          child: const Text('reject').tr(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            // ! Ask
                                            if (user.instructor
                                                        ?.alerts![reversedIndex]
                                                    ['type'] ==
                                                'ask') {
                                              user.instructor?.teams?.add(user
                                                      .instructor
                                                      ?.alerts![reversedIndex]
                                                  ['projectID']);
                                              await user.updateInstructorData(
                                                numberOfTeams: (user.instructor
                                                        ?.numberOfTeams)! +
                                                    1,
                                                teams: user.instructor?.teams,
                                              );
                                              await project.updateProjectData(
                                                supervisorName:
                                                    '${user.instructor?.firstName} ${user.instructor?.lastName}',
                                                projectID: user.instructor
                                                        ?.alerts![reversedIndex]
                                                    ['projectID'],
                                              );
                                              user.instructor?.alerts
                                                  ?.removeAt(reversedIndex);
                                              await user.updateInstructorData(
                                                  alerts:
                                                      user.instructor?.alerts);
                                              navigator.pushNamedAndRemoveUntil(
                                                InstructorMainScaffold
                                                    .routeName,
                                                (route) => false,
                                              );
                                            }
                                          },
                                          child: const Text('accept').tr(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: const Text('youDontHaveAlert').tr(),
                      ),
              );
  }
}
