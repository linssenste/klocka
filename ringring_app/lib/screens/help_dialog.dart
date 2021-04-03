import 'package:Klocka/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class HelpDialog extends StatefulWidget {
  String scanCode;

  HelpDialog(this.scanCode);

  @override
  _HelpDialogState createState() => _HelpDialogState();

  static Future<bool?> open(BuildContext context, String code) {
    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) => HelpDialog(code);
    );
  }
}

class _HelpDialogState extends State<HelpDialog> {
  var passwordCode = '';
  var errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock),
          Text('Verifizierung'),
        ],
      ),
      content:  Container(
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
                    setState(() {
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

                      }
                          : null,
                      child: Text('Anmelden'),
                    )
                  ],
                )
              ],
            ),
      ),
    );
  }

}
