import 'package:flutter_blue/flutter_blue.dart';

class Device {
  String? name;
  int? id;
  bool? connected;
  DeviceIdentifier? identifier;

  Device({this.id, this.name, this.connected, this.identifier});
}
