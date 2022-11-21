// ignore_for_file: prefer_final_fields
import 'package:gluco/models/user.dart';
import 'package:gluco/models/measurement.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'dart:io';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'egluco.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE credentials (
        clientid TEXT NOT NULL PRIMARY KEY,
        refreshtoken TEXT NOT NULL,
        lastlogin DATE NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE users (
        iduser INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        clientid TEXT NOT NULL UNIQUE REFERENCES credentials(clientid) ON UPDATE CASCADE ON DELETE CASCADE,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        birthday DATE NOT NULL,
        weight REAL NOT NULL,
        height REAL NOT NULL,
        sex TEXT NOT NULL,
        diabetes_type TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE measurementscomp (
        idmeasurements INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        glucose REAL NOT NULL,
        spo2 INTEGER NOT NULL,
        pr_rpm INTEGER NOT NULL,
        date DATE NOT NULL,
        iduser INTEGER NOT NULL REFERENCES users(iduser) ON UPDATE CASCADE ON DELETE CASCADE
      );
    ''');
    await db.execute('''
      CREATE TABLE measurementscoll (
        idmeasurements INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        glucose REAL NOT NULL,
        spo2 INTEGER NOT NULL,
        pr_rpm INTEGER NOT NULL,
        temperature REAL NOT NULL,
        m1_4p REAL NOT NULL,
        m2_4p REAL NOT NULL,
        m3_4p REAL NOT NULL,
        m4_4p REAL NOT NULL,
        m5_4p REAL NOT NULL,
        m6_4p REAL NOT NULL,
        m7_4p REAL NOT NULL,
        m8_4p REAL NOT NULL,
        m9_4p REAL NOT NULL,
        m10_4p REAL NOT NULL,
        m11_4p REAL NOT NULL,
        m12_4p REAL NOT NULL,
        m13_4p REAL NOT NULL,
        m14_4p REAL NOT NULL,
        m15_4p REAL NOT NULL,
        m16_4p REAL NOT NULL,
        m17_4p REAL NOT NULL,
        m18_4p REAL NOT NULL,
        m19_4p REAL NOT NULL,
        m20_4p REAL NOT NULL,
        m21_4p REAL NOT NULL,
        m22_4p REAL NOT NULL,
        m23_4p REAL NOT NULL,
        m24_4p REAL NOT NULL,
        f1_4p REAL NOT NULL,
        f2_4p REAL NOT NULL,
        f3_4p REAL NOT NULL,
        f4_4p REAL NOT NULL,
        f5_4p REAL NOT NULL,
        f6_4p REAL NOT NULL,
        f7_4p REAL NOT NULL,
        f8_4p REAL NOT NULL,
        f9_4p REAL NOT NULL,
        f10_4p REAL NOT NULL,
        f11_4p REAL NOT NULL,
        f12_4p REAL NOT NULL,
        f13_4p REAL NOT NULL,
        f14_4p REAL NOT NULL,
        f15_4p REAL NOT NULL,
        f16_4p REAL NOT NULL,
        f17_4p REAL NOT NULL,
        f18_4p REAL NOT NULL,
        f19_4p REAL NOT NULL,
        f20_4p REAL NOT NULL,
        f21_4p REAL NOT NULL,
        f22_4p REAL NOT NULL,
        f23_4p REAL NOT NULL,
        f24_4p REAL NOT NULL,
        date DATE NOT NULL,
        iduser INTEGER NOT NULL REFERENCES users(iduser) ON UPDATE CASCADE ON DELETE CASCADE
      );
    ''');
  }

  /// Insere a medição no banco referenciando o usuário em questão
  Future<bool> insertMeasurementCompleted(
      User user, MeasurementCompleted measurement) async {
    Database db = await DatabaseHelper.instance.database;
    Map<String, Object?> data = measurement.toMap();
    data['iduser'] = user.id;
    return await db.insert(
          'idmeasurementscomp',
          data,
        ) !=
        0;
  }

  /// Busca pelas medições do usuário em questão
  Future<List<MeasurementCompleted>> queryMeasurementCompleted(User user,
      [int? quantity]) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, Object?>> measurements = await db.query(
      'measurementscomp',
      where: 'iduser = ?',
      whereArgs: [user.id],
      orderBy: 'date DESC',
      limit: quantity,
    );
    List<MeasurementCompleted> measurementsList =
        measurements.map((c) => MeasurementCompleted.fromMap(c)).toList();
    return measurementsList;
  }

  @Deprecated('Ainda não possui utilidade')
  Future<int> updateMeasurementCompleted(
      MeasurementCompleted measurement) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      'measurementscomp',
      measurement.toMap(),
      where: 'idmeasurements = ?',
      whereArgs: [measurement.id],
    );
  }

  @Deprecated('Ainda não possui utilidade')
  Future<int> deleteMeasurementCompleted(
      MeasurementCompleted measurement) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      'measurementscomp',
      where: 'idmeasurements = ?',
      whereArgs: [measurement.id],
    );
  }

  /// Insere a medição no banco referenciando o usuário em questão
  /// (usada quando não há conexão à internet)
  Future<bool> insertMeasurementCollected(
      User user, MeasurementCollected measurement) async {
    Database db = await DatabaseHelper.instance.database;
    Map<String, Object?> data = measurement.toMap();
    data['iduser'] = user.id;
    return await db.insert(
          'measurementscoll',
          data,
        ) !=
        0;
  }

  /// Busca pelas medições do usuário em questão
  /// (usada quando não há conexão à internet)
  Future<List<MeasurementCollected>> queryMeasurementCollected(
      User user) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, Object?>> measurements = await db.query(
      'measurementscoll',
      where: 'iduser = ?',
      whereArgs: [user.id],
      orderBy: 'date DESC',
    );
    List<MeasurementCollected> measurementsList =
        measurements.map((c) => MeasurementCollected.fromMap(c)).toList();
    return measurementsList;
  }

  /// Deleta medições do usuário em questão
  /// (usada quando não há conexão à internet)
  Future<int> deleteMeasurementCollected(
      MeasurementCollected measurement) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      'measurementscoll',
      where: 'idmeasurements = ?',
      whereArgs: [measurement.id],
    );
  }

  /// Insere os dados do usuário no banco
  Future<bool> insertUser(User user, String client_id) async {
    Database db = await DatabaseHelper.instance.database;
    Map<String, dynamic> data = user.toMap();
    data['clientid'] = client_id;
    return await db.insert('users', data) != 0;
  }

  /// Busca os dados do usuário com id correspondente,
  /// retorna um objeto usuário com os dados,
  /// retorna null caso contrário
  Future<User?> queryUser(User user) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, Object?>> userData = await db.query(
      'users',
      where: 'iduser = ?',
      whereArgs: [user.id],
    );
    return userData.isEmpty ? null : User.fromMap(userData.first);
  }

  // Busca os dados do usuário com client_id correspondente,
  // usado na primeira consulta após fazer login
  Future<User?> queryUserByClientID(String client_id) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, Object?>> userData = await db.query(
      'users',
      where: 'clientid = ?',
      whereArgs: [client_id],
    );
    return userData.isEmpty ? null : User.fromMap(userData.first);
  }

  /// Atualiza os dados do perfil do usuário
  Future<bool> updateUser(User user) async {
    Database db = await DatabaseHelper.instance.database;
    Map<String, Object?> data = user.toMap();
    return await db.update(
          'users',
          data,
          where: 'iduser = ?',
          whereArgs: [user.id],
        ) !=
        0;
  }

  @Deprecated('Ainda não possui utilidade')
  Future<int> deleteUser(User user) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      'users',
      where: 'iduser = ?',
      whereArgs: [user.id],
    );
  }

  /// Insere as credenciais no banco, se já existirem sobreescreve
  Future<bool> insertCredentials(String client_id, String refresh_token) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(
          'credentials',
          {
            'clientid': client_id,
            'refreshtoken': refresh_token,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        ) !=
        0;
  }

  /// Busca pelas credenciais mais recentes no banco,
  /// se encontrar retorna um mapa contendo client_id, refresh_token,
  /// caso contrário retorna null
  Future<Map<String, String>?> queryCredentials() async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, Object?>> credentials = await db.query('credentials',
        columns: ['clientid', 'refreshtoken'],
        orderBy: 'lastlogin DESC',
        limit: 1);
    return credentials.isEmpty
        ? null
        : credentials.first.cast<String, String>();
  }

  /// Remove do banco as credenciais relativas ao client_id em questão
  Future<bool> deleteCredentials(String client_id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
          'credentials',
          where: 'clientid = ?',
          whereArgs: [client_id],
        ) !=
        0;
  }
}
