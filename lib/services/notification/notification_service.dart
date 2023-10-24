// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   void requestPermission() async {
//     NotificationSettings settings =
//         await FirebaseMessaging.instance.requestPermission();
//   }

//   initInfo() {
//     var androidInitialize =
//         const AndroidInitializationSettings('@mipmap/c_launcher');
//     var iOSInitialize = const DarwinInitializationSettings();
//     var initializationSettings =
//         InitializationSettings(android: androidInitialize, iOS: iOSInitialize);

//     FlutterLocalNotificationsPlugin().initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {},
//     );
//   }
// }
