// ignore_for_file: unused_import, unnecessary_new

import 'package:flutter/foundation.dart';

// papo que measurements não ficava melhor? casar com o nome da tabela no banco
class Collected {
  int id;
  int saturacao;
  int batimento;
  double glicose;
  double temperatura;
  DateTime data;

  Collected({
    required this.id,
    required this.saturacao,
    required this.batimento,
    required this.glicose,
    required this.temperatura,
    required this.data,
  });

  factory Collected.fromMap(Map<String, dynamic> json) => new Collected(
      id: json['id'],
      saturacao: json['spo'],
      batimento: json['bpm'],
      glicose: json['glucose'],
      temperatura: json['temperature'],
      data: json['data']);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'spo': saturacao,
      'bpm': batimento,
      'glucose': glicose,
      'temperature': temperatura,
      'data': data
    };
  }
}
