// ignore_for_file: invalid_null_aware_operator, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_unnecessary_containers, prefer_const_constructors, unused_local_variable, avoid_print, unused_import

import 'dart:convert';
import 'package:flutter_blue/gen/flutterblue.pbenum.dart';
import 'package:flutter_blue/gen/flutterblue.pbjson.dart';

import '../services/bluehelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gluco/styles/defaultappbar.dart';
import '../models/device.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/customcolors.dart';

class DevicePage extends StatefulWidget {
  DevicePage();

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  final BlueHelper blueHelp = BlueHelper();
  List<BluetoothDevice> _dvc = [];
  final String _devicesMsg = "Não há dispositivos por perto";
  final f = NumberFormat("\$###,###.00", "en_US");

  void scan() async {
    await blueHelp.initScan();
    _dvc = blueHelp.getDevices;
  }

  void toggleButton(dynamic dvc) {
    blueHelp.connectDeviceOrDisconnect(dvc);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => {scan()});
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Visibility(
            visible: _dvc.isNotEmpty,
            child: Padding(
              padding: EdgeInsets.only(left: 20.0, top: 5.0, bottom: 10.0),
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
              child: _dvc.isEmpty
                  ? Center(
                      child: Text(
                        _devicesMsg,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    )
                  // esse eu fiz na louca não tinha como testar
                  : ListView.separated(
                      itemCount: _dvc.length,
                      itemBuilder: (context, i) {
                        return ListTile(
                          trailing: IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () => {},
                          ),
                          title: Text(_dvc[i].name),
                          subtitle: Text(_dvc[i].id.toString()),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(_dvc[i].name),
                                actions: [
                                  Center(
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 500),
                                      height: 20,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: CustomColors.lightGreen,
                                      ),
                                      child: Stack(
                                        // ignore: prefer_const_literals_to_create_immutables
                                        children: [
                                          AnimatedPositioned(
                                            duration:
                                                Duration(milliseconds: 1000),
                                            curve: Curves.easeIn,
                                            top: 1.5,
                                            left: _dvc[i].id ==
                                                    blueHelp.connectedDevice
                                                        .identifier
                                                ? 60.0
                                                : 0.0,
                                            right: _dvc[i].id ==
                                                    blueHelp.connectedDevice
                                                        .identifier
                                                ? 60.0
                                                : 0.0,
                                            child: InkWell(
                                              onTap: () {
                                                toggleButton(_dvc[i]);
                                              },
                                              child: AnimatedSwitcher(
                                                  duration: Duration(
                                                      milliseconds: 1000),
                                                  transitionBuilder:
                                                      (Widget child,
                                                          Animation<double>
                                                              animation) {
                                                    return RotationTransition(
                                                      child: child,
                                                      turns: animation,
                                                    );
                                                  },
                                                  child: _dvc[i].id ==
                                                          blueHelp
                                                              .connectedDevice
                                                              .identifier
                                                      ? Icon(
                                                          Icons.check_circle,
                                                          color: CustomColors
                                                              .lightGreen,
                                                          size: 15.0,
                                                          key: UniqueKey(),
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .remove_circle_outline,
                                                          color: CustomColors
                                                              .scaffWhite,
                                                          size: 15.0,
                                                          key: UniqueKey(),
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
      ),
    );
  }
}
