// ignore_for_file: avoid_print, unused_import

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'collected.dart';
import '../db/measurements.dart';


class Api {
  DatabaseHelper db = DatabaseHelper.instance;
  Uri url = Uri.parse('http://159.223.221.13/');

  Future<dynamic> fetchMeasurements() async {
    Collected? measurement;
    var token = "tokenLegal";
    final client = RetryClient(http.Client());
    try {
      var response = await http.get(url, headers: {"token":token});
      if (response.statusCode == 200) {
        // success
        var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        measurement = Collected.fromMap(jsonResponse);
        return measurement;
      } else {
        // failure
        print('Request failed with status: ${response.statusCode}.');
      }
    } finally {
      client.close();
    }
    return;
  }

  Future<int> postMeasurements(Collected measurement) async {
    var success = 1;
    var json = measurement.toMap();
    final client = RetryClient(http.Client());
    try {
      var response = await http.post(
        url,
        body: json,
      );
      if (response.statusCode == 200) { // success
        success = 0;
        return success;
      }
    } finally {
      client.close();
    }
    return success;
  }
}
