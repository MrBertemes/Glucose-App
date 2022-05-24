// ignore_for_file: avoid_print, unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'collected.dart';
import '../db/measurements.dart';


class Api {
  
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
    var measurementJson = measurement.toMap();
    var stringJson = json.encode(measurementJson).toString();
    var paramName = 'param'; // Post parameter name
    var formBody = paramName + '=' + Uri.encodeQueryComponent(stringJson);
    var bodyBytes = utf8.encode(formBody);

    final client = RetryClient(http.Client());
    try {
      var response = await http.post(
        url,
        body: measurementJson,
        headers: {
          "Accept": "application/json",
          "Content-type": "application/x-www-form-urlencoded",
          "Content-lenght": bodyBytes.length.toString(),
        },
        encoding: Encoding.getByName("utf-8"),
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

  Future<int> postDataStream(String dataStream) async {
    var success =1;

    final client = RetryClient(http.Client());
    try {
      var response = await http.post(
        url,
        body: dataStream,
        headers: {
          "Accept": "application/json",
          "Content-type": "text/plain",
          "Content-lenght": dataStream.length.toString(),
        },
        encoding: Encoding.getByName("utf-8"),
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
