// ignore_for_file: prefer_const_constructors, avoid_function_literals_in_foreach_calls, avoid_print
import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';

class BlueHelper{
  FlutterBlue blue = FlutterBlue.instance;
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = "";


  Future<void> initScan() async {
    blue.startScan(timeout: Duration(seconds: 3));

    blue.scanResults.listen((value) {
      List<BluetoothDevice> valDevice = [];
      for (ScanResult e in value) {
        valDevice.add(e.device);
      }
      _devices = valDevice;

      if (_devicesMsg.isEmpty) {
        _devicesMsg = "Não há dispositivos disponíveis";
      }
    });
  }

  List<BluetoothDevice> getDevices(){
    return _devices;
  }

  Future<void> connectDeviceOrDisconnect(BluetoothDevice device) async {
    await device.connect(
      timeout: Duration(
        seconds: 10,
      ),
    ).whenComplete(() => {
      
    });
    String bit = 'nda';
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        List<int> value = await c.read();
        bit = utf8.decode(value);
        print("string brabissima: $bit");
      }
    });
  }

}