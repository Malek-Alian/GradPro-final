import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/instructor_model.dart';
import '../../models/project_model.dart';
import '../../models/student_model.dart';
import 'users_firestore.dart';

class ProjectsFirestore extends ChangeNotifier {
  final CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('Project');
  final CollectionReference _instructorCollection =
      FirebaseFirestore.instance.collection('Instructor');
  bool isLoading = false;
  String errorMessage = '';
  ProjectModel project = ProjectModel();
  ProjectModel? projectData;
  StudentModel? student;
  InstructorModel? instructor;

  void update(UsersFirestore usersFirestore) {
    usersFirestore.student == null && usersFirestore.instructor == null
        ? null
        : usersFirestore.isStudent()
            ? student = usersFirestore.student
            : instructor = usersFirestore.instructor;
  }

  set setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  set setMessage(String value) {
    errorMessage = value;
    notifyListeners();
  }

  Future<void> loadProjectData({required String? projectID}) async {
    QuerySnapshot querySnapshot = await _projectsCollection
        .where('projectID', isEqualTo: projectID)
        .limit(1)
        .get();
    projectData = ProjectModel.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>);
    notifyListeners();
  }

  Future<bool> createProject(
      {String? projectID,
      String? projectName,
      int? createdAt,
      String? bio,
      String? major,
      String? projectLevel}) async {
    try {
      setLoading = true;
      project.projectName = projectName;
      project.projectID = projectID;
      project.bio = bio;
      project.createdAt = createdAt;
      project.projectLevel = projectLevel;
      project.major = major;
      project.members = [student?.studentID];
      project.supervisorName = '';
      project.tasks = [];
      project.files = [];
      await _projectsCollection.add(project.toMap());
      setLoading = false;
      return true;
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
    return true;
  }

  QueryDocumentSnapshot<Object?>? doc;
  Future<void> updateProjectData(
      {String? supervisorName,
      String? projectID,
      List<dynamic>? members,
      List<dynamic>? tasks,
      List<dynamic>? files,
      String? bio}) async {
    final docSnap = await _projectsCollection
        .where('projectID', isEqualTo: projectID)
        .limit(1)
        .get();
    doc = docSnap.docs.first;
    if (supervisorName != null) {
      doc?.reference.update({'supervisorName': supervisorName});
    }
    if (members != null) {
      doc?.reference.update({'members': members});
    }
    if (tasks != null) {
      doc?.reference.update({'tasks': tasks});
    }
    if (files != null) {
      doc?.reference.update({'files': files});
    }
    if (bio != null) {
      doc?.reference.update({'bio': bio});
    }
  }

  Future<void> deleteProject() async {
    await deleteProjectSupervisor(projectID: projectData?.projectID);
    await doc?.reference.delete();
  }

  Future<void> deleteProjectSupervisor({String? projectID}) async {
    final docSnap = await _instructorCollection
        .where('teams', arrayContains: projectID)
        .limit(1)
        .get();
    if (docSnap.docs.isNotEmpty) {
      final doc = docSnap.docs.first;
      instructor = InstructorModel.fromMap(doc.data() as Map<String, dynamic>);
      instructor?.teams?.remove(projectID);
      doc.reference.update({'teams': instructor?.teams});
      doc.reference.update({'numberOfTeams': instructor?.teams?.length});
    }
  }

  Future<List<String>> getAllProjectIDs() async {
    try {
      final querySnapshot = await _projectsCollection.get();
      return querySnapshot.docs.map((doc) {
        return doc['projectID'] as String;
      }).toList();
    } on SocketException {
      setLoading = false;
      setMessage = 'No Internet';
      return [];
    } on FirebaseAuthException catch (error) {
      setLoading = false;
      setMessage = error.message ?? '';
      return [];
    } catch (e) {
      setLoading = false;
      setMessage = e.toString();
      return [];
    }
  }

  Stream<List<ProjectModel>?> get getProjectsForGuest {
    return _projectsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_projectListFromSnapshot);
  }

  List<ProjectModel>? _projectListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return ProjectModel.fromMap(data);
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

  Future<ProjectModel?> getProjectByID(String projectID) async {
    try {
      final querySnapshot = await _projectsCollection
          .where('projectID', isEqualTo: projectID)
          .limit(1)
          .get();
      return ProjectModel.fromMap(
          querySnapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      setMessage = 'Error fetching project data: $e';
      return null;
    }
  }
}
