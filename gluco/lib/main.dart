// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, deprecated_member_use, unused_import, avoid_print, sized_box_for_whitespace, non_constant_identifier_names, unused_local_variable, unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gluco/widgets/chartbox.dart';
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
  final Collected _dataCollected = Collected(
    batimento: 78,
    data: DateTime.now(),
    saturacao: 98,
    glicose: 98.2,
    temperatura: 36.8,
  );

  List<int> valor = [70, 67, 60, 66, 93, 72, 90, 96, 91, 87];
  var i = 0;
  FlutterBlue bluetooth = FlutterBlue.instance;

  void ScanBluetooth(FlutterBlue bluetooth) async {
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

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      leading: IconButton(
        color: Colors.black,
        alignment: Alignment.center,
        onPressed: () {},
        icon: Icon(
          Icons.view_list_rounded,
        ),
      ),
      elevation: 4,
      centerTitle: true,
      title: Text(
        "E-Glico",
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
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            button: TextStyle(color: Colors.black)),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
      home: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                height: (MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        appBar.preferredSize.height) *
                    0.7,
                child: Card(
                  child: ChartBox(collectedData: _dataCollected),
                  elevation: 2,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.7,
                height: (MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        appBar.preferredSize.height) *
                    0.3,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      if (i >= 9) {
                        i = 0;
                      } else {
                        i = i + 1;
                        ScanBluetooth(bluetooth);
                      }
                    });
                  },
                  child: Text('SCAN',
                      style: Theme.of(context).textTheme.headline6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
