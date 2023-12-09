import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnnouncementsFirestore extends ChangeNotifier {
  final CollectionReference _announcementsCollection =
      FirebaseFirestore.instance.collection('Announcements');

  Future<void> createAnnouncement({
    required String text,
    required String senderId,
    required String sender,
    required bool important,
  }) async {
    try {
      final DocumentReference docRef = await _announcementsCollection.add({
        'text': text,
        'sender': sender,
        'senderId': senderId,
        'important': important,
        'openedBy': [],
        'timestamp': FieldValue.serverTimestamp(),
      });
      final String announcementId = docRef.id;
      await docRef.update({'announcementId': announcementId});
    } catch (error) {
      // ignore: avoid_print
      print('Error creating announcement: $error');
    }
  }

  Stream<List<DocumentSnapshot>> streamAllAnnouncements() {
    try {
      return _announcementsCollection
          .orderBy('important', descending: true)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((querySnapshot) {
        return querySnapshot.docs;
      });
    } catch (error) {
      // ignore: avoid_print
      print('Error getting announcements stream: $error');
      return Stream.value([]);
    }
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _announcementsCollection.doc(announcementId).delete();
    } catch (error) {
      // ignore: avoid_print
      print('Error deleting announcement: $error');
    }
  }
}
