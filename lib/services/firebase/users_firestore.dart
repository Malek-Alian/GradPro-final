import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/instructor_model.dart';
import '../../models/student_model.dart';
import 'user_auth.dart';

class UsersFirestore extends ChangeNotifier {
  final CollectionReference _studentCollection =
      FirebaseFirestore.instance.collection('Student');
  final CollectionReference _instructorCollection =
      FirebaseFirestore.instance.collection('Instructor');
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  StudentModel? student;
  InstructorModel? instructor;
  bool isLoading = false;
  String errorMessage = '';

  set setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  set setMessage(String value) {
    errorMessage = value;
    notifyListeners();
  }

  bool isStudent() {
    final User user = UserAuth().currentUser;
    return user.email?.contains('std') ?? false;
  }

  Future<dynamic> getPersonByUID({required String uid}) async {
    final studentSnapshot = await _studentCollection
        .where('studentUID', isEqualTo: uid)
        .limit(1)
        .get();

    if (studentSnapshot.docs.isNotEmpty) {
      return StudentModel.fromMap(
          studentSnapshot.docs.first.data() as Map<String, dynamic>);
    }

    final instructorSnapshot = await _instructorCollection
        .where('instructorUID', isEqualTo: uid)
        .limit(1)
        .get();

    if (instructorSnapshot.docs.isNotEmpty) {
      return InstructorModel.fromMap(
          instructorSnapshot.docs.first.data() as Map<String, dynamic>);
    }

    return null;
  }

  // ! Guest
  Stream<List<StudentModel>?> get getStudentsForGuest {
    return _studentCollection
        .where('registered', isEqualTo: true)
        .where('hasTeam', isEqualTo: false)
        .orderBy('firstName')
        .snapshots()
        .map(_studentListFromSnapshot);
  }

  // ! Student
  Future<void> addStudent() async {
    Map<String, dynamic> userData = {
      'firstName': 'اريج',
      'lastName': 'داود',
      'major': 'CIS',
      'projectLevel': '1',
      'studentID': '2035292',
      'studentUID': 'XmhJXBWYiZbPwMJyIucvbqvmz4i2',
      'bio': '',
      'hasTeam': false,
      'registered': true,
      'profilePicture': '',
      'projectID': '',
      'token': '',
      'alerts': [],
      'chats': [],
      'canDo': [],
    };

    await _studentCollection.add(userData);
  }

  Future<void> addInstructor() async {
    Map<String, dynamic> userData = {
      'firstName': '',
      'lastName': '',
      'major': '',
      'instructorEmail': '',
      'instructorUID': '',
      'bio': '',
      'numberOfTeams': 0,
      'registered': false,
      'profilePicture': '',
      'token': '',
      'alerts': [],
      'chats': [],
      'teams': [],
    };

    await _instructorCollection.add(userData);
  }

  Future<void> loadStudentData() async {
    final User user = UserAuth().currentUser;
    QuerySnapshot querySnapshot = await _studentCollection
        .where('studentUID', isEqualTo: user.uid)
        .limit(1)
        .get();
    student = StudentModel.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> updateStudentData(
      {bool? registered,
      String? path,
      bool? hasTeam,
      String? projectID,
      String? token,
      List<dynamic>? alerts,
      String? bio,
      List<dynamic>? canDo,
      List<dynamic>? chats}) async {
    final User user = UserAuth().currentUser;
    final docSnap = await _studentCollection
        .where('studentUID', isEqualTo: user.uid)
        .limit(1)
        .get();
    final doc = docSnap.docs.first;
    if (registered != null) {
      doc.reference.update({'registered': true});
    }
    if (path != null) {
      doc.reference.update({'profilePicture': path});
    }
    if (hasTeam != null) {
      doc.reference.update({'hasTeam': hasTeam});
    }
    if (projectID != null) {
      doc.reference.update({'projectID': projectID});
    }
    if (token != null) {
      doc.reference.update({'token': token});
    }
    if (alerts != null) {
      doc.reference.update({'alerts': alerts});
    }
    if (bio != null) {
      doc.reference.update({'bio': bio});
    }
    if (canDo != null) {
      doc.reference.update({'canDo': canDo});
    }
    if (chats != null) {
      doc.reference.update({'chats': chats});
    }
    loadStudentData();
  }

  Future<void> updateStudentByID(
      {required String? studentID,
      Map<dynamic, dynamic>? alert,
      List<dynamic>? chats,
      bool? hasTeam,
      String? projectID}) async {
    final docSnap = await _studentCollection
        .where('studentID', isEqualTo: studentID)
        .limit(1)
        .get();
    final doc = docSnap.docs.first;
    StudentModel student =
        StudentModel.fromMap(docSnap.docs.first.data() as Map<String, dynamic>);
    if (alert != null) {
      student.alerts?.add(alert);
      doc.reference.update({'alerts': student.alerts});
    }
    if (hasTeam != null) {
      doc.reference.update({'hasTeam': hasTeam});
    }
    if (projectID != null) {
      doc.reference.update({'projectID': projectID});
    }
    if (chats != null) {
      doc.reference.update({'chats': chats});
    }
  }

  Future<StudentModel> getStudentByID({required studentID}) async {
    final querySnapshot = await _studentCollection
        .where('studentID', isEqualTo: studentID)
        .limit(1)
        .get();
    return StudentModel.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>);
  }

  Stream<List<StudentModel>?> get getStudents {
    return _studentCollection
        .where('registered', isEqualTo: true)
        .where('hasTeam', isEqualTo: false)
        .orderBy('firstName')
        .snapshots()
        .map(_studentListFromSnapshot);
  }

  List<StudentModel>? _studentListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return StudentModel.fromMap(data);
      }).toList();
    } on SocketException {
      setLoading = false;
      setMessage = 'No Internet';
    } on FirebaseAuthException catch (error) {
      setLoading = false;
      setMessage = error.message ?? '';
    } catch (e) {
      setLoading = false;
      setMessage = e.toString();
    }
    return null;
  }

  // ! Instructor
  Future<void> loadInstructorData() async {
    final User user = UserAuth().currentUser;
    QuerySnapshot querySnapshot = await _instructorCollection
        .where('instructorUID', isEqualTo: user.uid)
        .limit(1)
        .get();
    instructor = InstructorModel.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>);
    notifyListeners();
  }

  Future<void> updateInstructorData(
      {bool? registered,
      String? path,
      int? numberOfTeams,
      List<dynamic>? teams,
      String? token,
      List<dynamic>? alerts,
      List<dynamic>? chats,
      String? bio}) async {
    final User user = UserAuth().currentUser;
    final docSnap = await _instructorCollection
        .where('instructorUID', isEqualTo: user.uid)
        .limit(1)
        .get();
    final doc = docSnap.docs.first;
    if (registered != null) {
      doc.reference.update({'registered': true});
    }
    if (path != null) {
      doc.reference.update({'profilePicture': path});
    }
    if (numberOfTeams != null) {
      doc.reference.update({'numberOfTeams': numberOfTeams});
    }
    if (teams != null) {
      doc.reference.update({'teams': teams});
    }
    if (token != null) {
      doc.reference.update({'token': token});
    }
    if (alerts != null) {
      doc.reference.update({'alerts': alerts});
    }
    if (bio != null) {
      doc.reference.update({'bio': bio});
    }
    if (chats != null) {
      doc.reference.update({'chats': chats});
    }
    loadInstructorData();
  }

  Future<void> updateInstructorByEmail(
      {required String? instructorEmail,
      String? projectID,
      List<dynamic>? chats,
      Map<dynamic, dynamic>? alert}) async {
    final docSnap = await _instructorCollection
        .where('instructorEmail', isEqualTo: instructorEmail)
        .limit(1)
        .get();
    final doc = docSnap.docs.first;
    InstructorModel instructor = InstructorModel.fromMap(
        docSnap.docs.first.data() as Map<String, dynamic>);
    if (projectID != null) {
      instructor.teams?.add(projectID);
      doc.reference.update({'teams': instructor.teams});
      doc.reference.update({'numberOfTeams': instructor.numberOfTeams! + 1});
    }
    if (alert != null) {
      instructor.alerts?.add(alert);
      doc.reference.update({'alerts': instructor.alerts});
    }
    if (chats != null) {
      doc.reference.update({'chats': chats});
    }
  }

  Future<InstructorModel?> getInstructorByEmail(String instructorEmail) async {
    try {
      final querySnapshot = await _instructorCollection
          .where('instructorEmail', isEqualTo: instructorEmail)
          .limit(1)
          .get();
      return InstructorModel.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      setMessage = 'Error fetching instructor data: $e';
      return null;
    }
  }

  Stream<List<InstructorModel>?> get getInstructors {
    return _instructorCollection
        .where('major', isEqualTo: student?.major)
        .where('registered', isEqualTo: true)
        .where('numberOfTeams', isLessThan: 3)
        .orderBy('numberOfTeams')
        .orderBy('firstName')
        .snapshots()
        .map(_instructorListFromSnapshot);
  }

  List<InstructorModel>? _instructorListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return InstructorModel.fromMap(data);
      }).toList();
    } on SocketException {
      setLoading = false;
      setMessage = 'No Internet';
    } on FirebaseAuthException catch (error) {
      setLoading = false;
      setMessage = error.message ?? '';
    } catch (e) {
      setLoading = false;
      setMessage = e.toString();
    }
    return null;
  }

  // * Profile Image
  final picker = ImagePicker();
  XFile? _image;
  XFile? get getImage => _image;

  Future pickGalleryImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage();
    }
  }

  Future pickCameraImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    if (pickedFile != null) {
      _image = XFile(pickedFile.path);
      uploadImage();
    }
  }

  void uploadImage() async {
    final User user = UserAuth().currentUser;
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref('/profileImage${user.uid}');
    firebase_storage.UploadTask uploadTask =
        ref.putFile(File(getImage!.path).absolute);
    await Future.value(uploadTask);
    final String newURL = await ref.getDownloadURL();
    user.email?.contains('std') ?? false
        ? updateStudentData(path: newURL)
        : updateInstructorData(path: newURL);
  }
}
