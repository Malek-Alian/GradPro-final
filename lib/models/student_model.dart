class StudentModel {
  StudentModel(
      {this.studentID,
      this.studentUID,
      this.firstName,
      this.lastName,
      this.major,
      this.projectID,
      this.projectLevel,
      this.hasTeam,
      this.registered,
      this.profilePicture,
      this.bio,
      this.canDo,
      this.token,
      this.alerts,
      this.chats});

  String? studentUID;
  String? studentID;
  String? firstName;
  String? lastName;
  String? major;
  String? projectID;
  String? projectLevel;
  String? profilePicture;
  String? bio;
  String? token;
  bool? hasTeam;
  bool? registered;
  List<dynamic>? canDo;
  List<dynamic>? alerts;
  List<dynamic>? chats;

  StudentModel.fromMap(Map<String, dynamic> data)
      : assert(data.isNotEmpty),
        studentUID = data['studentUID'],
        studentID = data['studentID'],
        firstName = data['firstName'],
        lastName = data['lastName'],
        major = data['major'],
        projectID = data['projectID'],
        projectLevel = data['projectLevel'],
        hasTeam = data['hasTeam'],
        registered = data['registered'],
        profilePicture = data['profilePicture'],
        bio = data['bio'],
        canDo = data['canDo'],
        token = data['token'],
        alerts = data['alerts'],
        chats = data['chats'];

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['studentUID'] = studentUID;
    data['studentID'] = studentID;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['major'] = major;
    data['projectID'] = projectID;
    data['projectLevel'] = projectLevel;
    data['hasTeam'] = hasTeam;
    data['registered'] = registered;
    data['profilePicture'] = profilePicture;
    data['bio'] = bio;
    data['canDo'] = canDo;
    data['token'] = token;
    data['alerts'] = alerts;
    data['chats'] = chats;
    return data;
  }
}
