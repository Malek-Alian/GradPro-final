import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/services/firebase/user_auth.dart';
import 'package:graduation_project/shared_view/chat_page/chat_page.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/firebase/projects_firestore.dart';
import '../../services/firebase/users_firestore.dart';
import '../../services/theme/change_theme.dart';
import 'components/add_task_dialog.dart';
import 'components/supervisors_dialog.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  static const String routeName = 'My Team Page';

  @override
  State<MyTeamPage> createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  void _showFullScreenImage(BuildContext context, String image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.network(
              image,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  void _launchURL(String? url) async {
    if (url != null) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserAuth auth = Provider.of<UserAuth>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final ProjectsFirestore project = Provider.of<ProjectsFirestore>(context);
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final RefreshController refreshController =
        RefreshController(initialRefresh: false);
    final navigator = Navigator.of(context);
    final formKey = GlobalKey<FormState>();

    return user.isStudent()
        ? SmartRefresher(
            controller: refreshController,
            onRefresh: () async {
              await project.loadProjectData(
                  projectID: project.projectData?.projectID);
              refreshController.refreshCompleted();
            },
            header: WaterDropMaterialHeader(
              backgroundColor: theme.isDark
                  ? const Color(0xFF3700b3)
                  : const Color(0xFF537EC5),
              color: Colors.white,
              distance: 40.0,
            ),
            child: Scaffold(
              body: user.student?.hasTeam ?? false
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${project.projectData?.projectName}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            15.verticalSpace,
                            Text(
                              '${'description'.tr()}:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${project.projectData?.bio}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            20.verticalSpace,
                            ElevatedButton(
                              onPressed: () {
                                String description = '';
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    title: Text(
                                      '${'editDescription'.tr()}:',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    content: Form(
                                      key: formKey,
                                      child: TextFormField(
                                        initialValue: project.projectData?.bio,
                                        onSaved: (newValue) =>
                                            description = '$newValue',
                                        style: const TextStyle(
                                            color: Colors.black),
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          hintText: 'enterTeamDescription'.tr(),
                                          hintStyle: const TextStyle(
                                              color: Colors.black54),
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(
                                          'cancel'.tr(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          formKey.currentState?.save();
                                          await project.updateProjectData(
                                              projectID: project
                                                  .projectData?.projectID,
                                              bio: description);
                                          await project.loadProjectData(
                                              projectID: project
                                                  .projectData?.projectID);
                                          navigator.pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[700],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'save',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ).tr(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('editDescription'.tr()),
                            ),
                            15.verticalSpace,
                            Text(
                              '${'teamMembers'.tr()}:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            5.verticalSpace,
                            Wrap(
                              spacing: 8,
                              children: project.projectData?.members?.map(
                                    (member) {
                                      return FutureBuilder(
                                        future: user.getStudentByID(
                                            studentID: member),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else if (snapshot.hasData) {
                                            final student = snapshot.data!;
                                            return InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    content: SizedBox(
                                                      width: 400,
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              student.profilePicture !=
                                                                          null &&
                                                                      student.profilePicture !=
                                                                          ''
                                                                  ? GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        _showFullScreenImage(
                                                                            context,
                                                                            student.profilePicture!);
                                                                      },
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(100),
                                                                        child: Image
                                                                            .network(
                                                                          student
                                                                              .profilePicture!,
                                                                          width:
                                                                              100,
                                                                          height:
                                                                              100,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100),
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/images/defaultAvatar.png',
                                                                        width:
                                                                            100,
                                                                        height:
                                                                            100,
                                                                        color: Colors
                                                                            .black,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    '${student.firstName} ${student.lastName}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${student.major}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${student.projectLevel}',
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          15.verticalSpace,
                                                          Column(
                                                            children: [
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        8),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      400],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    const Text(
                                                                      'bio',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ).tr(),
                                                                    const SizedBox(
                                                                        height:
                                                                            8),
                                                                    Text(
                                                                      '${student.bio}',
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              15.verticalSpace,
                                                              const Text(
                                                                'skills',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ).tr(),
                                                              const SizedBox(
                                                                  height: 8),
                                                              Wrap(
                                                                spacing: 8,
                                                                children: student
                                                                    .canDo!
                                                                    .map(
                                                                        (skill) =>
                                                                            Chip(
                                                                              label: Text(skill),
                                                                              backgroundColor: const Color.fromARGB(255, 211, 122, 116),
                                                                            ))
                                                                    .toList(),
                                                              ),
                                                              if (auth.currentUser
                                                                      .uid !=
                                                                  student
                                                                      .studentUID)
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                              if (auth.currentUser
                                                                      .uid !=
                                                                  student
                                                                      .studentUID)
                                                                SizedBox(
                                                                  width: double
                                                                      .infinity,
                                                                  child:
                                                                      ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pushNamed(
                                                                          context,
                                                                          ChatPage
                                                                              .routeName,
                                                                          arguments: {
                                                                            'personUID':
                                                                                student.studentUID,
                                                                            'studentID':
                                                                                student.studentID,
                                                                            'firstName':
                                                                                student.firstName,
                                                                            'lastName':
                                                                                student.lastName,
                                                                            'chats':
                                                                                student.chats,
                                                                            'teamChat':
                                                                                false,
                                                                          });
                                                                    },
                                                                    child: const Text(
                                                                            'Send Message')
                                                                        .tr(),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Chip(
                                                label: Text(
                                                  '${student.firstName} ${student.lastName}',
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return const CircularProgressIndicator();
                                          }
                                        },
                                      );
                                    },
                                  ).toList() ??
                                  [],
                            ),
                            15.verticalSpace,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${'tasks'.tr()}:',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${project.projectData?.tasks?.length}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                )
                              ],
                            ),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: project.projectData?.tasks?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project.projectData?.tasks![index]
                                            ['taskName'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            project.projectData?.tasks![index]
                                                ['assignedTo'],
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(Icons.date_range,
                                              size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            project.projectData?.tasks![index]
                                                ['deadLine'],
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            20.verticalSpace,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${'Files'.tr()}:',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${project.projectData?.files?.length}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                )
                              ],
                            ),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: project.projectData?.files?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    _launchURL(project
                                        .projectData?.files![index]['url']);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 20),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                project.projectData
                                                    ?.files![index]['url'],
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  const Icon(Icons.person,
                                                      size: 16),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    project.projectData
                                                        ?.files![index]['from'],
                                                    style: const TextStyle(
                                                        fontSize: 16),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            PanaraConfirmDialog.show(
                                              context,
                                              color: Colors.red,
                                              textColor: Colors.black,
                                              title: "areYouSure".tr(),
                                              message: "removeFile?".tr(),
                                              confirmButtonText: "confirm".tr(),
                                              cancelButtonText: "cancel".tr(),
                                              onTapCancel: () {
                                                Navigator.pop(context);
                                              },
                                              onTapConfirm: () async {
                                                project.projectData?.files
                                                    ?.removeAt(index);
                                                await project.updateProjectData(
                                                    projectID: project
                                                        .projectData?.projectID,
                                                    files: project
                                                        .projectData?.files);
                                                await project.loadProjectData(
                                                    projectID: project
                                                        .projectData
                                                        ?.projectID);
                                                navigator.pop();
                                              },
                                              panaraDialogType:
                                                  PanaraDialogType.custom,
                                            );
                                          },
                                          icon: const Icon(
                                              Icons.remove_circle_outline),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            20.verticalSpace,
                            ElevatedButton(
                              onPressed: () {
                                String url = '';
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    title: Text(
                                      '${'Enter File URL'.tr()}:',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    content: Form(
                                      key: formKey,
                                      child: TextFormField(
                                        onSaved: (newValue) =>
                                            url = '$newValue',
                                        style: const TextStyle(
                                            color: Colors.black),
                                        maxLines: null,
                                        decoration: InputDecoration(
                                          hintText: 'File URL'.tr(),
                                          hintStyle: const TextStyle(
                                              color: Colors.black54),
                                          border: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                          ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide:
                                                BorderSide(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: Text(
                                          'cancel'.tr(),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          formKey.currentState?.save();
                                          if (url.startsWith('https://') ||
                                              url.startsWith('http://')) {
                                            Map<dynamic, dynamic> file = {
                                              'url': url,
                                              'from':
                                                  '${user.student?.firstName} ${user.student?.lastName}',
                                            };
                                            project.projectData?.files
                                                ?.add(file);
                                            await project.updateProjectData(
                                              projectID: project
                                                  .projectData?.projectID,
                                              files: project.projectData?.files,
                                            );
                                            await project.loadProjectData(
                                                projectID: project
                                                    .projectData?.projectID);
                                            navigator.pop();
                                          } else {
                                            Fluttertoast.showToast(
                                              msg:
                                                  'File url should start with https:// or http://',
                                              toastLength: Toast.LENGTH_LONG,
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red[700],
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'add',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ).tr(),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('Add File'.tr()),
                            ),
                            20.verticalSpace,
                            Text(
                              '${'supervisor'.tr()}:',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: project.projectData?.supervisorName ==
                                              null ||
                                          project.projectData?.supervisorName ==
                                              ''
                                      ? const Text('')
                                      : Text(
                                          'Dr. ${project.projectData?.supervisorName}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                ),
                                ElevatedButton(
                                  onPressed: project.projectData
                                                  ?.supervisorName ==
                                              null ||
                                          project.projectData?.supervisorName ==
                                              ''
                                      ? () {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const SupervisorsDialog(),
                                          );
                                        }
                                      : null,
                                  child: const Text('selectSupervisor').tr(),
                                ),
                                10.horizontalSpace,
                                ElevatedButton(
                                  onPressed: () {
                                    PanaraConfirmDialog.show(
                                      context,
                                      color: Colors.red,
                                      textColor: Colors.black,
                                      title: "areYouSure".tr(),
                                      message:
                                          "${'leaveTeam?'.tr()} ${project.projectData?.projectName}${'?'.tr()}",
                                      confirmButtonText: "confirm".tr(),
                                      cancelButtonText: "cancel".tr(),
                                      onTapCancel: () {
                                        Navigator.pop(context);
                                      },
                                      onTapConfirm: () async {
                                        project.projectData?.members
                                            ?.remove(user.student?.studentID);
                                        await project.updateProjectData(
                                            members:
                                                project.projectData?.members,
                                            projectID:
                                                project.projectData?.projectID);
                                        if (project.projectData?.members
                                                ?.isEmpty ??
                                            true) {
                                          await project.deleteProject();
                                        }
                                        user.student?.alerts?.removeWhere(
                                            (map) =>
                                                map['type'] == 'join' ||
                                                map['type'] == 'request');
                                        await user.updateStudentData(
                                            hasTeam: false,
                                            projectID: '',
                                            alerts: user.student?.alerts);
                                        navigator.pop();
                                      },
                                      panaraDialogType: PanaraDialogType.custom,
                                    );
                                  },
                                  child: const Text('leave').tr(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: const Text('youDontHaveTeam').tr(),
                    ),
            ),
          )
        // ! Instructor
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              title: const Text(
                'teamPage',
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
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${project.projectData?.projectName}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          '${project.projectData?.projectLevel}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    15.verticalSpace,
                    Text(
                      '${'description'.tr()}:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    5.verticalSpace,
                    Text(
                      '${project.projectData?.bio}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    20.verticalSpace,
                    Text(
                      '${'teamMembers'.tr()}:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    5.verticalSpace,
                    Wrap(
                      spacing: 8,
                      children: project.projectData?.members?.map(
                            (member) {
                              return FutureBuilder(
                                future: user.getStudentByID(studentID: member),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.hasData) {
                                    final student = snapshot.data!;
                                    return InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            content: SizedBox(
                                              width: 400,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      student.profilePicture !=
                                                                  null &&
                                                              student.profilePicture !=
                                                                  ''
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                _showFullScreenImage(
                                                                    context,
                                                                    student
                                                                        .profilePicture!);
                                                              },
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                child: Image
                                                                    .network(
                                                                  student
                                                                      .profilePicture!,
                                                                  width: 100,
                                                                  height: 100,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            )
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/defaultAvatar.png',
                                                                width: 100,
                                                                height: 100,
                                                                color: Colors
                                                                    .black,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            '${student.firstName} ${student.lastName}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${student.major}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Text(
                                                            '${student.projectLevel}',
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  15.verticalSpace,
                                                  Column(
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[400],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            const Text(
                                                              'bio',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ).tr(),
                                                            const SizedBox(
                                                                height: 8),
                                                            Text(
                                                              '${student.bio}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      15.verticalSpace,
                                                      const Text(
                                                        'skills',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ).tr(),
                                                      const SizedBox(height: 8),
                                                      Wrap(
                                                        spacing: 8,
                                                        children: student.canDo!
                                                            .map(
                                                                (skill) => Chip(
                                                                      label: Text(
                                                                          skill),
                                                                      backgroundColor: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          211,
                                                                          122,
                                                                          116),
                                                                    ))
                                                            .toList(),
                                                      ),
                                                      if (auth.currentUser
                                                              .uid !=
                                                          student.studentUID)
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                      if (auth.currentUser
                                                              .uid !=
                                                          student.studentUID)
                                                        SizedBox(
                                                          width:
                                                              double.infinity,
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  ChatPage
                                                                      .routeName,
                                                                  arguments: {
                                                                    'personUID':
                                                                        student
                                                                            .studentUID,
                                                                    'studentID':
                                                                        student
                                                                            .studentID,
                                                                    'firstName':
                                                                        student
                                                                            .firstName,
                                                                    'lastName':
                                                                        student
                                                                            .lastName,
                                                                    'chats':
                                                                        student
                                                                            .chats,
                                                                    'teamChat':
                                                                        false,
                                                                  });
                                                            },
                                                            child: const Text(
                                                                    'Send Message')
                                                                .tr(),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      child: Chip(
                                        label: Text(
                                          '${student.firstName} ${student.lastName}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const Text('No data');
                                  }
                                },
                              );
                            },
                          ).toList() ??
                          [],
                    ),
                    15.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'tasks'.tr()}:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${project.projectData?.tasks?.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      ],
                    ),
                    5.verticalSpace,
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: project.projectData?.tasks?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      project.projectData?.tasks![index]
                                          ['taskName'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          project.projectData?.tasks![index]
                                              ['assignedTo'],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.date_range, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          project.projectData?.tasks![index]
                                              ['deadLine'],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  PanaraConfirmDialog.show(
                                    context,
                                    color: Colors.red,
                                    textColor: Colors.black,
                                    title: "areYouSure".tr(),
                                    message: "removeTask?".tr(),
                                    confirmButtonText: "confirm".tr(),
                                    cancelButtonText: "cancel".tr(),
                                    onTapCancel: () {
                                      Navigator.pop(context);
                                    },
                                    onTapConfirm: () async {
                                      project.projectData?.tasks
                                          ?.removeAt(index);
                                      await project.updateProjectData(
                                          projectID:
                                              project.projectData?.projectID,
                                          tasks: project.projectData?.tasks);
                                      await project.loadProjectData(
                                          projectID:
                                              project.projectData?.projectID);
                                      navigator.pop();
                                    },
                                    panaraDialogType: PanaraDialogType.custom,
                                  );
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    AddTaskDialog(project: project),
                              );
                            },
                            child: const Text('addTask').tr(),
                          ),
                        ),
                      ],
                    ),
                    20.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'Files'.tr()}:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${project.projectData?.files?.length}',
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      ],
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: project.projectData?.files?.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            _launchURL(
                                project.projectData?.files![index]['url']);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project.projectData?.files![index]
                                            ['url'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(Icons.person, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            project.projectData?.files![index]
                                                ['from'],
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    PanaraConfirmDialog.show(
                                      context,
                                      color: Colors.red,
                                      textColor: Colors.black,
                                      title: "areYouSure".tr(),
                                      message: "removeFile?".tr(),
                                      confirmButtonText: "confirm".tr(),
                                      cancelButtonText: "cancel".tr(),
                                      onTapCancel: () {
                                        Navigator.pop(context);
                                      },
                                      onTapConfirm: () async {
                                        project.projectData?.files
                                            ?.removeAt(index);
                                        await project.updateProjectData(
                                            projectID:
                                                project.projectData?.projectID,
                                            files: project.projectData?.files);
                                        await project.loadProjectData(
                                            projectID:
                                                project.projectData?.projectID);
                                        navigator.pop();
                                      },
                                      panaraDialogType: PanaraDialogType.custom,
                                    );
                                  },
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    20.verticalSpace,
                    ElevatedButton(
                      onPressed: () {
                        String url = '';
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: Text(
                              '${'Enter File URL'.tr()}:',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            content: Form(
                              key: formKey,
                              child: TextFormField(
                                onSaved: (newValue) => url = '$newValue',
                                style: const TextStyle(color: Colors.black),
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: 'File URL'.tr(),
                                  hintStyle:
                                      const TextStyle(color: Colors.black54),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'cancel'.tr(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  formKey.currentState?.save();
                                  if (url.startsWith('https://') ||
                                      url.startsWith('http://')) {
                                    formKey.currentState?.save();
                                    Map<dynamic, dynamic> file = {
                                      'url': url,
                                      'from':
                                          'Dr. ${user.instructor?.firstName} ${user.instructor?.lastName}',
                                    };
                                    project.projectData?.files?.add(file);
                                    await project.updateProjectData(
                                      projectID: project.projectData?.projectID,
                                      files: project.projectData?.files,
                                    );
                                    await project.loadProjectData(
                                        projectID:
                                            project.projectData?.projectID);
                                    navigator.pop();
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          'File url should start with https:// or http://',
                                      toastLength: Toast.LENGTH_LONG,
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'add',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ).tr(),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text('Add File'.tr()),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      '${'supervisor'.tr()}:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Dr. ${user.instructor?.firstName} ${user.instructor?.lastName}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            bool left = false;
                            await PanaraConfirmDialog.show(
                              context,
                              color: Colors.red,
                              textColor: Colors.black,
                              title: "areYouSure".tr(),
                              message:
                                  "${'leaveTeam?'.tr()} ${project.projectData?.projectName}${'?'.tr()}",
                              confirmButtonText: "confirm".tr(),
                              cancelButtonText: "cancel".tr(),
                              onTapCancel: () {
                                Navigator.pop(context);
                              },
                              onTapConfirm: () async {
                                user.instructor?.teams
                                    ?.remove(project.projectData?.projectID);
                                await user.updateInstructorData(
                                    numberOfTeams:
                                        (user.instructor?.numberOfTeams)! - 1,
                                    teams: user.instructor?.teams);
                                await project.updateProjectData(
                                    projectID: project.projectData?.projectID,
                                    supervisorName: '');
                                left = true;
                                navigator.pop();
                              },
                              panaraDialogType: PanaraDialogType.custom,
                            );
                            if (left) {
                              navigator.pop();
                            }
                          },
                          child: const Text('leave').tr(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
