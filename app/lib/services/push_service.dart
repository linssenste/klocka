import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> setupNotificationHandler(Function onMessage) async {
    await Firebase.initializeApp();
    await _firebaseMessaging.requestPermission();

    if (Platform.isAndroid) {
      _localNotificationsPlugin.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('ic_launcher'),
      ));
      _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()!
          .createNotificationChannel(
            const AndroidNotificationChannel(
              "klocka_notification_channel",
              "Klocka Notifications",
              "When your bell rings.",
              sound: RawResourceAndroidNotificationSound("bell_sound"),
              playSound: true,
              importance: Importance.max,
            ),
          );
    }

    FirebaseMessaging.onMessage.listen((event) {
      onMessage();
    });
  }
}
