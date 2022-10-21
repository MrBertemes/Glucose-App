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
      CREATE TABLE measurements (
        idmeasurements INTEGER PRIMARY KEY,
        glucose REAL,
        spo2 INTEGER,
        pr_rpm INTEGER,
        date TEXT,
        iduser INTEGER,
        FOREIGN KEY (iduser) REFERENCES users(iduser)
      );
    ''');
    await db.execute('''
      CREATE TABLE users (
        iduser INTEGER PRIMARY KEY,
        email TEXT,
        name TEXT,
        birthdate TEXT,
        weight REAL,
        height REAL,
        sex TEXT,
        diabetes TEXT
      );
    ''');
    await db.execute('''
      CREATE TABLE credentials (
        clientid TEXT PRIMARY KEY,
        refreshtoken TEXT,
        lastlogin TEXT
      )
    ''');
  }

  /// Insere a medição no banco referenciando o usuário em questão
  Future<bool> insertMeasurement(
      User user, MeasurementCompleted measurement) async {
    Database db = await DatabaseHelper.instance.database;
    Map<String, Object?> data = measurement.toMap();
    data['iduser'] = user.id;
    return await db.insert(
          'measurements',
          data,
        ) !=
        0;
  }

  /// Busca pelas medições do usuário em questão
  Future<List<MeasurementCompleted>> queryMeasurements(User user,
      [int? quantity]) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, Object?>> measurements = await db.query(
      'measurements',
      where: 'iduser = ?',
      whereArgs: [user.id],
      orderBy: 'idmeasurements DESC',
      limit: quantity,
    );
    List<MeasurementCompleted> measurementsList =
        measurements.map((c) => MeasurementCompleted.fromMap(c)).toList();
    return measurementsList;
  }

  @Deprecated(
      'Ainda não possui utilidade, possivelmente insere errado visto que o id do banco local é auto incremental e deve ser substituido pelo id do banco remoto')
  Future<int> updateMeasurement(MeasurementCompleted measurement) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      'measurements',
      measurement.toMap(),
      where: 'idmeasurements = ?',
      whereArgs: [measurement.id],
    );
  }

  @Deprecated(
      'Ainda não possui utilidade, possivelmente insere errado visto que o id do banco local é auto incremental e deve ser substituido pelo id do banco remoto')
  Future<int> deleteMeasurement(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      'measurements',
      where: 'idmeasurements = ?',
      whereArgs: [id],
    );
  }

  /// Insere os dados do usuário no banco
  Future<bool> insertUser(User user) async {
    Database db = await DatabaseHelper.instance.database;
    //
    List<Map> id = await db.rawQuery(
        'select max(iduser) as id from users'); // jeito burro mas enfim
    //
    return await db.insert(
          'users',
          // como eu separei o campo perfil na classe user,
          // não dá pra usar o user.toMap() '-'
          {
            // 'iduser': user.id,
            //
            // 'iduser': (int.tryParse(id[0]['id'] ?? '') ?? 0) + 1,
            'iduser': (id[0]['id'] ?? -1) + 1,
            //
            'email': user.email,
            'name': user.name,
            'birthdate': user.profile!.birthdate.toString(),
            'weight': user.profile!.weight,
            'height': user.profile!.height,
            'sex': user.profile!.sex,
            'diabetes': user.profile!.diabetes,
          },
        ) !=
        0;
  }

  /// Busca os dados de perfil do usuário com email correspondente,
  /// retorna um mapa contendo os dados se encontrar e
  /// retorna null caso contrário
  Future<Map<String, Object?>?> queryUser(User user) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, Object?>> userProfile = await db.query(
      'users',
      // where: 'iduser = ?',
      // whereArgs: [user.id],
      //
      where: 'email = ?',
      whereArgs: [user.email],
      //
    );
    return userProfile.isEmpty ? null : userProfile.first;
  }

  /// Atualiza os dados do perfil do usuário
  Future<bool> updateUser(User user) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
          'users',
          {
            'birthdate': user.profile!.birthdate.toString(),
            'weight': user.profile!.weight,
            'height': user.profile!.height,
            'sex': user.profile!.sex,
            'diabetes': user.profile!.diabetes,
          },
          // where: 'iduser = ?',
          // whereArgs: [user.id],
          //
          where: 'email = ?',
          whereArgs: [user.email],
          //
        ) !=
        0;
  }

  @Deprecated(
      'Ainda não possui utilidade, em que momento os dados de um usuário serão apagados?')
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
            // inclui um marcador de último acesso pra poder selecionar
            // o usuário mais recentemente logado no caso de possibilitar
            // login com múltiplas contas no futuro
            'lastlogin': DateTime.now().toString(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        ) !=
        0;
  }

  /// Busca pelas credenciais mais recentes no banco,
  /// se encontrar retorna um mapa contendo client_id e refresh_token,
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
