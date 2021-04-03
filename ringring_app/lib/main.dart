import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:mailto/mailto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
// For Flutter applications, you'll most likely want to use
// the url_launcher package.
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

import 'screens/startup.dart';
import 'services/push_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  StorageService.isFirstStart = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  var _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primarySwatch: Colors.red,
      ),
      home: StorageService.isFirstStart ? StartupOperation() : MyHomePage(title: StorageService.companyDetails),
    );
  }

  void endStartup() {
    setState(() {
      StorageService.isFirstStart = false;
    });
  }

  @override
  void initState() {
    getTemporaryDirectory().then((value) async {
      var file = File('${value.path}/notification.wav');

      if (!(await file.exists())) {
        var data = await rootBundle.load('assets/bell_sound.wav');
        await file.writeAsBytes(data.buffer.asUint8List());
      }

      PushService.setupNotificationHandler(() async {
        AudioPlayer player = AudioPlayer();
        player.play(file.path, isLocal: true);

        showDialog(
          context: _navigatorKey.currentContext!,
          builder: (context) {
            Future.delayed(Duration(seconds: 10), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              title: Text("Ding Dong!"),
              content: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Es hat gerade ein Kunde an der Tür geklingt, der Hilfe bnötigt!'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                        elevation: 0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text('Schließen'),
                    )
                  ],
                ),
              ),
            );
          },
        );
      });
    });

    super.initState();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key); // werden bei compile schon erstellt

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? resultScan = '';
  bool reminderSwitchWeekday = false;
  bool reminderSwitchWeekend = false;
  dynamic resultRegister = {};

  final _scrollController = ScrollController();

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(color: Color(0xFFD51031)),
            child: Column(
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Text('Klocka.',
                          textAlign: TextAlign.center, style: TextStyle(fontSize: 35, color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SnappingSheet(
            grabbingHeight: 35,
            grabbing: Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Center(
                  child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Container(
                      height: 4,
                      width: 30,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
            snappingPositions: const [
              SnappingPosition.factor(
                positionFactor: 0.175,
                snappingCurve: Curves.easeOutExpo,
                snappingDuration: Duration(milliseconds: 1000),
              ),
              SnappingPosition.factor(
                positionFactor: 0.788,
                snappingCurve: Curves.easeOutExpo,
                snappingDuration: Duration(milliseconds: 600),
              ),
            ],
            sheetBelow: SnappingSheetContent(
              draggable: true,
              childScrollController: _scrollController,
              child: Container(
                color: Colors.grey.shade50,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 20, right: 20),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                height: 100,
                                padding: const EdgeInsets.all(3.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.black, width: 1),
                                ),
                                child: Column(
                                  children: [
                                    Text('Ladeninformationen: ',
                                        textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w300)),
                                    SizedBox(height: 5),
                                    Text(
                                      StorageService.companyName,
                                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      StorageService.contactName,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          StorageService.streetName,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          StorageService.zipCode,
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          ' ${StorageService.cityName}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Row(
                                  children: [
                                    Text('Zuletzt: ',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text('${StorageService.lastRing}', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Divider(color: Colors.grey),
                              SizedBox(height: 10),
                              Text('Erinnerungen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text(
                                  'Sie können sich jeden Morgen erinnern lassen, die Klingel-App zu aktivieren. So vergessen sie niemals die App.'),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Text('Werktags', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(' um 8:00 Uhr'),
                                    ],
                                  ),
                                  Spacer(),
                                  Switch(
                                      value: reminderSwitchWeekday,
                                      onChanged: (value) {
                                        setState(() {
                                          reminderSwitchWeekday = value;
                                        });
                                      }),
                                ],
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Text('Samstags', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(' um 8:00 Uhr'),
                                    ],
                                  ),
                                  Spacer(),
                                  Switch(
                                      value: reminderSwitchWeekend,
                                      onChanged: (value) {
                                        setState(() {
                                          reminderSwitchWeekend = value;
                                        });
                                      }),
                                ],
                              ),
                              SizedBox(height: 10),
                              Divider(color: Colors.grey),
                              SizedBox(height: 10),
                              Text('Wheelmap', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 10),
                              Text(
                                  'Fügen Sie doch gerne Ihr Lokal zur Wheelmap hinzu - dann können Menschen mit und ohne Behinderung sehen, ob und wie barrierefrei Ihr Lokal ist.'),

                              SizedBox(height: 20),
                              //Container(height: (MediaQuery.of(context).size.height) - 380),
                              Divider(color: Colors.grey),
                              SizedBox(height: 20),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xFFD51031),
                                    elevation: 0,
                                    shape: new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(30.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    final mailtoLink = Mailto(
                                      to: ['linssenste@gmail.com'],
                                      subject: 'Hilfestellung Klingel-App',
                                      body: '',
                                    );
                                    // Convert the Mailto instance into a string.
                                    // Use either Dart's string interpolation
                                    // or the toString() method.
                                    await launch('$mailtoLink');
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.feedback, size: 20),
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Feedback'),
                                        )
                                      ],
                                    ),
                                  )),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFFD51031),
                                  elevation: 0,
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed: () async {
                                  final mailtoLink = Mailto(
                                    to: ['linssenste@gmail.com'],
                                    subject: 'Hilfestellung Klingel-App',
                                    body: '',
                                  );
                                  // Convert the Mailto instance into a string.
                                  // Use either Dart's string interpolation
                                  // or the toString() method.
                                  await launch('$mailtoLink');
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.help, size: 20.0),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text('Support'),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  await launch('https://www.instagram.com/viersenfueralle/?hl=de');
                                },
                                child: Center(
                                    child: Text('...mit ❤️ in München & Viersen entwickelt',
                                        style: TextStyle(fontSize: 13))),
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
              ),
            ),
            child: Center(
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height / 2 + 125,
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Text(
                              (StorageService.isSubscribed
                                  ? 'Die Klingel ist gerade aktiviert.'
                                  : 'Die Klingel ist gerade ausgeschaltet.'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Container(
                              width: 250,
                              child: Text('Klicken Sie auf das Logo, um den Klingel-Status zu ändern.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w200,
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            if (StorageService.isSubscribed) {
                              print(StorageService.companyLink);
                              await FirebaseMessaging.instance.unsubscribeFromTopic(StorageService.companyLink);

                              Vibration.vibrate(pattern: [0, 100, 50, 100]);
                              setState(() {
                                StorageService.isSubscribed = false;
                              });
                            } else {
                              await FirebaseMessaging.instance.subscribeToTopic(StorageService.companyLink);

                              Vibration.vibrate(pattern: [0, 300]);
                              setState(() {
                                StorageService.isSubscribed = true;
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 100.0),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: StorageService.isSubscribed ? 1 : 0.3,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    height: StorageService.isSubscribed ? 250 : 200,
                                    width: StorageService.isSubscribed ? 250 : 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(StorageService.isSubscribed ? 125 : 100),
                                      boxShadow: [BoxShadow(color: Colors.white10, blurRadius: 10)],
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                        child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            height: StorageService.isSubscribed ? 120 : 100,
                                            child: AnimatedOpacity(
                                                duration: const Duration(milliseconds: 200),
                                                opacity: StorageService.isSubscribed ? 1 : 0.8,
                                                child: new Image.asset('assets/klocka_logo_colored.png')))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
