import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/services/firebase/user_auth.dart';
import 'package:graduation_project/shared_view/chat_page/chat_page.dart';
import 'package:provider/provider.dart';

import '../../../models/project_model.dart';
import '../../../services/firebase/users_firestore.dart';

class TeamDialog extends StatelessWidget {
  const TeamDialog({super.key, required this.projectData, required this.index});

  final List<ProjectModel> projectData;
  final int index;

  void _showFullScreenImage(BuildContext context, student) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.network(
              student.profilePicture!,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserAuth auth = Provider.of<UserAuth>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);

    return AlertDialog(
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '${projectData[index].major}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${projectData[index].projectName}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${projectData[index].projectLevel}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            15.verticalSpace,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'description',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ).tr(),
                  const SizedBox(height: 8),
                  Text(
                    '${projectData[index].bio}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'members',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ).tr(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: projectData[index]
                  .members!
                  .map((member) => FutureBuilder(
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
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              student.profilePicture != null &&
                                                      student.profilePicture !=
                                                          ''
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        _showFullScreenImage(
                                                            context, student);
                                                      },
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        child: Image.network(
                                                          student
                                                              .profilePicture!,
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '${student.firstName} ${student.lastName}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${student.major}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${student.projectLevel}',
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
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
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ).tr(),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      '${student.bio}',
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
                                                'skills',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ).tr(),
                                              const SizedBox(height: 8),
                                              Wrap(
                                                spacing: 8,
                                                children: student.canDo!
                                                    .map((skill) => Chip(
                                                          label: Text(skill),
                                                          backgroundColor:
                                                              const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  211,
                                                                  122,
                                                                  116),
                                                        ))
                                                    .toList(),
                                              ),
                                              if (user.student?.studentUID !=
                                                      null ||
                                                  user.instructor
                                                          ?.instructorUID !=
                                                      null)
                                                if (auth.currentUser.uid !=
                                                    student.studentUID)
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                              if (user.student?.studentUID !=
                                                      null ||
                                                  user.instructor
                                                          ?.instructorUID !=
                                                      null)
                                                if (auth.currentUser.uid !=
                                                    student.studentUID)
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            ChatPage.routeName,
                                                            arguments: {
                                                              'personUID': student
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
                                                                  student.chats,
                                                              'teamChat': false,
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
                                ),
                                backgroundColor:
                                    const Color.fromARGB(255, 211, 122, 116),
                              ),
                            );
                          } else {
                            return const Text('No data');
                          }
                        },
                      ))
                  .toList(),
            ),
            projectData[index].supervisorName != ''
                ? Column(
                    children: [
                      const SizedBox(height: 15),
                      const Text(
                        'Supervisor',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ).tr(),
                      const SizedBox(height: 8),
                      Text(
                        'Dr. ${projectData[index].supervisorName}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
