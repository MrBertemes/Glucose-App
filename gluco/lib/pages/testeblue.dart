// ignore_for_file: invalid_null_aware_operator, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_unnecessary_containers, prefer_const_constructors, unused_local_variable, avoid_print, unused_import, avoid_function_literals_in_foreach_calls, void_checks

import 'dart:convert';
import 'package:flutter_blue/gen/flutterblue.pbenum.dart';
import 'package:flutter_blue/gen/flutterblue.pbjson.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gluco/styles/defaultappbar.dart';
import '../models/device.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/customcolors.dart';

class TesteBlue extends StatefulWidget {
  const TesteBlue({Key? key}) : super(key: key);

  @override
  State<TesteBlue> createState() => _TesteBlueState();
}

class _TesteBlueState extends State<TesteBlue> {
  FlutterBlue blue = FlutterBlue.instance;
  late Future<List<BluetoothDevice>> _devices;
  late Device connectedDevice;
  final String _devicesMsg = "Não há dispositivos por perto";
  final f = NumberFormat("\$###,###.00", "en_US");

  @override
  void initState() {
    super.initState();
    _devices = initScan();
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
            connectedDevice = Device(
                connected: true, identifier: device.id, name: device.name),
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

  void toggleButton(dynamic dvc) {
    connectDeviceOrDisconnect(dvc);
  }

  Future<List<BluetoothDevice>> initScan() async {
    List<BluetoothDevice> devices = [];
    // Start scanning
    blue.startScan(timeout: Duration(seconds: 4));

    // Listen to scan results
    var subscription = blue.scanResults.listen(
      (results) {
        // do something with scan results
        for (ScanResult r in results) {
          print("${r.device.name} found: ${r.hashCode}");
          devices.add(r.device);
        }
      },
    );
    // Stop scanning
    blue.stopScan();
    return devices;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(
        title: 'Conexão com Relógio',
        trailing: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Icon(Icons.bluetooth),
          ),
        ],
      ),
      body: FutureBuilder(
          future: initScan(),
          initialData: "Procurando dispositivos...",
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("Falha ao escanear!"),
              );
            } else if (snapshot.hasData) {
              List<BluetoothDevice> _devices = [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Visibility(
                    visible: snapshot.hasData,
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 5.0, bottom: 10.0),
                      child: Text(
                        'Dispositivos Disponíveis',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 10.0),
                      decoration: BoxDecoration(
                        color: CustomColors.scaffWhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: !snapshot.hasData
                          ? Center(
                              child: Text(
                                _devicesMsg,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            )
                          // esse eu fiz na louca não tinha como testar
                          : ListView.separated(
                              itemCount: _devices.length,
                              itemBuilder: (context, i) {
                                return ListTile(
                                  trailing: IconButton(
                                    icon: Icon(Icons.settings),
                                    onPressed: () => {},
                                  ),
                                  title: Text(_devices[i].name),
                                  subtitle: Text(_devices[i].id.toString()),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(_devices[i].name),
                                        actions: [
                                          Center(
                                            child: AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 500),
                                              height: 20,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: CustomColors.lightGreen,
                                              ),
                                              child: Stack(
                                                // ignore: prefer_const_literals_to_create_immutables
                                                children: [
                                                  AnimatedPositioned(
                                                    duration: Duration(
                                                        milliseconds: 1000),
                                                    curve: Curves.easeIn,
                                                    top: 1.5,
                                                    left: _devices[i].id ==
                                                            connectedDevice
                                                                .identifier
                                                        ? 60.0
                                                        : 0.0,
                                                    right: _devices[i].id ==
                                                            connectedDevice
                                                                .identifier
                                                        ? 60.0
                                                        : 0.0,
                                                    child: InkWell(
                                                      onTap: () {
                                                        toggleButton(
                                                            _devices[i]);
                                                      },
                                                      child: AnimatedSwitcher(
                                                          duration: Duration(
                                                              milliseconds:
                                                                  1000),
                                                          transitionBuilder:
                                                              (Widget child,
                                                                  Animation<
                                                                          double>
                                                                      animation) {
                                                            return RotationTransition(
                                                              child: child,
                                                              turns: animation,
                                                            );
                                                          },
                                                          child: _devices[i]
                                                                      .id ==
                                                                  connectedDevice
                                                                      .identifier
                                                              ? Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: CustomColors
                                                                      .lightGreen,
                                                                  size: 15.0,
                                                                  key:
                                                                      UniqueKey(),
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .remove_circle_outline,
                                                                  color: CustomColors
                                                                      .scaffWhite,
                                                                  size: 15.0,
                                                                  key:
                                                                      UniqueKey(),
                                                                )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              separatorBuilder: (context, i) {
                                return Divider(
                                  color: Colors.grey,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
