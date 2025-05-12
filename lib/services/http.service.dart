import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class RestSerice {

  //connection string for mobile or tablet
  final String url = "http://192.168.40.12/connector/api";

  //connection string for desktop
  // final String url = "http://127.0.0.1/connector/api";

  Future<Map<String, String>?> getHeaders({bool isMultipart = false}) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedToken = prefs.getString("access_token") ?? "";

    Map<String, String>? headers = {};

    if(isMultipart) {
      headers["Content-Type"] = "multipart/form-data";
    }else{
      headers["Content-Type"] = "application/json";
    }

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
      final response = await http.post(url, headers: await getHeaders(), body: jsonEncode(body));
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

  Future<dynamic> postMultipartData(String endPoint, Map<String, String> body, Iterable<http.MultipartFile> files) async {
    final url = Uri.parse(this.url + endPoint);
    try {

      var request = http.MultipartRequest('POST', url);

      request.fields.addAll(body);

      request.files.addAll(files);

      request.headers.addAll(await getHeaders(isMultipart: true) as Map<String, String>);

      final response = await request.send();

      String resp = await response.stream.bytesToString();

      // print(request.fields);
      // print(resp + " >> " + files.length.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(await response.stream.bytesToString());
        return jsonData;
      } else {
        return {};
      }

    } catch (exception) {
      return {'error': exception};
    }
  }

  Future<dynamic> putMultipartData(String endPoint, Map<String, String> body, Iterable<http.MultipartFile> files) async {
    final url = Uri.parse(this.url + endPoint);
    try {

      var request = http.MultipartRequest('POST', url);

      request.fields.addAll(body);

      request.fields["_method"] = "PUT";

      request.files.addAll(files);

      request.headers.addAll(await getHeaders(isMultipart: true) as Map<String, String>);

      final response = await request.send();

      // print(" Fields :=> ${request.fields}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(await response.stream.bytesToString());
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
      final response = await http.put(url, headers: await getHeaders(), body: jsonEncode(body));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData;
      } else {
        return {};
      }
    } catch (exception) {
      print("Error $exception");
      return {'error': exception};
    }
  }

}