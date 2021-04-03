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

  RegisterData(this.address, this.company);
}

class ApiService {
  static String baseUrl = 'https://europe-west3-ringring-6a70f.cloudfunctions.net/api';

  static login(String id, String password) async {
    var response = await http.post(Uri.parse('$baseUrl/auth/$id'), body: {'password': password});

    if (response.statusCode == 200) {
      var data = JsonMapper.deserialize<RegisterData>(response.body);
      StorageService.registerData = data;
    }
  }

  static codeExists(String id) async {
    var response = await http.get(Uri.parse('$baseUrl/exists/$id'));
  }
}
