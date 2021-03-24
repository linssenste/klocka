import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanCode extends StatefulWidget {
  @override
  _ScanCodeState createState() => _ScanCodeState();
}

class _ScanCodeState extends State<ScanCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.green,
          child: QRView(
            key: qrKey,
            onQRViewCreated: (controller) {
              this.controller = controller;
              bool hasResult = false;
              controller.scannedDataStream.listen((scanData) {
                if (hasResult) return;
                hasResult = true;
                Navigator.of(context).pop(scanData.code);
              });
            },
            overlay: QrScannerOverlayShape(),
          )),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
