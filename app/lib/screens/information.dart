import 'package:Klocka/screens/toolbar_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'license_page.dart';

class InformationPage extends StatefulWidget {
  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  @override
  Widget build(BuildContext context) {
    return ToolbarWidget(
      'Informationen',
      Container(
          color: Colors.white,
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 40),
                new Image.asset('assets/people_disablity_community.jpg'),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Wer Inklusion will, sucht Wege, wer sie verhindern will, sucht Begründungen.',
                        style: GoogleFonts.zillaSlab(fontSize: 24, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Text(
                  '(Hubert Hüppe)',
                  style: GoogleFonts.zillaSlab(fontSize: 15, color: Colors.black),
                  textAlign: TextAlign.end,
                ),
                SizedBox(height: 10),
                Divider(),
                Container(
                    height: MediaQuery.of(context).size.height - 550,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                              'Bavaria ipsum dolor sit amet Graudwiggal nia i hob di liab i moan scho aa aba Prosd do. Oans, zwoa, gsuffa auffi d’, a Prosit der Gmiadlichkeit. Oa wann griagd ma nacha wos z’dringa ham Gams, blärrd? In da gwiss blärrd i sog ja nix, i red ja bloß und glei wirds no fui lustiga Namidog oamoi: Nomoi so nimma da Kini Kuaschwanz Sepp vo de. Graudwiggal singd gwihss, heid gfoids ma sagrisch guad di wolln des is hoid aso. Brezn fei i mog di fei Gstanzl kimmt Landla woaß, da?'),
                        ),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFD51031),
                        elevation: 0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () async {
                        await launch('https://klocka.app/impressum');
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.copyright_outlined, size: 20),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Impressum'),
                            )
                          ],
                        ),
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 20),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFD51031),
                        elevation: 0,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => OssLicensesPage())),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.gavel, size: 20),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Lizenzen'),
                            )
                          ],
                        ),
                      )),
                ),
              ],
            ),
          )),
    );
  }
}
