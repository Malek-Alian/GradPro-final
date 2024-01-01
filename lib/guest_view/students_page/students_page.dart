import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/student_model.dart';
import '../../services/firebase/users_firestore.dart';
import '../../services/theme/change_theme.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final UsersFirestore user = Provider.of<UsersFirestore>(context);

    return StreamBuilder(
      stream: user.getStudentsForGuest,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          List<StudentModel> studentData = snapshot.data ?? [];
          return ListView.builder(
            itemCount: studentData.length,
            itemBuilder: (context, index) {
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
                                  studentData[index].profilePicture != null &&
                                          studentData[index].profilePicture !=
                                              ''
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Image.network(
                                            studentData[index].profilePicture!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
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
                                        '${studentData[index].firstName} ${studentData[index].lastName}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${studentData[index].major}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${studentData[index].projectLevel}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(8),
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
                                          '${studentData[index].bio}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  15.verticalSpace,
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
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
                                        children: studentData[index]
                                            .canDo!
                                            .map((skill) => Chip(
                                                  label: Text(skill),
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                          255, 211, 122, 116),
                                                ))
                                            .toList(),
                                      ),
                                    ],
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
    );
  }
}
