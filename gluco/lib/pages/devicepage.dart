// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_unnecessary_containers, prefer_const_constructors, unused_local_variable, avoid_print, unused_import

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gluco/styles/defaultappbar.dart';
import '../models/device.dart';
import 'package:intl/intl.dart';

import '../styles/colors.dart';

class DevicePage extends StatefulWidget {
  final FlutterBlue blue;

  DevicePage({required this.blue});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = "";
  final f = NumberFormat("\$###,###.00", "en_US");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {initScan()});
  }

  Future<void> initScan() async {
    widget.blue.startScan(timeout: Duration(seconds: 3));

    if (!mounted) return;

    widget.blue.scanResults.listen((value) {
      if (!mounted) return;

      List<BluetoothDevice> valDevice = [];
      for (ScanResult e in value) {
        valDevice.add(e.device);
      }
      setState(() {
        _devices = valDevice;
      });

      if (_devicesMsg.isEmpty) {
        setState(() {
          _devicesMsg = "Não há dispositivos disponíveis";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(
        title: "Conexão com Relógio",
        trailing: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Icon(Icons.bluetooth),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: fundoScaf2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: _devices.isEmpty
            ? Center(
                child: Text(
                  _devicesMsg,
                  style: Theme.of(context).textTheme.headline6,
                ),
              )
            : ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (c, i) {
                  return ListTile(
                    leading: Icon(Icons.bluetooth),
                    title: Text(_devices[i].name),
                    subtitle: Text(_devices[i].id.toString()),
                    onTap: () {
                      connectDevice(_devices[i]);
                    },
                  );
                },
              ),
      ),
    );
  }

  Future<void> connectDevice(BluetoothDevice device) async {
    await device.connect(
      autoConnect: true,
      timeout: Duration(
        seconds: 3,
      ),
    );
  }

}
