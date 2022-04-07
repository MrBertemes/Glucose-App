// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, use_key_in_widget_constructors, must_be_immutable, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'valuecard.dart';
import '../models/collected.dart';

class ChartBox extends StatelessWidget {
  int valor = 0;
  Collected collectedData;

  ChartBox({
    required this.collectedData,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 4,
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(2),
                height: constraints.maxHeight * 1,
                width: constraints.maxWidth * 0.98,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ValuesCard(
                      label: 'BPM',
                      dados: collectedData.batimento,
                    ),
                    ValuesCard(
                      label: 'SpO2',
                      dados: collectedData.saturacao,
                    ),
                    ValuesCard(
                      label: 'Glicose',
                      dados: collectedData.glicose,
                    ),
                    ValuesCard(
                      label: 'Temperatura',
                      dados: collectedData.temperatura,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(5),
                height: constraints.maxHeight * 0.6,
                width: constraints.maxWidth * 1,
              ),
            ],
            alignment: AlignmentDirectional.topStart,
          ),
        ),
      );
    });
  }
}
