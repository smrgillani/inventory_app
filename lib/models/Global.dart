
// Global variable to store the map
import 'dart:convert';
import '../services/http.service.dart';

Map<String, dynamic> erpGlobals = {};

Future<void> fetchGlobalData() async {

  try {

    dynamic resp = await RestSerice().getData("/business-details");

    erpGlobals = resp['data'];

  } catch (e) {

    print('Error fetching global map: $e');

  }

}
