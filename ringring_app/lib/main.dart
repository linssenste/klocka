import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ringring_app/screens/register.dart';

import 'screens/scan_code.dart';
import 'services/push_service.dart';

void main() {
  runApp(MyApp());
  PushService.setupNotificationHandler();
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(title: 'Ring Ring App!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String resultScan = '';
  dynamic resultRegister = {};

  void _scanCode(BuildContext context) async {
    resultScan = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => ScanCode()));
    setState(() {});
  }

  void _registerLocale(BuildContext context) async {
    resultRegister = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => Register()));
  }

  void _sendBackend(String qrCode) async {
    var code = qrCode.split("/").last;
    var url =
        'https://europe-west3-ringring-6a70f.cloudfunctions.net/webApi/api/v1/register/$code';
    var response = await http
        .post(Uri.parse(url), body: {'name': 'doodle', 'color': 'blue'});
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    await FirebaseMessaging.instance.subscribeToTopic(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              _registerLocale(context);
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed:
                  resultScan != '' ? () => _sendBackend(resultScan) : null,
              child: Text('Absenden'),
            ),
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$resultScan',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanCode(context),
        tooltip: 'Scan QR code',
        child: Icon(Icons.qr_code),
      ),
    );
  }
}
