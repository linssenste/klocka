import 'dart:io';

import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:http/http.dart' as http;

import 'storage_service.dart';

@jsonSerializable
class RegisterAddrData {
  String city, zip, street;

  RegisterAddrData(this.city, this.zip, this.street);
}

@jsonSerializable
class RegisterCompanyData {
  String name, contact;
  String? website;

  RegisterCompanyData(this.name, this.contact, this.website);
}

@jsonSerializable
class RegisterData {
  RegisterAddrData address;
  RegisterCompanyData company;
  String? password;

  RegisterData(this.address, this.company, this.password);
}

class ApiService {
  static String baseUrl = 'https://klocka.app';

  static Future<bool> login(String id, String password) async {
    var response = await http.post(Uri.parse('$baseUrl/auth/$id'), body: {'password': password});

    if (response.statusCode == 200) {
      var data = JsonMapper.deserialize<RegisterData>(response.body);
      StorageService.registerData = data;
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> register(String id, RegisterData registerData) async {
    print(JsonMapper.serialize(registerData));
    var response =
        await http.post(Uri.parse('$baseUrl/register/$id'), body: JsonMapper.serialize(registerData), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
    });
    print(response.statusCode);
    if (response.statusCode == 200) {
      var data = JsonMapper.deserialize<RegisterData>(response.body);
      StorageService.registerData = data;
      return true;
    } else {
      return false;
    }
  }

  static Future<bool?>? registerable(String id) async {
    var response = await http.get(Uri.parse('$baseUrl/exists/$id'));

    if (response.statusCode == 401) {
      return false;
    } else if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }
  }
}
