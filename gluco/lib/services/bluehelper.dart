// ignore_for_file: prefer_const_constructors, avoid_function_literals_in_foreach_calls, avoid_print
import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:gluco/models/device.dart';

class BlueHelper {
  FlutterBlue blue = FlutterBlue.instance;
  final List<BluetoothDevice> _devices = [];
  late Device connectedDevice;

  Future<void> initScan() async {
    blue.scan(
      allowDuplicates: true,
      timeout: Duration(seconds: 60),
    );

    blue.scanResults.listen(
      (value) {
        for (ScanResult e in value) {
          _devices.add(e.device);
        }
      },
    );
  }

  List<BluetoothDevice> get getDevices {
    return _devices;
  }

  Future<void> connectDeviceOrDisconnect(BluetoothDevice device) async {
    await device
        .connect(
          timeout: Duration(
            seconds: 10,
          ),
        )
        .whenComplete(
          () => {
            connectedDevice = Device(connected: true, identifier: device.id, name: device.name),
          },
        );
    String bit = 'nda';
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) async {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        List<int> value = await c.read();
        bit = utf8.decode(value);
        print("string recebida: $bit");
      }
    });
  }
}
