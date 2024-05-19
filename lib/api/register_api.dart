import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupApi {
  static const List<String> hosts = [
    'http://192.168.1.12:8080', //pubg-4g bahria
       //'http://172.20.3.2:8080', //bahria faculty
    // 'http://192.168.1.11:5000',
    // 'http://192.168.1.132:8080', //home
    // 'http://127.0.0.1:8080', //localhost
    // 'http://172.20.10.2:8080', //hotspot personal
    //'http://172.28.3.253:8080', //bahria student
    // 'http://192.168.1.15:8080' //sharjeel home


  ];
  static const String basePath = '/api/v1/auth/signup';
  static final storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> sigup(
      String firstName,
      String lastName,
      String username,
      String email,
      String password,
      ) async {
    for (String host in hosts) {
      try {
        final url = '$host$basePath';
        final response = await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'firstName': firstName,
            'lastName': lastName,
            'username': username,
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          final authToken = responseBody['authToken'];
          final userRole = responseBody['user']['role'];
          await storage.write(key: 'authToken', value: authToken);
          await storage.write(key: 'userRole', value: userRole);
          return {'success': true, 'role': userRole};
        } else {
          print('Failed to signup at $host: ${response.body}');
        }
      } catch (e) {
        print('Failed to connect to $host: $e');
      }
    }

    return {'success': false, 'error': 'Unable to create account'};
  }
}
