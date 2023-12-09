import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:graduation_project/models/student_model.dart';
import 'package:graduation_project/services/firebase/user_auth.dart';
import 'package:graduation_project/services/firebase/users_firestore.dart';
import 'package:graduation_project/shared_view/chat_page/chat_page.dart';
import 'package:provider/provider.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  static const String routeName = 'About Us';

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final UsersFirestore usersFirestore = UsersFirestore();
  List<StudentModel> team = [];

  void _showFullScreenImage(BuildContext context, image) {
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

  void fetchStudentData() async {
    final malek = await usersFirestore.getStudentByID(studentID: '2035009');
    final rania = await usersFirestore.getStudentByID(studentID: '2034291');
    final ali = await usersFirestore.getStudentByID(studentID: '2035074');
    final mohannad = await usersFirestore.getStudentByID(studentID: '2035035');
    setState(() {
      team.addAll([malek, rania, ali, mohannad]);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  @override
  Widget build(BuildContext context) {
    final UserAuth auth = Provider.of<UserAuth>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'aboutUs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ).tr(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'aboutUs',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEA5455),
                  ),
                ).tr(),
                const SizedBox(height: 50.0),
                SvgPicture.asset(
                  'assets/images/logo.svg',
                  width: 200,
                ),
                const SizedBox(height: 50.0),
                Text(
                  'aboutUsBio'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                const SizedBox(height: 30.0),
                const Text(
                  'meetOurTeam',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEA5455),
                  ),
                ).tr(),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceEvenly, // Adjust the alignment as needed
                  children: team.isEmpty
                      ? [
                          const Column(
                            children: [
                              CircleAvatar(
                                radius: 30.0,
                                backgroundImage: AssetImage(
                                    'assets/images/defaultAvatar.png'),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Malek',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Column(
                            children: [
                              CircleAvatar(
                                radius: 30.0,
                                backgroundImage: AssetImage(
                                    'assets/images/defaultAvatar.png'),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Rania',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Column(
                            children: [
                              CircleAvatar(
                                radius: 30.0,
                                backgroundImage: AssetImage(
                                    'assets/images/defaultAvatar.png'),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Ali',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Column(
                            children: [
                              CircleAvatar(
                                radius: 30.0,
                                backgroundImage: AssetImage(
                                    'assets/images/defaultAvatar.png'),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Mohannad',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ]
                      : team
                          .map(
                            (student) => Column(
                              children: [
                                GestureDetector(
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
                                                                    .profilePicture);
                                                          },
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100),
                                                            child:
                                                                Image.network(
                                                              student.profilePicture ??
                                                                  '',
                                                              width: 100,
                                                              height: 100,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        )
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
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
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[400],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
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
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ).tr(),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          '${student.bio}',
                                                          style:
                                                              const TextStyle(
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ).tr(),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    children: student.canDo!
                                                        .map((skill) => Chip(
                                                              label:
                                                                  Text(skill),
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
                                                  if (user.student
                                                              ?.studentUID !=
                                                          null ||
                                                      user.instructor
                                                              ?.instructorUID !=
                                                          null)
                                                    if (auth.currentUser.uid !=
                                                        student.studentUID)
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                  if (user.student
                                                              ?.studentUID !=
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
                                  child: CircleAvatar(
                                    radius: 30.0,
                                    backgroundImage: student.profilePicture !=
                                            ''
                                        ? NetworkImage(student.profilePicture!)
                                        : const AssetImage(
                                                'assets/images/defaultAvatar.png')
                                            as ImageProvider,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${student.firstName}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
