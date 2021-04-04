import 'package:Klocka/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginDialog extends StatefulWidget {
  String scanCode;

  LoginDialog(this.scanCode);

  @override
  _LoginDialogState createState() => _LoginDialogState();

  static Future<bool?> open(BuildContext context, String code) {
    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (context) => LoginDialog(code),
    );
  }
}

class _LoginDialogState extends State<LoginDialog> {
  var passwordCode = '';
  var errorMessage = '';

  bool loadingLogin = false;

  final fieldText = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
      title: Row(
        children: [
          Icon(Icons.lock),
          Text('Verifizierung'),
        ],
      ),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Der eingescannte QR-Code ist bereits registriert. Bitte geben Sie das Passwort ein: '),
            SizedBox(height: 20),
            TextFormField(
              textInputAction: TextInputAction.done,
              controller: fieldText,
              enableSuggestions: false,
              autocorrect: false,
              obscureText: true,
              onEditingComplete: submitPassword,
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
                    var mailtoLink = Mailto(
                      to: ['linssenste@gmail.com'],
                      subject: 'Passwort zurücksetzen - Lokal "${widget.scanCode}"',
                      body: '',
                    );

                    await launch('$mailtoLink');
                  },
                  child: Text('Passwort vergessen?', style: TextStyle(color: Colors.red, fontSize: 14))),
            ),
            SizedBox(height: 20),
            actionButtons()
          ],
        ),
      ),
    );
  }

  Widget actionButtons() {
    return Row(
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
        if (loadingLogin)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 3, valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFFD51031)))),
          )
        else
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFD51031),
              elevation: 0,
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0),
              ),
            ),
            onPressed: passwordCode != "" ? submitPassword : null,
            child: Text('Anmelden'),
          )
      ],
    );
  }

  submitPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() {
      loadingLogin = true;
    });

    var successLogin = await ApiService.login(widget.scanCode, passwordCode);

    setState(() {
      loadingLogin = false;
    });
    if (successLogin) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        passwordCode = '';
        fieldText.clear();
      });
    }
  }
}
