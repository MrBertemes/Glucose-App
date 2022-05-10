// ignore_for_file: avoid_print

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:firebase/firebase_io.dart';
// import 'package:firebase/firestore.dart';
// import '../models/collected.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {

  Database();

  var db = FirebaseFirestore.instance;

  void addNewMeasurement(Map<String, dynamic> measureMap) {
    db.collection("measures").add(measureMap).then((DocumentReference doc) =>
        print('DocumentSnapshot added with ID: ${doc.id}'));
  }
}
