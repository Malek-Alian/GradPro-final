class InstructorModel {
  InstructorModel(
      {this.instructorEmail,
      this.instructorUID,
      this.firstName,
      this.lastName,
      this.major,
      this.numberOfTeams,
      this.registered,
      this.profilePicture,
      this.bio,
      this.teams,
      this.token,
      this.alerts,
      this.chats});

  String? instructorUID;
  String? instructorEmail;
  String? firstName;
  String? lastName;
  String? major;
  String? profilePicture;
  String? bio;
  String? token;
  int? numberOfTeams;
  bool? registered;
  List<dynamic>? teams;
  List<dynamic>? alerts;
  List<dynamic>? chats;

  InstructorModel.fromMap(Map<String, dynamic> data)
      : assert(data.isNotEmpty),
        instructorUID = data['instructorUID'],
        instructorEmail = data['instructorEmail'],
        firstName = data['firstName'],
        lastName = data['lastName'],
        major = data['major'],
        numberOfTeams = data['numberOfTeams'],
        registered = data['registered'],
        profilePicture = data['profilePicture'],
        bio = data['bio'],
        teams = data['teams'],
        token = data['token'],
        alerts = data['alerts'],
        chats = data['chats'];

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['instructorUID'] = instructorUID;
    data['instructorEmail'] = instructorEmail;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['major'] = major;
    data['numberOfTeams'] = numberOfTeams;
    data['registered'] = registered;
    data['profilePicture'] = profilePicture;
    data['bio'] = bio;
    data['teams'] = teams;
    data['token'] = token;
    data['alerts'] = alerts;
    data['chats'] = chats;
    return data;
  }
}
