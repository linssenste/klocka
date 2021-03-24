import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> setupNotificationHandler() async {
    await Firebase.initializeApp();
    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((event) {
      print("MESSAGE ${event}");
    });
  }
}
