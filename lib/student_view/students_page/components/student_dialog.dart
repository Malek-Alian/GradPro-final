import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:graduation_project/services/firebase/user_auth.dart';
import 'package:graduation_project/shared_view/chat_page/chat_page.dart';
import 'package:provider/provider.dart';

import '../../../models/student_model.dart';

class StudentDialog extends StatelessWidget {
  const StudentDialog(
      {super.key, required this.studentData, required this.index});

  final List<StudentModel> studentData;
  final int index;

  void _showFullScreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.network(
              studentData[index].profilePicture ?? '',
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

    return AlertDialog(
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                studentData[index].profilePicture != null &&
                        studentData[index].profilePicture != ''
                    ? GestureDetector(
                        onTap: () {
                          _showFullScreenImage(context);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            studentData[index].profilePicture ?? '',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'assets/images/defaultAvatar.png',
                          width: 100,
                          height: 100,
                          color: Colors.black,
                          fit: BoxFit.cover,
                        ),
                      ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                const Color.fromARGB(255, 211, 122, 116),
                          ))
                      .toList(),
                ),
                if (auth.currentUser.uid != studentData[index].studentUID)
                  const SizedBox(
                    height: 10,
                  ),
                if (auth.currentUser.uid != studentData[index].studentUID)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, ChatPage.routeName,
                            arguments: {
                              'personUID': studentData[index].studentUID,
                              'studentID': studentData[index].studentID,
                              'firstName': studentData[index].firstName,
                              'lastName': studentData[index].lastName,
                              'chats': studentData[index].chats,
                              'teamChat': false,
                            });
                      },
                      child: const Text('Send Message').tr(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
