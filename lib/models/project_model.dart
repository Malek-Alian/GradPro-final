class ProjectModel {
  ProjectModel(
      {this.projectID,
      this.projectName,
      this.bio,
      this.rate,
      this.createdAt,
      this.supervisorName,
      this.major,
      this.projectLevel,
      this.members,
      this.tasks,
      this.files});

  String? projectID;
  String? projectName;
  String? bio;
  String? supervisorName;
  String? projectLevel;
  String? major;
  int? rate;
  int? createdAt;
  List<dynamic>? members;
  List<dynamic>? tasks;
  List<dynamic>? files;

  ProjectModel.fromMap(Map<String, dynamic> data)
      : assert(data.isNotEmpty),
        projectID = data['projectID'],
        projectName = data['projectName'],
        bio = data['bio'],
        rate = data['rate'],
        createdAt = data['createdAt'],
        supervisorName = data['supervisorName'],
        projectLevel = data['projectLevel'],
        major = data['major'],
        members = data['members'],
        tasks = data['tasks'],
        files = data['files'];

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['projectID'] = projectID;
    data['projectName'] = projectName;
    data['bio'] = bio;
    data['rate'] = rate;
    data['createdAt'] = createdAt;
    data['supervisorName'] = supervisorName;
    data['major'] = major;
    data['projectLevel'] = projectLevel;
    data['members'] = members;
    data['tasks'] = tasks;
    data['files'] = files;
    return data;
  }
}
