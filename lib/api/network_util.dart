import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NetworkUtil {
  static final List<String> hosts = [
    'http://192.168.1.12:8080', //pubg-4g bahria
    // 'http://172.20.3.2:8080', //bahria faculty
    // 'http://172.20.10.2:8080',
    // 'http://192.168.1.132:8080', //home
    // 'http://172.20.1.185:8080',
    // 'http://127.0.0.1:8080', //localhost
    // 'http://172.20.10.2:8080', //hotspot personal
    // 'http://172.28.3.253:8080', //bahria student
    // 'http://192.168.1.15:8080' //sharjeel home

   ];
  static final storage = FlutterSecureStorage();

  static Future<http.Response?> tryRequest(String path, {required Map<String, String> headers, String method = 'GET', dynamic body}) async {
    for (String host in hosts) {
      try {
        var url = Uri.parse('$host$path');
        http.Response response;
        if (method == 'POST') {
          response = await http.post(url, headers: headers, body: jsonEncode(body));
        } else {
          response = await http.get(url, headers: headers);
        }
        if (response.statusCode < 400) {
          return response;
        } else {
          print('Request to $url failed with status ${response.statusCode}');
        }
      } catch (e) {
        print('Exception when connecting to $host: $e');
      }
    }
    return null;
  }
}
