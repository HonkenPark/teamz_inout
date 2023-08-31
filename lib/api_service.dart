// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://pdrf.mediazenaicloud.com:36402";

  static Future<int> getInOutStatus(String user) async {
    String reqMethod = 'teamzInoutCheck';
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encodedUser = stringToBase64.encode(user);

    final url = Uri.parse('$baseUrl/$reqMethod/$encodedUser');
    print('url: $url');
    final response = await http.get(url);
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData.containsKey('result') &&
          jsonData['result'].contains('출근전')) {
        return 1;
      } else if (jsonData.containsKey('result') &&
          jsonData['result'].contains('근무중')) {
        return 2;
      } else if (jsonData.containsKey('result') &&
          jsonData['result'].contains('퇴근후')) {
        return 3;
      } else {
        return 4;
      }
    } else {
      return 4;
    }
  }

  static Future<bool> requestInOut(String user) async {
    String reqMethod = 'teamzInoutRequest';
    bool isFinish = false;
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encodedUser = stringToBase64.encode(user);

    final url = Uri.parse('$baseUrl/$reqMethod/$encodedUser');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      isFinish = true;
    } else {
      isFinish = false;
    }
    return isFinish;
  }
}
