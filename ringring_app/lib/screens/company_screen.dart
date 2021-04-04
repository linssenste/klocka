import 'dart:async';

import 'package:Klocka/screens/information.dart';
import 'package:Klocka/services/storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class CompanyScreen extends StatefulWidget {
  @override
  _CompanyScreenState createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  dynamic _selectedTimer = 0;
  String? resultScan = '';
  bool reminderSwitchWeekday = false;
  bool reminderSwitchWeekend = false;
  dynamic resultRegister = {};

  final _scrollController = ScrollController();
  late Timer _timer;
  int timerLeft = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Color(0xFFD51031)),
          child: SizedBox(
            width: 500,
            child: Stack(
              children: [
                Positioned(
                  left: (MediaQuery.of(context).size.width / 2) - 60,
                  top: 60,
                  child:
                      Text('Klocka.', textAlign: TextAlign.center, style: TextStyle(fontSize: 35, color: Colors.white)),
                ),
                Positioned(
                    top: 56,
                    left: MediaQuery.of(context).size.width - 50,
                    child: IconButton(
                      icon: Icon(Icons.info_outline_rounded, color: Colors.white),
                      onPressed: () {
                        Vibration.vibrate(pattern: [0, 15]);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => InformationPage()));
                      },
                    ))
              ],
            ),
          ),
        ),
        SnappingSheet(
          grabbingHeight: 35,
          grabbing: Container(
            height: 10,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Center(
                child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Container(
                    height: 4,
                    width: 30,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
          snappingPositions: const [
            SnappingPosition.factor(
              positionFactor: 0.175,
              snappingCurve: Curves.easeOutExpo,
              snappingDuration: Duration(milliseconds: 1000),
            ),
            SnappingPosition.factor(
              positionFactor: 0.788,
              snappingCurve: Curves.easeOutExpo,
              snappingDuration: Duration(milliseconds: 600),
            ),
          ],
          sheetBelow: SnappingSheetContent(
            draggable: true,
            childScrollController: _scrollController,
            child: Container(
              color: Colors.grey.shade50,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, left: 20, right: 20),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 100,
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.transparent, width: 1),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    StorageService.registerData!.company.name,
                                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    StorageService.registerData!.company.contact,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(height: 3),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${StorageService.registerData!.address.street}, ',
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        StorageService.registerData!.address.zip,
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        StorageService.registerData!.address.city,
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),

                            Divider(color: Colors.grey),
                            SizedBox(height: 10),
                            Text('Erinnerungen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 10),
                            Text(
                                'Sie können sich jeden Morgen erinnern lassen, die Klingel-App zu aktivieren. So vergessen sie niemals die App.'),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text('Werktags', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(' um 8:00 Uhr'),
                                  ],
                                ),
                                Spacer(),
                                Switch(
                                    value: reminderSwitchWeekday,
                                    onChanged: (value) async {
                                      if (value == true) {
                                        await FirebaseMessaging.instance.subscribeToTopic('workday');
                                      } else {
                                        await FirebaseMessaging.instance.unsubscribeFromTopic('workday');
                                      }
                                      setState(() {
                                        reminderSwitchWeekday = value;
                                      });
                                    }),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text('Samstags', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(' um 8:00 Uhr'),
                                  ],
                                ),
                                Spacer(),
                                Switch(
                                    value: reminderSwitchWeekend,
                                    onChanged: (value) async {
                                      if (value == true) {
                                        await FirebaseMessaging.instance.subscribeToTopic('weekend');
                                      } else {
                                        await FirebaseMessaging.instance.unsubscribeFromTopic('weekend');
                                      }
                                      setState(() {
                                        reminderSwitchWeekend = value;
                                      });
                                    }),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(color: Colors.grey),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text('Wheelmap', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: GestureDetector(
                                      onTap: () async {
                                        var addressHandle =
                                            '${StorageService.registerData!.address.street}%2C%20${StorageService.registerData!.address.zip.replaceAll(' ', '%20')}%20${StorageService.registerData!.address.city.replaceAll(' ', '%20')}';
                                        var wheelUrl =
                                            'https://wheelmap.org/search?q=${addressHandle.replaceAll(' ', '%20').replaceAll('.', '').replaceAll('?', '')}';
                                        Vibration.vibrate(pattern: [0, 15]);
                                        await launch(wheelUrl);
                                      },
                                      child: Icon(Icons.link)),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                                'Ist Ihr Unternehmen bereits bei Wheelmap eingetragen? Wenn nicht, klicken Sie auf das Link-Symbol, um dies zu tun, denn dann können Menschen mit und ohne Behinderung einsehen, ob und wie barrierefrei Ihr Unternehmen ist.'),

                            SizedBox(height: 20),
                            //Container(height: (MediaQuery.of(context).size.height) - 380),
                            Divider(color: Colors.grey),
                            SizedBox(height: 20),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xFFD51031),
                                  elevation: 0,
                                  shape: new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(30.0),
                                  ),
                                ),
                                onPressed: () async {
                                  Vibration.vibrate(pattern: [0, 15]);
                                  final mailtoLink = Mailto(
                                    to: ['linssenste@gmail.com'],
                                    subject: 'Hilfestellung Klingel-App',
                                    body: '',
                                  );
                                  // Convert the Mailto instance into a string.
                                  // Use either Dart's string interpolation
                                  // or the toString() method.
                                  await launch('$mailtoLink');
                                },
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.feedback, size: 20),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text('Feedback'),
                                      )
                                    ],
                                  ),
                                )),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFFD51031),
                                elevation: 0,
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                              ),
                              onPressed: () async {
                                Vibration.vibrate(pattern: [0, 15]);
                                final mailtoLink = Mailto(
                                  to: ['linssenste@gmail.com'],
                                  subject: 'Hilfestellung Klingel-App',
                                  body: '',
                                );
                                // Convert the Mailto instance into a string.
                                // Use either Dart's string interpolation
                                // or the toString() method.
                                await launch('$mailtoLink');
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.help, size: 20.0),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Support'),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                await launch('https://www.instagram.com/viersenfueralle/?hl=de');
                              },
                              child: Center(
                                  child: Text('...mit ❤️ in München & Viersen entwickelt',
                                      style: TextStyle(fontSize: 13))),
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
            ),
          ),
          child: Center(
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height / 2 + 125,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Text(
                            (StorageService.isSubscribed
                                ? 'Die Klingel ist gerade aktiviert.'
                                : 'Die Klingel ist gerade ausgeschaltet.'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            width: 250,
                            child: Text('Klicken Sie auf das Logo, um den Klingel-Status zu ändern.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w200,
                                )),
                          ),
                          // AnimatedOpacity(opacity: StorageService.isSubscribed ? 0 : 1,duration: Duration(milliseconds: 200),child: setActivateTimer())
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () async {
                          if (StorageService.isSubscribed) {
                            print(StorageService.companyLink);
                            await FirebaseMessaging.instance.unsubscribeFromTopic(StorageService.companyLink);

                            Vibration.vibrate(pattern: [0, 100, 50, 100]);
                            setState(() {
                              StorageService.isSubscribed = false;
                            });
                          } else {
                            await FirebaseMessaging.instance.subscribeToTopic(StorageService.companyLink);

                            Vibration.vibrate(pattern: [0, 300]);
                            setState(() {
                              StorageService.isSubscribed = true;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 100.0),
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              AnimatedOpacity(
                                duration: const Duration(milliseconds: 200),
                                opacity: StorageService.isSubscribed ? 1 : 0.3,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: StorageService.isSubscribed ? 250 : 200,
                                  width: StorageService.isSubscribed ? 250 : 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(StorageService.isSubscribed ? 125 : 100),
                                    boxShadow: [BoxShadow(color: Colors.white10, blurRadius: 10)],
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                      child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          height: StorageService.isSubscribed ? 120 : 100,
                                          child: AnimatedOpacity(
                                              duration: const Duration(milliseconds: 200),
                                              opacity: StorageService.isSubscribed ? 1 : 0.8,
                                              child: new Image.asset('assets/klocka_logo_colored.png')))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  // void startTimer() {
  //   const oneSec = const Duration(seconds: 1);
  //   _timer = new Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       if (timerLeft == 0) {
  //         setState(() {
  //           StorageService.isSubscribed = true;
  //           _selectedTimer = -1;
  //         });
  //         timer.cancel();
  //       } else {
  //         timerLeft--;
  //         print('$timerLeft');
  //       }
  //     },
  //   );
  // }
  //
  // activateTimer(int type) {
  //   Vibration.vibrate(pattern: [0, 10]);
  //   _timer.cancel();
  //   if (_selectedTimer == type) {
  //     setState(() {
  //       _selectedTimer = -1;
  //     });
  //   } else {
  //     setState(() {
  //       _selectedTimer = type;
  //       timerLeft = type;
  //       startTimer();
  //     });
  //   }
  // }
  //
  // Widget TimerChip(time) {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: GestureDetector(
  //       onTap: () => activateTimer(time),
  //       child: Container(
  //           height: 35,
  //           width: 94,
  //           decoration: BoxDecoration(
  //               color: _selectedTimer == time ? Colors.white : Colors.transparent,
  //               borderRadius: BorderRadius.circular(17.5),
  //               border: Border.all(color: Colors.white)),
  //           child: Center(
  //             child: Row(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.only(left: 10, right: 5.0),
  //                   child: Icon(Icons.more_time, size: 20, color: _selectedTimer == time ? Colors.black : Colors.white),
  //                 ),
  //                 Text('$time min', style: TextStyle(color: _selectedTimer == time ? Colors.black : Colors.white)),
  //               ],
  //             ),
  //           )),
  //     ),
  //   );
  // }
  //
  // setActivateTimer() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [TimerChip(30), TimerChip(45), TimerChip(60)],
  //   );
  // }
  //
  // @override
  // void dispose() {
  //   _timer.cancel();
  //   super.dispose();
  // }
}
