import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

import 'help_dialog.dart';

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
                onQRViewCreated: onQRViewCreated,
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
                            children: const [
                              CircularProgressIndicator(),
                              Padding(
                                padding: EdgeInsets.only(top: 15.0),
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
                              child: buildRow(),
                            ),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget buildRow() {
    return Row(
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
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    bool hasResult = false;

    controller.scannedDataStream.listen((scanData) async {
      if (hasResult) return;

      hasResult = true;
      Vibration.vibrate();

      setState(() {
        loadingCode = true;
      });

      var qrCodeId = scanData.code.split("/").last;
      var url = 'https://europe-west3-ringring-6a70f.cloudfunctions.net/api/exists/$qrCodeId';

      var value = await http.get(Uri.parse(url));
      if (value.statusCode == 200 && (value.body == true || value.body == 'true')) {
        setState(() {
          loadingCode = false;
          showText = false;
        });

        var val = await HelpDialog.open(context, code);

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
      } else {
        Navigator.of(context).pop(scanData.code);
      }

      //
    });
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
