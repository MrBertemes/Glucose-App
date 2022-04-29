// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_unnecessary_containers, prefer_const_constructors, unused_local_variable, avoid_print, unused_import

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DevicePage extends StatelessWidget {
  final AppBar appBar;
  final FlutterBlue blue;

  DevicePage({required this.blue, required this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: FutureBuilder(
          future: blueIsOn(blue),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.toString() == 'true') {
                scanDevices(blue);
                return Center(
                  child: Text(
                    "Bluetooth está ligado",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    "Bluetooth está desligado",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                );
              }
            } else {
              return Center(
                child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor),
              );
            }
          }),
    );
  }

  Future<bool> blueIsOn(FlutterBlue blue) async {
    if (await blue.isOn) {
      return true;
    }
    return false;
  }

  void scanDevices(FlutterBlue bluetooth) async {
    bluetooth.startScan(timeout: Duration(seconds: 4));
    var subscription = bluetooth.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });

    // Stop scanning
    bluetooth.stopScan();
  }
}
