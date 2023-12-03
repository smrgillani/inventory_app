import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> getData(String endPoint) async {
  final url = Uri.parse('https://api.example.com/data'); // Replace with your API endpoint

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Successful API call
      final jsonData = json.decode(response.body); // Parse JSON response

      // Handle and use the JSON data as needed
      print(jsonData);
    } else {
      // Handle error cases
      print('Failed to fetch data: ${response.statusCode}');
    }
  } catch (exception) {
    print('Error: $exception');
  }
}


Future<Map<String, dynamic>> getToken() async {
  Map<String, dynamic> respData = {};

  try {
    final tokenUrl = Uri.parse(
        'http://192.168.0.14/connector/api/business-register'); // Replace with the token endpoint URL
    final response = await http.get(
      tokenUrl,
      headers: {
        'Host': '10.71.23.166',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;

      respData['cookies'] = response.headers['set-cookie'];
      respData['body'] = responseBody;

      String xsrfToken = "";
      String cedarValleySession = "";
      List<String> cookieParts = respData['cookies'].split(';');
      for (String cookie in cookieParts) {
        if (cookie.contains("XSRF-TOKEN=")) {
          xsrfToken = cookie.split("=")[1];
          xsrfToken = xsrfToken.split(";")[0];
        } else if (cookie.contains("_session=")) {
          cedarValleySession = cookie.split(",")[1];
          cedarValleySession = cedarValleySession.split("=")[1];
          cedarValleySession = cedarValleySession.split(";")[0];
        }
      }

      respData['cookies'] = 'XSRF-TOKEN=$xsrfToken; cedar_valley_session=$cedarValleySession';
    }
  }catch(e){}

  return respData;
}

Future<Map<String, dynamic>> sendFormData(Map<String, dynamic> formData, String cookie) async {
  const String url = 'http://192.168.0.14/connector/api/business-register';
  // final String filePath = '/path/to/your/file.png';

  final headers = {
    "cache-control":"no-cache",
    'Cookie': cookie
  };

  // Create a multipart request
  final request = http.MultipartRequest('POST', Uri.parse(url))..headers.addAll(headers);

  request.fields['_token'] = formData['token'];
  request.fields['data'] = formData['data'];

  // Add a file to be uploaded
  // request.files.add(await http.MultipartFile.fromPath('file', filePath));

  // Send the request
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  Map<String, dynamic> bodyResponse = <String, dynamic>{};

  try{
    bodyResponse = json.decode(response.body);
    print("error in try");
  }catch(e){
    print("error in catch");
    if(response.statusCode == 419){
      bodyResponse['sucess'] = false;
      Map<String, dynamic> errors = {};
      errors['page_expiry'] = ["Session Expired: Please try again to continue with registration. Apologies for the inconvenience. Thank you for your understanding."];
      bodyResponse['errors'] = false;
    }
  }

  // if (response.statusCode == 200) {
  //   responseBody
  //   print('POST Response Data: ${response.body}');
  // } else {
  //   print('POST Request Failed with Status Code: ${response.body} ${response.statusCode}');
  // }

  return bodyResponse;
}
