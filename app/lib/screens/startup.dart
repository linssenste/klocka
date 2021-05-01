import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:path_provider/path_provider.dart';

import './register.dart';
import '../main.dart';
import 'scan_code.dart';

class StartupOperation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Container(
      child: IntroductionScreen(
        onChange: (page) {
          print('moin: $page');
          if (page == 2) {
            simulateRing();
          }
        },
        showNextButton: false,
        pages: [
          welcomePage(context),
          introScanPage(context),
          introRingPage(context),
          introHelpPage(context),
          PageViewModel(
            title: '',
            decoration: PageDecoration(
              pageColor: Colors.grey.shade50,
              imagePadding: const EdgeInsets.all(1),
              contentPadding: const EdgeInsets.only(top: 0),
            ),
            bodyWidget: Column(
              children: [
                SizedBox(height: 120),
                SizedBox(
                  child: Image(
                    image: AssetImage('assets/intro_4_happy.png'),
                    width: (MediaQuery.of(context).size.width - 20),
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 80),
                Text(
                  'Geschafft!',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Column(
                          children: [
                            Text(
                              'Jetzt kann jede*r bei dir im Laden problemlos einkaufen.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFFD51031),
                                  elevation: 0,
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed: () async {
                                  String? resultScan = await Navigator.of(context)
                                      .push(MaterialPageRoute(builder: (context) => ScanCode()));

                                  if (resultScan == null) {
                                    return;
                                  }

                                  if (resultScan == "auth-success") {
                                    MyApp.of(context)!.endStartup();
                                  } else {
                                    print('else...');
                                    bool? success = await Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (context) => RegisterScreen(resultScan)));
                                    if (success == null) {
                                      return;
                                    }
                                    MyApp.of(context)!.endStartup();
                                  }
                                  //
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    "      Los geht's       ",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(25.0, 10.0),
            color: Colors.red.shade100,
            activeColor: Color(0xFFD51031),
            spacing: const EdgeInsets.symmetric(horizontal: 5.0),
            activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
        done: const Text("Los geht's", style: TextStyle(fontWeight: FontWeight.w800)),
        onDone: () async {
          String? resultScan = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ScanCode()));

          if (resultScan == null) {
            return;
          }
          print('TR ${resultScan}');
          if (resultScan == "LOGGEDINAUTHCODEPLACEHOLDER") {
            print("IN HERE");
            MyApp.of(context)!.endStartup();
          } else {
            print('else...');
            bool? success =
                await Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterScreen(resultScan)));
            if (success == null) {
              return;
            }
            MyApp.of(context)!.endStartup();
          }
          // When done button is press
        },
      ),
    ); //;
  }

  PageViewModel welcomePage(context) {
    return templatePage(
        context,
        'Willkommen!',
        'Toll, dass du dabei bist! 👋🏼\n Durch die Klocka App kannst du einen wertvollen Beitrag zur Inklusion leisten.\n\n Wische nach rechts & los geht\'s!',
        false,
        'assets/intro_welcome_people.png',
        false);
  }

  PageViewModel introScanPage(context) {
    return templatePage(
        context,
        'Klingeln',
        'Der hilfebenötigende Mensch kann durch das Einscannen des angebrachten QR-Codes ganz leicht die Klingel auslösen.',
        false,
        'assets/intro_1_scan.png',
        false);
  }

  PageViewModel introRingPage(BuildContext context) {
    return templatePage(
        context,
        'Benachrichtigung',
        'Nun erhälst du eine Benachrichtigung in Form eines Klingelns & wirst auf die Person aufmerksam gemacht.',
        false,
        'assets/intro_2_ring.png',
        true);
  }

  PageViewModel introHelpPage(BuildContext context) {
    return templatePage(
        context,
        'Hilfestellung',
        'Jetzt kannst du der Person Hilfestellung leisten & ihr das Hineinkommen ermöglichen.',
        false,
        'assets/intro_3_help.png',
        false);
  }

  PageViewModel introSuccessPage(BuildContext context) {
    return templatePage(context, 'Geschafft!', 'Jetzt kann jede*r bei dir im Laden problemlos einkaufen.', false,
        'assets/intro_4_happy.png', false);
  }

  PageViewModel usagePage(BuildContext context) {
    return templatePage(context, 'Nutzung', 'Erklärung Nutzung', false, 'assets/intro_4_happy.png', false);
  }

  PageViewModel templatePage(
      BuildContext context, String title, String explanation, bool startButton, String imageDirName, bool allowTap) {
    return PageViewModel(
      title: '',
      decoration: PageDecoration(
        pageColor: Colors.grey.shade50,
        imagePadding: const EdgeInsets.all(1),
        contentPadding: const EdgeInsets.only(top: 0),
      ),
      bodyWidget: Column(
        children: [
          SizedBox(height: 100),
          GestureDetector(
            onTap: () async {
              if (allowTap) {
                getTemporaryDirectory().then((value) async {
                  var file = File('${value.path}/notification.wav');

                  if (!(await file.exists())) {
                    var data = await rootBundle.load('assets/bell_sound.wav');
                    await file.writeAsBytes(data.buffer.asUint8List());
                  }

                  AudioPlayer player = AudioPlayer();
                  player.play(file.path, isLocal: true);
                });
              }
            },
            child: SizedBox(
              child: Image(
                image: AssetImage(imageDirName),
                width: (MediaQuery.of(context).size.width - 20),
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 50),
          Text(
            title,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.justify,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 40, right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    explanation,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void simulateRing() {
    getTemporaryDirectory().then((value) async {
      var file = File('${value.path}/notification.wav');

      if (!(await file.exists())) {
        var data = await rootBundle.load('assets/bell_sound.wav');
        await file.writeAsBytes(data.buffer.asUint8List());
      }

      AudioPlayer player = AudioPlayer();
      player.play(file.path, isLocal: true);
    });
  }
}
