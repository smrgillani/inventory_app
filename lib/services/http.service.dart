import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RestSerice {

  final String url = "http://10.72.29.212/connector/api";

  Future<Map<String, String>?> getHeaders() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedToken = prefs.getString("access_token") ?? "";

    Map<String, String>? headers = {};

    if((storedToken.isNotEmpty)){
      headers["Authorization"] = "Bearer $storedToken";
    }

    return headers;
  }

  Future<dynamic> delData(String endPoint) async {
    final url = Uri.parse(this.url + endPoint);
    try {
      final response = await http.delete(url, headers: await getHeaders());
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        return {};
      }
    } catch (exception) {
      return {'error': exception};
    }
  }

  Future<dynamic> getData(String endPoint) async {
    final url = Uri.parse(this.url + endPoint);
    try {
      final response = await http.get(url, headers: await getHeaders());
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        return {};
      }
    } catch (exception) {
      return {'error': exception};
    }
  }

  Future<dynamic> postData(String endPoint, Map<String, dynamic> body) async {
    final url = Uri.parse(this.url + endPoint);
    try {
      final response = await http.post(url, headers: await getHeaders(), body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        return {};
      }
    } catch (exception) {
      return {'error': exception};
    }
  }

  Future<dynamic> putData(String endPoint, Map<String, dynamic> body) async {
    final url = Uri.parse(this.url + endPoint);
    try {
      final response = await http.put(url, headers: await getHeaders(), body: body);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        return {};
      }
    } catch (exception) {
      return {'error': exception};
    }
  }

}