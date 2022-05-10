// ignore_for_file: unused_import, unnecessary_new

import 'package:flutter/foundation.dart';

class Collected {
   int saturacao;
   int batimento;
   double glicose;
   double temperatura;
   DateTime data;

  Collected({
    required this.saturacao,
    required this.batimento,
    required this.glicose,
    required this.temperatura,
    required this.data,
  });

  factory Collected.fromMap(Map<String, dynamic> json) => new Collected(
    saturacao: json['saturacao'],
    batimento: json['batimento'],
    glicose: json['glicose'],
    temperatura: json['temperatura'],
    data: json['data']
  );


  Map<String, dynamic> toMap() {
    return {
      'saturacao': saturacao,
      'batimento': batimento,
      'glicose': glicose,
      'temperatura': temperatura,
      'data' : data
    };
  }
  
}
