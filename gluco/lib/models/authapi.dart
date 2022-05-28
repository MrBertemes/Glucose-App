import 'dart:convert';
import 'package:http/http.dart' as http;

import '../db/authdb.dart';
import 'loginmodel.dart';
import 'signupmodel.dart';

class AuthAPI {
  static final _client = http.Client();

  static Future<bool> login(LoginRequestModel model) async {
    var url = Uri.http('egluco.bio.br', '/users/login');

    var response = await _client.post(
      url,
      body: jsonEncode(model.toMap()),
      headers: {
        'Content-type': 'application/json',
      },
    );

    switch (response.statusCode) {
      case 200:
        await AuthDB.setCredentials(
          LoginResponseModel.fromMap(jsonDecode(response.body)),
        );
        return true;
      default:
        return false;
    }
  }

  static Future<SignUpResponseModel> signUp(SignUpRequestModel model) async {
    var url = Uri.http('egluco.bio.br', '/users/signup');

    var response = await _client.post(
      url,
      body: jsonEncode(model.toMap()),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    return SignUpResponseModel.fromMap(jsonDecode(response.body));
  }

  static Future<String> getUserProfile() async {
    var loginDetails = await AuthDB.getCredentials();

    var url = Uri.http('egluco.bio.br', '/users/userprofile');

    var response = await _client.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ${loginDetails!.data.token}',
      },
    );

    switch (response.statusCode) {
      case 200:
        return response.body;
      default:
        return '';
    }
  }
}
