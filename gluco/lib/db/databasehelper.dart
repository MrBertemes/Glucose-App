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
    // a primary key tá como autoincrement mas provavelmente será usada só pra teste,
    // o id vai ser o mesmo do banco do phpmyadmin, retornado pela requisição, isso?
    await db.execute('''
      CREATE TABLE measurements (
        idmeasurements INTEGER PRIMARY KEY AUTOINCREMENT,
        glucose REAL,
        sats INTEGER,
        bpm INTEGER,
        temperature REAL,
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
        email TEXT PRIMARY KEY,
        password TEXT,
        lastlogin TEXT
      )
    ''');
  }

  /// Insere a medição no banco referenciando o usuário em questão
  Future<bool> insertMeasurement(User user, Measurement measurement) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(
          'measurements',
          // como o id de measurements ainda está como auto incremental,
          // não dá pra usar measurement.toMap(),
          // além de que faltaria a chave estrangeira referenciado o usuário
          {
            'glucose': measurement.glucose,
            'sats': measurement.sats,
            'bpm': measurement.bpm,
            'temperature': measurement.temperature,
            'date': measurement.date.toString(),
            'iduser': user.id,
          },
        ) !=
        0;
  }

  /// Busca pelas medições do usuário em questão
  Future<List<Measurement>> queryMeasurements(User user,
      [int? quantity]) async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, Object?>> measurements = await db.query(
      'measurements',
      where: 'iduser = ?',
      whereArgs: [user.id],
      orderBy: 'idmeasurements DESC',
      limit: quantity,
    );
    List<Measurement> measurementsList =
        measurements.map((c) => Measurement.fromMap(c)).toList();
    return measurementsList;
  }

  @Deprecated(
      'Ainda não possui utilidade, possivelmente insere errado visto que o id do banco local é auto incremental e deve ser substituido pelo id do banco remoto')
  Future<int> updateMeasurement(Measurement measurement) async {
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
    return await db.insert(
          'users',
          // como eu separei o campo perfil na classe user,
          // não dá pra usar o user.toMap() '-'
          {
            'iduser': user.id,
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
      where: 'iduser = ?',
      whereArgs: [user.id],
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
          where: 'iduser = ?',
          whereArgs: [user.id],
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
  Future<bool> insertCredentials(String email, String password) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.insert(
          'credentials',
          {
            'email': email,
            'password': password,
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
  /// se encontrar retorna um mapa contendo email e senha,
  /// caso contrário retorna null
  Future<Map<String, String>?> queryCredentials() async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, Object?>> credentials = await db.query('credentials',
        columns: ['email', 'password'], orderBy: 'lastlogin DESC', limit: 1);
    return credentials.isEmpty
        ? null
        : credentials.first.cast<String, String>();
  }

  /// Remove do banco as credenciais relativas ao email em questão
  Future<bool> deleteCredentials(String email) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
          'credentials',
          where: 'email = ?',
          whereArgs: [email],
        ) !=
        0;
  }
}
