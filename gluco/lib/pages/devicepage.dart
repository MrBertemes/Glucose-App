// ignore_for_file: invalid_null_aware_operator, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, avoid_unnecessary_containers, prefer_const_constructors, unused_local_variable, avoid_print, unused_import

import 'dart:convert';
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
  final BlueHelper blue = BlueHelper();
  List<BluetoothDevice> _devices = [];
  String _devicesMsg = "";
  final f = NumberFormat("\$###,###.00", "en_US");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => {blue.initScan()});
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
            visible: _devices.isNotEmpty,
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
              child: _devices.isEmpty
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
                            blue.connectDeviceOrDisconnect(_devices[i]);
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
