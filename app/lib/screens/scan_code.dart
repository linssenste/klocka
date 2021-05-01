import 'package:Klocka/screens/dialogs/help_dialog.dart';
import 'package:Klocka/screens/dialogs/login_dialog.dart';
import 'package:Klocka/services/api_service.dart';
import 'package:Klocka/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vibration/vibration.dart';

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
      resizeToAvoidBottomInset: false,
      body: Container(
          color: Colors.white,
          child: Stack(
            children: [
              QRView(
                key: qrKey,
                onQRViewCreated: onQRViewCreated,
                overlay: QrScannerOverlayShape(
                    borderRadius: 20, borderWidth: 5, cutOutSize: 250, borderColor: Color(0xFFD51031)),
              ),
              Positioned(
                top: 50,
                child: Center(
                  child: Opacity(
                    opacity: .7,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: IconButton(
                            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () {
                              Vibration.vibrate(pattern: [0, 15]);
                              Navigator.of(context).pop(null);
                            })),
                  ),
                ),
              ),
              Positioned(
                top: (MediaQuery.of(context).size.height / 2) - 200,
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 200),
                        opacity: loadingCode || !showText ? 0 : 1,
                        child: const Text(
                          'Bitte scannen Sie den QR-Code ein.',
                          style: TextStyle(color: Colors.white),
                        ),
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
                      child: (!showText) ? null : helpRow(),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget helpRow() {
    return GestureDetector(
      onTap: () => ScanHelpDialog.open(context),
      child: Container(
        color: Color(0x00000000),
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically,
          children: const [
            Icon(
              Icons.help_outline,
              color: Color(0x5AFFFFFF),
              size: 20.0,
              semanticLabel: 'Zur Hilfestellung hier klicken.',
            ),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'Benötigen Sie Hilfe?',
                style: TextStyle(color: Color(0x5AFFFFFF)),
              ),
            ),
          ],
        ),
      ),
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

      var codeRegisterable = await ApiService.registerable(qrCodeId);

      if (codeRegisterable == false) {
        setState(() {
          loadingCode = false;
          showText = false;
        });

        var loginResponse = await LoginDialog.open(context, qrCodeId);

        if (loginResponse == true) {
          StorageService.companyLink = qrCodeId;
          Navigator.of(context).pop('auth-success');
        } else {
          StorageService.companyLink = '';
          hasResult = false;
          setState(() {
            showText = true;
          });
        }
      } else if (codeRegisterable == true) {
        Navigator.of(context).pop(qrCodeId);
      } else {
        // Snackbar for invalid QR-Code
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.white,
          content: Text(
            'Das ist ein unbekannter QR-Code. Bitte überprüfen Sie, dass Sie den richtigen Code eingescannt haben.',
            style: TextStyle(color: Colors.black),
          ),
          duration: Duration(milliseconds: 1500),
        ));

        Future.delayed(const Duration(milliseconds: 2000), () {
          hasResult = false;
        });

        setState(() {
          loadingCode = false;
        });
      }

      // if (value.statusCode == 200 && (value.body == true || value.body == 'true')) {
      //   setState(() {
      //     loadingCode = false;
      //     showText = false;
      //   });
      //
      //   var val = await HelpDialog.open(context, code);
      //
      //   if (val == true) {
      //     var code = 'LOGGEDINAUTHCODEPLACEHOLDER';
      //     print("CODE ${code}");
      //     Navigator.of(context).pop(code);
      //   } else {
      //     setState(() {
      //       loadingCode = false;
      //       showText = true;
      //       hasResult = false;
      //     });
      //   }
      // } else {
      //   Navigator.of(context).pop(scanData.code);
      // }

      //
    });
  }
}
