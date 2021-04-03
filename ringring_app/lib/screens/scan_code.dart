import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailto/mailto.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

import '../services/storage_service.dart';

AuthData authDataFromJson(String str) => AuthData.fromJson(json.decode(str));

String authDataToJson(AuthData data) => json.encode(data.toJson());

class ScanCode extends StatefulWidget {
  @override
  _ScanCodeState createState() => _ScanCodeState();
}

class _ScanCodeState extends State<ScanCode> {
  String passwordCode = '';
  late bool showText = true;
  late bool loadingCode = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller; // weil später init sonst auch optional possible

  @override
  Widget build(BuildContext context) {
    // set up the button

    return Scaffold(
      body: Container(
          color: Colors.white,
          child: Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: (controller) async {
                  this.controller = controller;
                  bool hasResult = false;
                  controller.scannedDataStream.listen((scanData) async {
                    if (hasResult) return;
                    Vibration.vibrate();
                    hasResult = true;

                    setState(() {
                      loadingCode = true;
                    });
                    var code = scanData.code.split("/").last;
                    var url = 'https://europe-west3-ringring-6a70f.cloudfunctions.net/webApi/api/v1/exists/$code';
                    var passwordCode = '';
                    var errorMessage = '';

                    var value = await http.get(Uri.parse(url));
                    if (value.statusCode == 200 && (value.body == true || value.body == 'true')) {
                      setState(() {
                        loadingCode = false;
                        showText = false;
                      });

                      StateSetter _setState;

                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                Icon(Icons.lock),
                                Text('Verifizierung'),
                              ],
                            ),
                            content: StatefulBuilder(
                              // You need this, notice the parameters below:
                              builder: (BuildContext context, StateSetter setState) {
                                _setState = setState;
                                return Container(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          'Der eingescannte QR-Code ist bereits registriert. Bitte geben Sie das Passwort ein: '),
                                      SizedBox(height: 20),
                                      TextFormField(
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        obscureText: true,
                                        onChanged: (textValue) {
                                          _setState(() {
                                            passwordCode = textValue;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 2.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.red, width: 0.5),
                                          ),
                                          labelText: 'Password',
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                            onTap: () async {
                                              final mailtoLink = Mailto(
                                                to: ['linssenste@gmail.com'],
                                                subject:
                                                    'Passwort zurücksetzen - Lokal "${scanData.code.split("/").last}"',
                                                body: '',
                                              );
// Convert the Mailto instance into a string.
// Use either Dart's string interpolation
// or the toString() method.
                                              await launch('$mailtoLink');
                                            },
                                            child: Text('Passwort vergessen?',
                                                style: TextStyle(color: Colors.red, fontSize: 14))),
                                      ),
                                      SizedBox(
                                          height: 25,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: Text(
                                              errorMessage,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          )),
                                      SizedBox(height: 20),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: Text('Abbrechen'),
                                          ),
                                          SizedBox(width: 20),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.red,
                                              elevation: 0,
                                              shape: new RoundedRectangleBorder(
                                                borderRadius: new BorderRadius.circular(30.0),
                                              ),
                                            ),
                                            onPressed: passwordCode != ""
                                                ? () async {
                                                    FocusManager.instance.primaryFocus?.unfocus();
                                                    var code = scanData.code.split("/").last;
                                                    var url =
                                                        'https://europe-west3-ringring-6a70f.cloudfunctions.net/webApi/api/v1/auth/$code';
                                                    var response = await http
                                                        .post(Uri.parse(url), body: {'password': passwordCode});

                                                    print('Response status: ${response.statusCode} - ${response.body}');
                                                    if (response.statusCode == 200) {
                                                      final authData = authDataFromJson(response.body);

                                                      print("RESULT ${authData}");
                                                      StorageService.companyName = authData.name;
                                                      print("NAME: ${authData.name} -  ${StorageService.companyName}");
                                                      StorageService.contactName = authData.contact;
                                                      StorageService.streetName = authData.street;
                                                      StorageService.zipCode = authData.zip;
                                                      StorageService.cityName = authData.cityName;
                                                      StorageService.companyLink = code.toString();

                                                      Navigator.of(context).pop(true);
                                                    } else {
                                                      _setState(() {
                                                        errorMessage = "Oh, das Passwort ist leider falsch!";
                                                      });
                                                      Vibration.vibrate(pattern: [10, 200, 100, 200], amplitude: 255);
                                                    }
                                                  }
                                                : null,
                                            child: Text('Anmelden'),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ).then((val) {
                        if (val == true) {
                          var code = 'LOGGEDINAUTHCODEPLACEHOLDER';
                          print("CODE ${code}");
                          Navigator.of(context).pop(code);
                        } else {
                          setState(() {
                            loadingCode = false;
                            showText = true;
                            hasResult = false;
                          });
                        }
                      });
                    } else {
                      Navigator.of(context).pop(scanData.code);
                    }

                    //
                  });
                },
                overlay: QrScannerOverlayShape(borderRadius: 20, borderWidth: 0, cutOutSize: 200),
              ),
              Positioned(
                top: (MediaQuery.of(context).size.height / 2) - 160,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: Text(
                        (loadingCode || !showText) ? '' : 'Bitte scannen Sie den QR-Code ein.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: (MediaQuery.of(context).size.height / 2) + 250,
                child: Center(
                  child: (!loadingCode)
                      ? null
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: Column(
                            children: [
                              CircularProgressIndicator(),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Text(
                                  'QR-Code wird überprüft...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            ],
                          )),
                        ),
                ),
              ),
              Positioned(
                bottom: 50,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: (loadingCode || !showText)
                          ? null
                          : GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Row(
                                      children: const [
                                        Icon(
                                          Icons.help_outline,
                                          color: Colors.black,
                                          size: 20.0,
                                          semanticLabel: 'Hilfestellung Dialog',
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text("Hilfe"),
                                        ),
                                      ],
                                    ),
                                    content: Text('Hier eine Hilfestellung für den QR-Code'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Schließen'))
                                    ],
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                                crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically,
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    color: Colors.white,
                                    size: 20.0,
                                    semanticLabel: 'Zur Hilfestellung hier klicken.',
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      'Benötigen Sie Hilfe?${loadingCode}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class AuthData {
  AuthData({
    required this.cityName,
    required this.zip,
    required this.website,
    required this.street,
    required this.contact,
    required this.password,
    required this.name,
  });

  String cityName;
  String zip;
  String website;
  String street;
  String contact;
  String password;
  String name;

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
        cityName: json["cityName"],
        zip: json["zip"],
        website: json["website"],
        street: json["street"],
        contact: json["contact"],
        password: json["password"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "cityName": cityName,
        "zip": zip,
        "website": website,
        "street": street,
        "contact": contact,
        "password": password,
        "name": name,
      };
}
