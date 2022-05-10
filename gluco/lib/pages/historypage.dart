// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/collected.dart';

class HistoryPage extends StatelessWidget {
  final AppBar appBar;

  HistoryPage({required this.appBar});

  List<Collected> medidasUltimaSemana = [
    Collected(
      saturacao: 100,
      batimento: 90,
      glicose: 45.00,
      temperatura: 36.6,
      data: DateTime.now(),
    ),
  ];

  List<String> medidasUltimaSemanaTest = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: ListView.builder(
        padding: EdgeInsets.all(4),
        itemCount: medidasUltimaSemana.length,
        itemBuilder: (c, i) {
          return SizedBox(
            height: (MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    appBar.preferredSize.height) *
                0.142857143,
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              leading: Icon(Icons.calendar_today_rounded),
              title: Text(DateFormat.EEEE().format(medidasUltimaSemana[i].data)),
              // title: Text(medidasUltimaSemanaTest[i]),
            ),
          );
        },
      ),
    );
  }
}
