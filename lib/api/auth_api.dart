import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1/auth';
  static final storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
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
        return {'success': false, 'error': 'Invalid credentials'};
      }
    } catch (e) {
      print('Exception during login: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
