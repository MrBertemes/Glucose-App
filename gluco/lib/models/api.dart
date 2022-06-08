// ignore_for_file: avoid_print, unused_import

import 'dart:async';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'collected.dart';
import '../db/databasehelper.dart';

class Api {
  Uri url = Uri.parse('http://159.223.221.13/');

  Future<dynamic> fetchMeasurements(int id, String name) async {
    Collected? measurement;
    var token = await generateToken(id, name);
    final client = RetryClient(http.Client());
    try {
      var response = await http.get(url, headers: {
        "access-token": token,
        "Content-Type": "application/json",
      });
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
      if (response.statusCode == 200) {
        // success
        success = 0;
        return success;
      }
    } finally {
      client.close();
    }
    return success;
  }

  Future<int> postDataStream(String dataStream) async {
    var success = 1;

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
      if (response.statusCode == 200) {
        // success
        success = 0;
        return success;
      }
    } finally {
      client.close();
    }
    return success;
  }

  Future<String> generateToken(int id, String name) async {
    await dotenv.load();
    var _secret = dotenv.get('MOT');

    // JWT
    // header
    var header = {
      "alg": "HS256",
      "typ": "JWT",
    };
    var header64 = base64Encode(jsonEncode(header).codeUnits);

    // Payload
    var payload = {
      "sub": id, // id
      "name": name,
      "exp": DateTime.now().microsecondsSinceEpoch +
          2400000, // 1 hora de expiração
    };
    var payload64 = base64Encode(jsonEncode(payload).codeUnits);

    // signature
    var hmac = Hmac(sha256, _secret.codeUnits);
    var digest = hmac.convert("$header64.$payload64".codeUnits);
    var sign = base64Encode(digest.bytes);

    return "$header64.$payload64.$sign";
  }
}
