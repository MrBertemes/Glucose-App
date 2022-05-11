import 'package:gluco/models/client.dart';
import '../models/collected.dart';
import 'package:flutter/material.dart';
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
      CREATE TABLE measurements(
        id INTEGER PRIMARY KEY
        spo2 INTEGER
        temperature REAL
        glucose REAL
        bpm INTEGRER
        FOREIGN KEY(clientid) REFERENCES clients(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE clients(
        id INTEGER PRIMARY KEY
        email TEXT
        password TEXT
        name TEXT
        age INTEGER
        weight REAL
        height REAL
        sex TEXT
        diabetes INTEGER
      )
    ''');
  }

  Future<List<Collected>> getMeasurements() async {
    Database db = await instance.database;
    List<Map<String, Object?>> measurements;
    measurements = await db.query('measurements', orderBy: 'id');

    List<Collected> measurementsList = measurements.isNotEmpty
        ? measurements.map((e) => Collected.fromMap(e)).toList()
        : [];
    return measurementsList;
  }

  Future<int> addMeasurement(Collected measurement) async {
    Database db = await instance.database;
    return await db.insert(
      'measurements',
      measurement.toMap(),
    );
  }

  Future<int> updateMeasurements(Collected measurement) async {
    Database db = await instance.database;
    return await db.update(
      'measurements',
      measurement.toMap(),
      where: 'id = ?',
      whereArgs: [measurement.id],
    );
  }

  Future<int> updateCient(Client client) async {
    Database db = await instance.database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> removeMeasurement(int id) async {
    Database db = await instance.database;
    return await db.delete(
      'measurements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
