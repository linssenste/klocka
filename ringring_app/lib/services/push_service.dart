import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

import './storage_service.dart';

class PushService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> setupNotificationHandler(Function onMessage) async {
    await Firebase.initializeApp();
    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((event) {
      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('H:m');
      final String formattedTime = formatter.format(now);
      final DateFormat formatterDate = DateFormat('dd.MM.yyyy');
      final String formattedDate = formatterDate.format(now);

      StorageService.lastRing = ('${formattedTime} Uhr (${formattedDate})');
      print("MESSAGELOL ${event}");
      onMessage();
    });
  }
}
