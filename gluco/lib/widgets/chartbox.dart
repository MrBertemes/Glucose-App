// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, use_key_in_widget_constructors, must_be_immutable, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, deprecated_member_use

import 'package:flutter/material.dart';
import 'valuecard.dart';
import '../models/measurement.dart';

class ChartBox extends StatelessWidget {
  int valor = 0;
  MeasurementCompleted collectedData;

  ChartBox({
    required this.collectedData,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).accentColor,
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
                      dados: collectedData.pr_rpm,
                    ),
                    ValuesCard(
                      label: 'SpO2',
                      dados: collectedData.spo2,
                    ),
                    ValuesCard(
                      label: 'Glicose',
                      dados: collectedData.glucose,
                    ),
                    // ValuesCard(
                    //   label: 'Temperatura',
                    //   dados: collectedData.temperature,
                    // ),
                  ],
                ),
              ),
              // Container( //
              //   padding: EdgeInsets.all(5),
              //   height: constraints.maxHeight * 0.6,
              //   width: constraints.maxWidth * 1,
              // ),
            ],
            alignment: AlignmentDirectional.topStart,
          ),
        ),
      );
    });
  }
}
