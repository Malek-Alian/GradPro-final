import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/services/firebase/user_auth.dart';
import 'package:graduation_project/shared_view/chat_page/chat_page.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';

import '../../../models/instructor_model.dart';
import '../../../services/firebase/projects_firestore.dart';
import '../../../services/firebase/users_firestore.dart';

class SupervisorsDialog extends StatelessWidget {
  const SupervisorsDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final UserAuth auth = Provider.of<UserAuth>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final ProjectsFirestore project = Provider.of<ProjectsFirestore>(context);
    final navigator = Navigator.of(context);

    void showFullScreenImage(BuildContext context, String image) {
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

    return AlertDialog(
      scrollable: true,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 400,
        height: 350,
        child: StreamBuilder(
          stream: user.getInstructors,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              List<InstructorModel> instructorData = snapshot.data ?? [];
              return ListView.builder(
                itemCount: instructorData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: ListTile(
                      leading: instructorData[index].profilePicture != null &&
                              instructorData[index].profilePicture != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(53),
                              child: Image.network(
                                instructorData[index].profilePicture!,
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
                                color: Colors.black,
                                fit: BoxFit.cover,
                              ),
                            ),
                      title: Text(
                        'Dr. ${instructorData[index].firstName}',
                        style: const TextStyle(color: Colors.black),
                      ),
                      trailing: OutlinedButton(
                        onPressed: () {
                          PanaraConfirmDialog.show(
                            context,
                            color: Colors.red,
                            textColor: Colors.black,
                            title: "areYouSure".tr(),
                            message:
                                "${'ask?'.tr()} ${instructorData[index].firstName} ${instructorData[index].lastName} ${'teamSupervisor?'.tr()}",
                            confirmButtonText: "confirm".tr(),
                            cancelButtonText: "cancel".tr(),
                            onTapCancel: () {
                              Navigator.pop(context);
                            },
                            onTapConfirm: () async {
                              await user.updateInstructorByEmail(
                                instructorEmail:
                                    instructorData[index].instructorEmail,
                                alert: {
                                  'projectID':
                                      '${project.projectData?.projectID}',
                                  'title':
                                      '${project.projectData?.projectName}',
                                  'body':
                                      'Hi, I\'m ${user.student?.firstName} ${user.student?.lastName}, Would you be our team supervisor ?',
                                  'picture': '${user.student?.profilePicture}',
                                  'type': 'ask',
                                },
                              );
                              navigator.pop();
                              Fluttertoast.showToast(
                                msg:
                                    'Invitation sent to Dr. ${instructorData[index].firstName} ${instructorData[index].lastName}',
                                toastLength: Toast.LENGTH_LONG,
                              );
                            },
                            panaraDialogType: PanaraDialogType.custom,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            width: 2,
                            color: Colors.black,
                          ),
                        ),
                        child: const Text('ask').tr(),
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: SizedBox(
                              width: 400,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        instructorData[index].profilePicture !=
                                                    null &&
                                                instructorData[index]
                                                        .profilePicture !=
                                                    ''
                                            ? GestureDetector(
                                                onTap: () {
                                                  showFullScreenImage(
                                                      context,
                                                      instructorData[index]
                                                          .profilePicture!);
                                                },
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Image.network(
                                                    instructorData[index]
                                                        .profilePicture!,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Image.asset(
                                                  'assets/images/defaultAvatar.png',
                                                  width: 100,
                                                  height: 100,
                                                  color: Colors.black,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Dr. ${instructorData[index].firstName} ${instructorData[index].lastName}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '${instructorData[index].major}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  15.verticalSpace,
                                  Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[400],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'bio',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ).tr(),
                                            const SizedBox(height: 8),
                                            Text(
                                              '${instructorData[index].bio}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      15.verticalSpace,
                                      const Text(
                                        'teams',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ).tr(),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: instructorData[index]
                                                .teams
                                                ?.map(
                                              (team) {
                                                return FutureBuilder(
                                                  future: project
                                                      .getProjectByID(team),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const CircularProgressIndicator();
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                          'Error: ${snapshot.error}');
                                                    } else if (snapshot
                                                        .hasData) {
                                                      final project =
                                                          snapshot.data!;
                                                      return Chip(
                                                        label: Text(
                                                          '${project.projectName}',
                                                        ),
                                                        backgroundColor:
                                                            const Color
                                                                .fromARGB(255,
                                                                211, 122, 116),
                                                      );
                                                    } else {
                                                      return const Text(
                                                          'No data');
                                                    }
                                                  },
                                                );
                                              },
                                            ).toList() ??
                                            [],
                                      ),
                                      if (auth.currentUser.uid !=
                                          instructorData[index].instructorUID)
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      if (auth.currentUser.uid !=
                                          instructorData[index].instructorUID)
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, ChatPage.routeName,
                                                  arguments: {
                                                    'personUID':
                                                        instructorData[index]
                                                            .instructorUID,
                                                    'instructorEmail':
                                                        instructorData[index]
                                                            .instructorEmail,
                                                    'firstName':
                                                        instructorData[index]
                                                            .firstName,
                                                    'lastName':
                                                        instructorData[index]
                                                            .lastName,
                                                    'chats':
                                                        instructorData[index]
                                                            .chats,
                                                    'teamChat': false,
                                                  });
                                            },
                                            child:
                                                const Text('Send Message').tr(),
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
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(user.errorMessage),
              );
            }
          },
        ),
      ),
    );
  }
}
