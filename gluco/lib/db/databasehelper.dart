// ignore_for_file: prefer_final_fields
import 'package:gluco/models/user.dart';
import 'package:gluco/view/historicoteste.dart';
import 'package:intl/intl.dart';
import '../models/collected.dart';
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
    String path = join(documentsDirectory.path, 'measurements.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        spo INTEGER,
        temperature REAL,
        date TEXT,
        glucose REAL,
        bpm INTEGRER
      );
    ''');
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT,
        name TEXT,
        age INTEGER,
        weight REAL,
        height REAL,
        sex TEXT,
        diabetes INTEGER
      );
    ''');
  }

  Future<List<Collected?>> getMeasurements() async {
    Database db = await DatabaseHelper.instance.database;
    List<Map<String, Object?>> measurements;
    measurements = await db.query('measurements', orderBy: 'id');

    List<Collected?> measurementsList = measurements.isNotEmpty
        ? measurements.map((e) {
            if (e.isNotEmpty) {
              for (var k in e.keys) {
                if (k == 'date') {
                  var tmp = DateTime.parse(e[k] as String);
                  e[k] = tmp;
                }
              }
              var c = Collected?.fromMap(e);
              return c;
            }
            return null;
          }).toList()
        : [];
    return measurementsList;
  }

  Future<int> addMeasurement(Collected measurement) async {
    Database db = await DatabaseHelper.instance.database;
    var res = 0;

    var _cDB = {
      'spo': measurement.saturacao,
      'temperature': measurement.temperatura,
      'date': measurement.data.toString(),
      'glucose': measurement.glicose,
      'bpm': measurement.batimento,
    };

    var dB = {
      'spo': 1,
      'temperature': 1.2,
      'date': 'dia',
      'glucose': 2.2,
      'bpm': 30,
    };

    if (db.isOpen) {
      res = await db.insert(
        'measurements',
        _cDB,
      );
    }
    return res;
  }

  Future<int> updateMeasurements(Collected measurement) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      'measurements',
      measurement.toMap(),
      where: 'id = ?',
      whereArgs: [measurement.id],
    );
  }

  Future<int> removeMeasurement(int id) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.delete(
      'measurements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Future<List<User>> getUser(User c) async {
  //   Database db = await DatabaseHelper.instance.database;
  //   List<Map<String, Object?>> user;
  //   user = await db.rawQuery('''
  //     SELECT * FROM clients WHERE email='${c.email}'
  //     '''); // Pega a tupla que tem o email do cliente passado como parametro

  //   List<User> userList =
  //       user.isNotEmpty ? user.map((e) => User.fromMap(e)).toList() : [];
  //   return userList;
  // }

  Future<int> updateUser(User user) async {
    Database db = await DatabaseHelper.instance.database;
    return await db.update(
      'clients',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.profile!.id],
    );
  }
}
