import 'dart:io';

import 'package:Klocka/screens/company_screen.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'main.mapper.g.dart';
import 'screens/startup.dart';
import 'services/push_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeJsonMapper();
  await StorageService.init();
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
      home: StorageService.isFirstStart ? StartupOperation() : MyHomePage(title: 'Klocka'),
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

        // showDialog(
        //   context: _navigatorKey.currentContext!,
        //   builder: (context) {
        //     Future.delayed(Duration(seconds: 10), () {
        //       Navigator.of(context).pop(true);
        //     });
        //     return AlertDialog(
        //       title: Text("Ding Dong!"),
        //       content: Container(
        //         child: Column(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             Text('Ein Kunde hat gerade an der Tür geklingelt, der Hilfe benötigt.'),
        //             SizedBox(height: 10),
        //             ElevatedButton(
        //               style: ElevatedButton.styleFrom(
        //                 primary: Colors.red,
        //                 elevation: 0,
        //                 shape: new RoundedRectangleBorder(
        //                   borderRadius: new BorderRadius.circular(30.0),
        //                 ),
        //               ),
        //               onPressed: () {
        //                 Navigator.of(context).pop(true);
        //               },
        //               child: Text('Schließen'),
        //             )
        //           ],
        //         ),
        //       ),
        //     );
        //   },
        // );
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
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: CompanyScreen());
  }
}
