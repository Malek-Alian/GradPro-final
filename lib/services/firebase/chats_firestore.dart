import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatsFirestore extends ChangeNotifier {
  final CollectionReference _chatsCollection =
      FirebaseFirestore.instance.collection('Chats');

  Future<void> createMessage(
      String chatId, Map<String, dynamic> messageData) async {
    try {
      DocumentReference chatRef = _chatsCollection.doc(chatId);
      CollectionReference messagesRef = chatRef.collection('Messages');
      await messagesRef.add(messageData);
    } catch (error) {
      // ignore: avoid_print
      print("Error creating message document: $error");
    }
  }

  Stream<List<QueryDocumentSnapshot>> getMessagesInChatStream(String chatId) {
    DocumentReference chatRef = _chatsCollection.doc(chatId);
    CollectionReference messagesRef = chatRef.collection('Messages');
    return messagesRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs);
  }

  Future<QueryDocumentSnapshot?> getLastMessageInChat(String chatId) async {
    try {
      DocumentReference chatRef = _chatsCollection.doc(chatId);
      CollectionReference messagesRef = chatRef.collection('Messages');
      QuerySnapshot messageQuery = await messagesRef
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messageQuery.docs.isNotEmpty) {
        return messageQuery.docs.first;
      } else {
        return null;
      }
    } catch (error) {
      // ignore: avoid_print
      print("Error getting last message: $error");
      return null;
    }
  }

  void markMessagesAsRead(String chatID, String uid) {
    final CollectionReference messagesRef =
        FirebaseFirestore.instance.collection('Chats/$chatID/Messages');
    messagesRef
        .where('receiverID', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        messagesRef.doc(doc.id).update({'read': true});
      }
    });
  }

  Future<int> calculateUnreadMessagesCount(String chatID, String uid) async {
    final CollectionReference messagesRef =
        FirebaseFirestore.instance.collection('Chats/$chatID/Messages');
    final QuerySnapshot unreadMessages = await messagesRef
        .where('receiverID', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    return unreadMessages.size;
  }
}
