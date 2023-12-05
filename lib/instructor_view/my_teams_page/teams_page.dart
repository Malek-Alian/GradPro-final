import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/services/theme/change_theme.dart';
import 'package:provider/provider.dart';

import '../../models/project_model.dart';
import '../../services/firebase/projects_firestore.dart';
import '../../services/firebase/users_firestore.dart';
import '../../shared_view/my_team_page/my_team_page.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    final UsersFirestore user = Provider.of<UsersFirestore>(context);
    final ProjectsFirestore project = Provider.of<ProjectsFirestore>(context);
    final ChangeTheme theme = Provider.of<ChangeTheme>(context);
    final navigator = Navigator.of(context);

    return Scaffold(
      body: (user.instructor?.numberOfTeams) == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (user.instructor?.numberOfTeams)! > 0
              ? ListView.builder(
                  itemCount: user.instructor?.numberOfTeams,
                  itemBuilder: (context, index) {
                    final projectFuture =
                        project.getProjectByID(user.instructor?.teams![index]);
                    ProjectModel? projectData;
                    return FutureBuilder(
                      future: projectFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasData) {
                          projectData = snapshot.data;
                          return ListTile(
                            leading: const Icon(Icons.groups),
                            title: Text(
                              '${projectData?.projectName}',
                              style: TextStyle(
                                color:
                                    theme.isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            trailing: Text(
                              '${projectData?.projectLevel}',
                              style: TextStyle(
                                fontSize: 17,
                                color:
                                    theme.isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            onTap: () async {
                              await project.loadProjectData(
                                  projectID: projectData?.projectID);
                              navigator.pushNamed(MyTeamPage.routeName);
                            },
                          );
                        } else {
                          return Center(
                            child: Text(project.errorMessage),
                          );
                        }
                      },
                    );
                  },
                )
              : Center(
                  child: const Text(
                    'youDontHaveTeams',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ).tr(),
                ),
    );
  }
}
