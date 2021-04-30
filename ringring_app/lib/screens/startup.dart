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
            decoration: PageDecoration(pageColor: Colors.grey.shade50),
            title: "Los geht's",
            bodyWidget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('moin'),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFD51031),
                        elevation: 0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () async {
                        String? resultScan =
                            await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ScanCode()));

                        print("HERE!");
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
                      child: Text("Los geht's"),
                    ),
                  ),
                ),
              ],
            ),
            image: Padding(
              padding: const EdgeInsets.only(top: 70.0),
              child: SizedBox(
                child: Image.asset(
                  'assets/intro_4_happy.png',
                ),
              ),
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
        context, '👋🏼 Willkommen!', 'Inklusion. Für alle. Überall.', false, 'assets/intro_welcome_people.png', false);
  }

  PageViewModel introScanPage(context) {
    return templatePage(
        context,
        'Klingel betätigen',
        'Egal ob Mensch mit einer Behinderung, eine ältere Person oder Elternteil mit Kinderwagen. Es kann immer vorkommen, dass mein Hilfe benötigt, um in den Laden zu kommen. Wenn Kunden Hilfe benötigen, scannen sie ganz einfach mit ihrem Smartphone den QR-Code am Schild. Der Code führt die Kunden auf eine Internetseite (optional auch Ihre Homepage)',
        false,
        'assets/intro_1_scan.png',
        false);
  }

  PageViewModel introRingPage(BuildContext context) {
    return templatePage(
        context, 'Ring', 'Erklärung und willkommserklärung hier', false, 'assets/intro_2_ring.png', true);
  }

  PageViewModel introHelpPage(BuildContext context) {
    return templatePage(
        context, 'Help', 'Erklärung und willkommserklärung hier', false, 'assets/intro_3_help.png', false);
  }

  PageViewModel introSuccessPage(BuildContext context) {
    return templatePage(
        context, 'Success', 'Erklärung und willkommserklärung hier', false, 'assets/intro_4_happy.png', false);
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
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Flexible(child: Text(explanation, textAlign: TextAlign.left, style: TextStyle(fontSize: 18)))],
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
