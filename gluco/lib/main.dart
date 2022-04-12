// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, deprecated_member_use, unused_import, avoid_print, sized_box_for_whitespace, non_constant_identifier_names, unused_local_variable, unused_field, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluco/widgets/chartbox.dart';
import 'package:gluco/pages/homepage.dart';
import 'package:gluco/widgets/sidebar.dart';
import 'package:gluco/widgets/valuecard.dart';
import 'package:flutter_blue/flutter_blue.dart';
import './models/collected.dart';

void main() => runApp(MaterialApp(
      home: Main(),
    ));

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  Collected _dataCollected = Collected(
    batimento: 78,
    data: DateTime.now(),
    saturacao: 98,
    glicose: 98.2,
    temperatura: 36.8,
  );

  // List<int> valor = [70, 67, 60, 66, 93, 72, 90, 96, 91, 87];
  // var i = 0;
  FlutterBlue bluetooth = FlutterBlue.instance;
 // from 0 upto 99 included

  

  void scanBluetooth(FlutterBlue bluetooth) async {
    if (await bluetooth.isAvailable) {
      bluetooth.startScan(timeout: Duration(seconds: 10));

      var subscriptions = bluetooth.scanResults.listen((results) {
        for (ScanResult r in results) {
          print('${r.device.name} found! rssi: ${r.rssi}');
        }
      });

      bluetooth.stopScan();
    } else {
      print('Device doesn\'t have bluetooth');
    }
  }
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final AppBar appBar = AppBar(
      elevation: 4,
      centerTitle: true,
      title: Text(
        "E-Gluco",
        textAlign: TextAlign.center,
        style: TextStyle(
            // fontSize: Theme.of(context).appBarTheme.textTheme.headline6.fontSize
            ),
      ),
    );

    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.green,
          accentColor: Colors.red,
          errorColor: Colors.purple[900],
          fontFamily: 'Quicksand',
          textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              button: TextStyle(color: Colors.white)),
          appBarTheme: AppBarTheme(
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: TextStyle(
                    color: Colors.white,
                    fontFamily: 'OpenSans',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        home: HomePage(
          appBar: appBar,
          dataCollected: _dataCollected,
          bluetooth: bluetooth,
        ));
  }
}
