// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, prefer_const_constructors, deprecated_member_use, sized_box_for_whitespace, prefer_final_fields, unused_import, unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter_blue/gen/flutterblue.pb.dart' as pb;
import '../widgets/sidebar.dart';
import '../models/collected.dart';
import '../widgets/chartbox.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  AppBar appBar;
  Collected dataCollected;
  FlutterBlue bluetooth;
  HomePage(
      {required this.appBar,
      required this.dataCollected,
      required this.bluetooth});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  Random random = Random();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: widget.appBar,
      drawer: SideBar(
        appBar: widget.appBar,
      ),
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
              child: AsyncButtonBuilder(
                child: Text('MEDIR'),
                onPressed: () async {
                  setState(() {
                    scanBluetooth(widget.bluetooth);
                    // readData(widget.bluetooth);
                  });
                },
                builder: (context, child, callback, _) {
                  return ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: Theme.of(context).accentColor,
                          ),
                        )
                      ),
                    ),
                    onPressed: callback,
                    child: child,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scanBluetooth(FlutterBlue bluetooth) async {
    if (await bluetooth.isOn) {
      bluetooth.startScan(timeout: Duration(seconds: 10));

      var subscriptions = bluetooth.scanResults.listen((results) {
        for (ScanResult r in results) {
          print('${r.device.name} found! rssi: ${r.rssi}');
        }
      });
      bluetooth.stopScan();
    } else {
      print('Bluetooth está desligado');
    }
  }

  void readData(FlutterBlue bluetooth){
    
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
