import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class ScanHelpDialog extends StatefulWidget {
  @override
  _ScanHelpDialogState createState() => _ScanHelpDialogState();
  static Future<bool?> open(BuildContext context) {
    Vibration.vibrate(pattern: [0, 20]);

    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) => ScanHelpDialog(),
    );
  }
}

class _ScanHelpDialogState extends State<ScanHelpDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
      title: Row(
        children: const [
          Icon(
            Icons.help_outline,
            color: Colors.black,
            size: 20.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text("Hilfe oder so"),
          ),
        ],
      ),
      content: Text(
          'Das ist nur ein Platzhalter. In der finalen Version soll hier eine kurze Hilfestellung für die QR-Codes bereitgestellt werden. Im besten Fall auch mit Bildern.'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Schließen'))
      ],
    );
  }
}
