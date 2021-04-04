import 'package:Klocka/screens/toolbar_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../oss_licenses.dart';

class OssLicensesPage extends StatelessWidget {
  static Future<List<String>> loadLicenses() async {
    // merging non-dart based dependency list using LicenseRegistry.
    final ossKeys = ossLicenses.keys.toList();
    final lm = <String, List<String>>{};
    await for (var l in LicenseRegistry.licenses) {
      for (var p in l.packages) {
        if (!ossKeys.contains(p)) {
          final lp = lm.putIfAbsent(p, () => []);
          lp.addAll(l.paragraphs.map((p) => p.text));
          ossKeys.add(p);
        }
      }
    }
    for (var key in lm.keys) {
      ossLicenses[key] = {'license': lm[key]!.join('\n')};
    }
    return ossKeys..sort();
  }

  static final _licenses = loadLicenses();

  @override
  Widget build(BuildContext context) {
    return ToolbarWidget(
        'Lizenzen',
        FutureBuilder<List<String>>(
            future: _licenses,
            builder: (context, snapshot) {
              return ListView.separated(
                shrinkWrap: true, //just set this property
                padding: const EdgeInsets.only(right: 10, left: 10),
                itemCount: snapshot.data?.length ?? 0,
                itemBuilder: (context, index) {
                  final key = snapshot.data![index];
                  final licenseJson = ossLicenses[key] as Map<String, dynamic>;
                  final version = licenseJson['version'];
                  return ListTile(
                      title: Text('$key ${version ?? ''}'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => MiscOssLicenseSingle(name: key, json: licenseJson))));
                },
                separatorBuilder: (context, index) => const Divider(),
              );
            }));
  }
}

class MiscOssLicenseSingle extends StatelessWidget {
  final String name;
  final Map<String, dynamic> json;

  String? get version => json['version'] as String?;
  String? get description => json['description'] as String?;
  String? get licenseText => json['license'] as String?;
  String? get homepage => json['homepage'] as String?;

  MiscOssLicenseSingle({required this.name, required this.json});

  String _bodyText() {
    return licenseText!.split('\n').map((line) {
      if (line.startsWith('//')) line = line.substring(2);
      line = line.trim();
      return line;
    }).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$name ${version ?? ''}'),
        backgroundColor: Color(0xFFD51031),
      ),
      body: Container(
          color: Theme.of(context).canvasColor,
          child: ListView(children: <Widget>[
            if (description != null)
              Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                  child: Text(description!,
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(fontWeight: FontWeight.bold))),
            if (homepage != null)
              Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
                  child: InkWell(
                    onTap: () => launch(homepage!),
                    child: Text(homepage!,
                        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
                  )),
            if (description != null || homepage != null) const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 12.0, right: 12.0),
              child: Text(_bodyText(), style: Theme.of(context).textTheme.bodyText2),
            ),
          ])),
    );
  }
}
