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

  static String get companyDetails => _storage.getString('companyDetails') ?? '';
  static set companyDetails(String companyDetails) => _storage.setString('companyDetails', companyDetails);

  static String get companyName => _storage.getString('companyName') ?? '';
  static set companyName(String companyName) => _storage.setString('companyName', companyName);

  static String get contactName => _storage.getString('contactName') ?? '';
  static set contactName(String contactName) => _storage.setString('contactName', contactName);

  static String get streetName => _storage.getString('streetName') ?? '';
  static set streetName(String streetName) => _storage.setString('streetName', streetName);

  static String get zipCode => _storage.getString('zipCode') ?? '';
  static set zipCode(String zipCode) => _storage.setString('zipCode', zipCode);

  static String get cityName => _storage.getString('cityName') ?? '';
  static set cityName(String cityName) => _storage.setString('cityName', cityName);

  static String get lastRing => _storage.getString('lastRing') ?? '';
  static set lastRing(String lastRing) => _storage.setString('lastRing', lastRing);

  static RegisterData? get registerData => get('register-data');
  static set registerData(RegisterData? registerData) => set('register-data', registerData);

  static T? get<T>(String key) => JsonMapper.deserialize<T>(_storage.getString(key));
  static void set<T>(String key, T? value) =>
      value != null ? _storage.setString(key, JsonMapper.serialize(value)) : _storage.remove(key);
}
