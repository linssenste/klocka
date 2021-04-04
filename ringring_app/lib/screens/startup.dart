import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

import './register.dart';
import '../main.dart';
import 'scan_code.dart';

class StartupOperation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    return Container(
      child: IntroductionScreen(
        showNextButton: false,
        pages: [
          welcomePage(),
          usagePage(),
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
            image: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 160),
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.red.shade200,
                    borderRadius: BorderRadius.circular(125),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(125),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        dotsDecorator: DotsDecorator(
            size: const Size.square(10.0),
            activeSize: const Size(50.0, 10.0),
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

  PageViewModel welcomePage() {
    return templatePage('Willkommen', 'Erklärung und willkommserklärung hier', false);
  }

  PageViewModel usagePage() {
    return templatePage('Nutzung', 'Erklärung Nutzung', false);
  }

  PageViewModel templatePage(String title, String explanation, bool startButton) {
    return PageViewModel(
      title: title,
      decoration: PageDecoration(pageColor: Colors.grey.shade50),
      bodyWidget: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('${explanation}')],
          ),
        ],
      ),
      image: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 160),
          child: Container(
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.red.shade200,
              borderRadius: BorderRadius.circular(125),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(125),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
