// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'sidebar.dart';
import '../models/collected.dart';
import 'chartbox.dart';
import 'dart:math';

class FirstPage extends StatefulWidget {
  final AppBar appBar;
  Collected dataCollected;
  FlutterBlue bluetooth;
  FirstPage({required this.appBar, required this.dataCollected, required this.bluetooth});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  Random random = Random();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.appBar,
        drawer: SideBar(),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: (MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        widget.appBar.preferredSize.height) *
                    0.7,
                child: Card(
                  child: ChartBox(collectedData: widget.dataCollected),
                  elevation: 2,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.7,
                height: (MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        widget.appBar.preferredSize.height) *
                    0.3,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      readData(widget.bluetooth);
                    });
                  },
                  child: Text(
                    'SCAN',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
  void readData(FlutterBlue bluetooth) {
    // Temporario somente - Depois será a chamada de funcao
    // que mantem contato e recebe os dados.
    widget.dataCollected.batimento = random.nextInt(110) + 60;
    widget.dataCollected.data = DateTime.now();
    widget.dataCollected.glicose =
        (((random.nextInt(110) + 60) + random.nextDouble()) * 100)
                .truncateToDouble() /
            100;
    widget.dataCollected.saturacao = random.nextInt(101) + 96;
    widget.dataCollected.temperatura =
        (((random.nextInt(38) + 35) + random.nextDouble()) * 100)
                .truncateToDouble() /
            100;
  }
}