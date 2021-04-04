import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class StorageService {
  static late SharedPreferences _storage; // ohne late --> nicht nullable  sonst nullable type
  static Future<void> init() async => _storage = await SharedPreferences.getInstance(); // storage initalisiert!

  static bool get isFirstStart => _storage.getBool('isFirstStart') ?? true;
  static set isFirstStart(bool startup) => _storage.setBool('isFirstStart', startup);

  static bool get isSubscribed => _storage.getBool('isSubscribed') ?? true;
  static set isSubscribed(bool isSubscribed) => _storage.setBool('isSubscribed', isSubscribed);

  static bool get isFirstMain => _storage.getBool('isFirstMain') ?? true;
  static set isFirstMain(bool isFirstMain) => _storage.setBool('isFirstMain', isFirstMain);

  static String get companyLink => _storage.getString('companyLink') ?? '';
  static set companyLink(String companyLink) => _storage.setString('companyLink', companyLink);

  static RegisterData? get registerData => get('register-data');
  static set registerData(RegisterData? registerData) => set('register-data', registerData);

  static T? get<T>(String key) => JsonMapper.deserialize<T>(_storage.getString(key));
  static void set<T>(String key, T? value) =>
      value != null ? _storage.setString(key, JsonMapper.serialize(value)) : _storage.remove(key);
}
