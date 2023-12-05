import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/firebase/projects_firestore.dart';
import 'package:provider/provider.dart';

import '../../../services/firebase/users_firestore.dart';
import 'change_image_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String routeName = 'Profile Page';

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final ProjectsFirestore project = Provider.of<ProjectsFirestore>(context);
    final List<dynamic>? list =
        user.isStudent() ? user.student?.canDo! : user.instructor?.teams!;
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'profile',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Stack(
              children: [
                ClipOval(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFC2E8FF), Color(0xFFE0FFFF)],
                      ),
                    ),
                    child: user.isStudent()
                        ? user.student?.profilePicture != null &&
                                user.student?.profilePicture != ''
                            ? Image.network(
                                '${user.student?.profilePicture}',
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/defaultAvatar.png',
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              )
                        : user.instructor?.profilePicture != null &&
                                user.instructor?.profilePicture != ''
                            ? Image.network(
                                '${user.instructor?.profilePicture}',
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/defaultAvatar.png',
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    height: 46,
                    width: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ChangeImageDialog(user: user);
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '${user.student?.firstName ?? 'Dr. ${user.instructor?.firstName}'} ${user.instructor?.lastName ?? user.student?.lastName}',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${user.instructor?.major ?? user.student?.major}',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'bio',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ).tr(),
                  const SizedBox(height: 20),
                  Text(
                    '${user.student?.bio ?? user.instructor?.bio}',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          String bio = '';
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              title: const Text(
                                'editBio',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ).tr(),
                              content: Form(
                                key: formKey,
                                child: TextFormField(
                                  initialValue: user.isStudent()
                                      ? user.student?.bio != ''
                                          ? user.student?.bio
                                          : null
                                      : user.instructor?.bio != ''
                                          ? user.instructor?.bio
                                          : null,
                                  onSaved: (newValue) => bio = '$newValue',
                                  style: const TextStyle(color: Colors.black),
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: 'enterYourBio'.tr(),
                                    hintStyle:
                                        const TextStyle(color: Colors.black54),
                                    border: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(16)),
                                      borderSide:
                                          BorderSide(color: Colors.black),
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
                                    if (user.isStudent()) {
                                      await user.updateStudentData(bio: bio);
                                    } else {
                                      await user.updateInstructorData(bio: bio);
                                    }
                                    navigator.pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
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
                        child: const Text('editBio').tr(),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.isStudent() ? 'skills'.tr() : 'teams'.tr(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      user.isStudent()
                          ? Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: list!
                                  .map((skill) => Chip(
                                        label: Text(
                                          skill,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ))
                                  .toList()
                                  .cast<Widget>(),
                            )
                          : Wrap(
                              spacing: 8,
                              children: user.instructor?.teams?.map(
                                    (team) {
                                      return FutureBuilder(
                                        future: project.getProjectByID(team),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else if (snapshot.hasData) {
                                            final project = snapshot.data!;
                                            return Chip(
                                              label: Text(
                                                '${project.projectName}',
                                                style: const TextStyle(
                                                  color: Colors.black,
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
                      const SizedBox(height: 20),
                      user.isStudent()
                          ? ElevatedButton(
                              onPressed: () async {
                                await user.loadStudentData();
                                String skill = '';
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          title: const Text(
                                            'editSkills',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ).tr(),
                                          content: Form(
                                            key: formKey,
                                            child: SizedBox(
                                              width: 400,
                                              height: 300,
                                              child: Column(
                                                children: [
                                                  Expanded(
                                                    child: ListView.builder(
                                                      itemCount: user.student
                                                          ?.canDo?.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ListTile(
                                                          tileColor:
                                                              Colors.grey[350],
                                                          title: Text(
                                                            user.student
                                                                ?.canDo?[index],
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                          trailing: IconButton(
                                                            onPressed: () {
                                                              user.student
                                                                  ?.canDo
                                                                  ?.removeAt(
                                                                      index);
                                                              setState(() {
                                                                user.student
                                                                    ?.canDo;
                                                              });
                                                            },
                                                            icon: const Icon(
                                                              Icons
                                                                  .remove_circle_outline,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          onSaved: (newValue) =>
                                                              skill =
                                                                  '$newValue',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black),
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                'enterSkill'
                                                                    .tr(),
                                                            hintStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .black54),
                                                            border:
                                                                const OutlineInputBorder(),
                                                            enabledBorder:
                                                                const OutlineInputBorder(
                                                              borderSide: BorderSide(
                                                                  width: 2,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      10.horizontalSpace,
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          formKey.currentState
                                                              ?.save();
                                                          user.student?.canDo
                                                              ?.add(skill);
                                                          setState(() {
                                                            user.student?.canDo;
                                                          });
                                                        },
                                                        child: const Text(
                                                                'addSkill')
                                                            .tr(),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text(
                                                'cancel',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red,
                                                ),
                                              ).tr(),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await user.updateStudentData(
                                                    canDo: user.student?.canDo);
                                                navigator.pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red[700],
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
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              child: const Text('editSkills').tr(),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
