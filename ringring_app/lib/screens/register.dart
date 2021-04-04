import 'package:Klocka/screens/toolbar_page.dart';
import 'package:Klocka/services/api_service.dart';
import 'package:Klocka/services/storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final dynamic resultScan;
  const RegisterScreen(this.resultScan);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String codePassword = '';
  String codePasswordVerify = '';
  bool checkingQrCode = false;
  bool isLoading = false;
  String companyName = '';
  String contactName = '';
  String websiteUrl = '';

  String address = '';
  String zipCode = '';
  String cityName = '';

  int _currentStep = 0;
  StepperType stepperType = StepperType.vertical;

  @override
  Widget build(BuildContext context) {
    var code = widget.resultScan.split("/").last;

    final node = FocusScope.of(context);

    return ToolbarWidget(
      'Registrieren',
      Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Theme(
                data: ThemeData(canvasColor: Color(0xFFD51031), primaryColor: Color(0xFFD51031)),
                child: Stepper(
                  controlsBuilder: (BuildContext context, {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) {
                    return Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Visibility(
                            visible: _currentStep != 3,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFFD51031),
                                elevation: 0,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: onStepContinue,
                              child: const Text('Nächster Schritt'),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  type: stepperType,
                  physics: ScrollPhysics(),
                  currentStep: _currentStep,
                  onStepTapped: (step) => tapped(step),
                  onStepContinue: ((_currentStep == 0 && contactName.length > 0 && companyName.length > 0) ||
                          (_currentStep == 1 && address.length > 0 && zipCode.length == 5 && cityName.length > 0) ||
                          _currentStep == 2
                      ? continued
                      : null),
                  steps: <Step>[
                    Step(
                      title: const Text('Ladenlokal'),
                      content: Column(
                        children: [
                          const Text(
                            'Bitte geben Sie den Namen Ihres Lokals, sowie den Namen des zuständigen Ansprechpartners ein.',
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            enableSuggestions: false,
                            onChanged: (textValue) {
                              setState(() {
                                companyName = textValue;
                              });
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 0.5),
                              ),
                              labelText: 'Lokalname*',
                            ),
                            onEditingComplete: () => node.nextFocus(),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            enableSuggestions: false,
                            onChanged: (textValue) {
                              setState(() {
                                contactName = textValue;
                              });
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 0.5),
                              ),
                              labelText: 'Ansprechpartner*',
                            ),
                            onEditingComplete: () => node.unfocus(),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
                    ),
                    Step(
                      title: const Text('Anschrift'),
                      content: Column(
                        children: <Widget>[
                          Text(
                              'Bitte geben Sie auch eine Addresse ein, dass wir Sie in unserem System registieren können.'),
                          SizedBox(height: 30),
                          TextFormField(
                            enableSuggestions: false,
                            textInputAction: TextInputAction.next,
                            onChanged: (textValue) {
                              setState(() {
                                address = textValue;
                              });
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 0.5),
                              ),
                              labelText: 'Straße & Hausnummer',
                            ),
                            onEditingComplete: () => node.nextFocus(),
                          ),
                          SizedBox(height: 30),
                          TextFormField(
                            onChanged: (textValue) {
                              setState(() {
                                zipCode = textValue;
                              });
                            },
                            maxLength: 5,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 0.5),
                              ),
                              labelText: 'Postleitzahl (PLZ)',
                            ),
                            onEditingComplete: () => node.nextFocus(),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            onChanged: (textValue) {
                              setState(() {
                                cityName = textValue;
                              });
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 0.5),
                              ),
                              labelText: 'Stadt',
                            ),
                            onEditingComplete: () => node.unfocus(),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
                    ),
                    Step(
                      title: new Text('QR-Code'),
                      content: Column(
                        children: <Widget>[
                          Text(
                              'Jeder QR-Code hat einen einmaligen Code, der extra in leichter Sprache. Ihr Code lautet:  '),
                          SizedBox(height: 10),
                          Text(
                            '${widget.resultScan.split("/").last}',
                            style: TextStyle(fontSize: 20, letterSpacing: 3, color: Colors.black54),
                          ),
                          SizedBox(height: 20),
                          Text(
                              'Wenn ein Kunde den Code einscannt & so klingelt, wird er auf die Seite von diesem Projekt geleitet. Optional können Sie auch Ihre eigene Webseite angeben, zu dem der Kunde dann weitergeleitet wird.'),
                          SizedBox(height: 20),
                          TextFormField(
                            autocorrect: false,
                            keyboardType: TextInputType.url,
                            decoration: const InputDecoration(
                                isDense: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFD51031), width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFD51031), width: 0.5),
                                ),
                                labelText: 'Webseite',
                                prefixText: 'https://www.'),
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
                    ),
                    Step(
                      title: new Text('Sicherheit'),
                      content: Column(
                        children: <Widget>[
                          Text(
                              'Falls Sie diese App löschen, oder die App auf einem anderen Gerät installiseren, müssen Sie ein Passwort festlegen. Mit diesem können Sie die Klingel-App dann mit dem QR-Code neu registrieren.'),
                          SizedBox(height: 10),
                          TextFormField(
                            obscureText: true,
                            onChanged: (textValue) {
                              setState(() {
                                codePassword = textValue;
                              });
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 0.5),
                              ),
                              labelText: 'Passwort',
                            ),
                            onEditingComplete: () => node.unfocus(),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            obscureText: true,
                            onChanged: (textValue) {
                              setState(() {
                                codePasswordVerify = textValue;
                              });
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 2.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFD51031), width: 0.5),
                              ),
                              labelText: 'Passwort verifizieren',
                            ),
                            onEditingComplete: () => node.unfocus(),
                          ),
                          SizedBox(height: 40),
                          if (isLoading)
                            const Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD51031))))
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFFD51031),
                                  elevation: 0,
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed: (address != "" &&
                                        zipCode != "" &&
                                        cityName != "" &&
                                        contactName != "" &&
                                        companyName != "" &&
                                        codePasswordVerify == codePassword &&
                                        codePassword != "")
                                    ? registerCompany
                                    : null,
                                child: const Text('Registrieren'),
                              ),
                            )
                        ],
                      ),
                      isActive: _currentStep >= 0,
                      state: _currentStep >= 3 ? StepState.complete : StepState.disabled,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> registerCompany() async {
    setState(() {
      isLoading = true;
    });

    FocusScope.of(context).unfocus();
    var code = widget.resultScan.split("/").last;
    await FirebaseMessaging.instance.subscribeToTopic(code.toString());

    RegisterData companyInformation = RegisterData(RegisterAddrData(cityName, zipCode, address),
        RegisterCompanyData(companyName, contactName, websiteUrl), codePassword);

    var registerSuccess = await ApiService.register(code.toString(), companyInformation);
    print(registerSuccess);

    if (registerSuccess != true) {
      StorageService.companyLink = '';
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Leider ist ein Fehler aufgetreten! Probieren Sie es doch noch einmal.")));
    } else {
      StorageService.companyLink = code.toString();
      Navigator.of(context).pop(true);
    }
    setState(() {
      isLoading = false;
    });
  }

  switchStepsType() {
    setState(() => stepperType == StepperType.vertical
        ? stepperType = StepperType.horizontal
        : stepperType = StepperType.vertical);
  }

  tapped(int step) {
    setState(() => {_currentStep = step});
    FocusManager.instance.primaryFocus?.unfocus();
  }

  continued() {
    FocusManager.instance.primaryFocus?.unfocus();
    print(_currentStep);

    _currentStep < 4 ? setState(() => _currentStep += 1) : null;
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }
}
