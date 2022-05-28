// ignore_for_file: body_might_complete_normally_nullable, unused_import

import 'dart:convert';
import '../models/loginmodel.dart';

// Papo que era pra deixar junto em db/measurements.dart mas preferi fazer separado pra não dar conflito
// não faz nem sentido esse nome
class AuthDB {
  static Future<bool> isLoggedIn() async {
    /* Algo nesse sentido, mas não pesquisei muito sobre sqflite ainda
    // credentials seria uma tabela separada contendo email, senha, e id do usuário?
    // corresponderia ao usuário logado atualmente, mas o banco ainda poderia ter dados
    // salvos de outros usuários
    Database db = await instance.database;
    List<Map<String, Object?>> credentials;
    credentials = await db.query('credentials');
    return credentials.isEmpty;
    */
    return true;
  }

  static Future<LoginResponseModel?> getCredentials() async {
    if (await isLoggedIn()) {
      /*
      Database db = await instance.database;
      List<Map<String, Object?>> login = await db.query('credentials');
      return LoginResponseModel.fromMap(jsonDecode(login));
      */
    }
  }

  static Future<void> setCredentials(LoginResponseModel loginResponse) async {
    /*
    Database db = await instance.database;
    await db.insert(
      'credentials',
      jsonEncode(loginResponse.toMap()),
    );
    */
  }

  static Future<void> logout() async {
    /*
    Database db = await instance.database;
    await db.delete(
      'credentials',
    );
    */
  }
}
