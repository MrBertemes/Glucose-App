// ignore_for_file: unused_import, unnecessary_new

import 'package:flutter/foundation.dart';

class Client {
   int id;
   String email;
   String name;
   int age;
   double weight;
   double height;
   String sex;
   int diabetes;

  Client({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.sex,
    required this.diabetes
  });

  factory Client.fromMap(Map<String, dynamic> json) => new Client(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    age: json['batimento'],
    weight: json['glicose'],
    height: json['temperatura'],
    sex: json['data'],
    diabetes: json['diabetes'],
  );


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'sex' : sex,
      'diabetes' : diabetes,
    };
  }
  
}
