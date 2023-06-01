// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_const_constructors
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gluco/models/device.dart';
import 'package:gluco/services/bluetoothhelper.dart';
import 'package:gluco/styles/customcolors.dart';
import 'package:gluco/styles/defaultappbar.dart';

class DevicePage extends StatefulWidget {
  DevicePage();

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  void initScan() async {
    await BluetoothHelper.instance.scan();
    devices.clear();
    devices.addAll(BluetoothHelper.instance.devices);
  }

  final List<Device> devices = [];

  late Stream<bool> btState;
  late Stream<bool> btScan;
  late Stream<bool> btConn;

  late ValueNotifier<bool> _source;

  StreamController<bool> connecting = StreamController<bool>.broadcast();
  void connectDevice(bool cnt, int i) async {
    connecting.add(true);
    for (final dvc in devices) {
      dvc.connected = false;
    }
    await BluetoothHelper.instance.disconnect();
    if (cnt) {
      devices[i].connected = await BluetoothHelper.instance.connect(devices[i]);
    }
    connecting.add(false);
  }

  @override
  void initState() {
    btState = BluetoothHelper.instance.state;
    btScan = BluetoothHelper.instance.scanning;
    btConn = BluetoothHelper.instance.connected;
    _source = ValueNotifier<bool>(BluetoothHelper.instance.source);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            CustomColors.bluelight,
            CustomColors.blueGreenlight,
            CustomColors.greenlight,
          ],
        ),
      ),
      child: Scaffold(
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
            StreamBuilder<bool>(
                stream: btScan,
                initialData: false,
                builder: (context, snapshot) {
                  return Visibility(
                    // se desligar o bluetooth, a mensagem continua aparecendo
                    visible: !snapshot.data! && devices.isNotEmpty,
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 5.0, bottom: 10.0),
                      child: Text(
                        'Dispositivos Disponíveis',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 10.0),
                decoration: BoxDecoration(
                  color: CustomColors.scaffWhite.withOpacity(0.50),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: StreamBuilder<bool>(
                  stream: btState,
                  initialData: false,
                  builder: (context, snapshot) {
                    if (!snapshot.data!) {
                      return Center(
                        // se ligar e desligar o bluetooth pode ocorrer DeadObjectException
                        child: Text(
                          'O Bluetooth está desabilitado...',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      );
                    } else {
                      initScan();
                      return StreamBuilder<bool>(
                        stream: btScan,
                        initialData: true,
                        builder: (context, snapshot) {
                          if (snapshot.data!) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: CustomColors.lightBlue,
                              ),
                            );
                          } else {
                            return devices.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        'Nenhum dispositivo Bluetooth encontrado...',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                    ),
                                  )
                                : StreamBuilder<bool>(
                                    stream: btConn,
                                    initialData: true,
                                    builder: (context, snapshot) {
                                      return ListView.separated(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20),
                                        itemCount: devices.length,
                                        itemBuilder: (context, i) {
                                          return ListTile(
                                            title: Text(devices[i].name,
                                                style: TextStyle(
                                                    color:
                                                        devices[i].connected &&
                                                                snapshot.data!
                                                            ? CustomColors
                                                                .lightGreen
                                                            : Colors.black)),
                                            subtitle: Text(
                                                devices[i].connected &&
                                                        snapshot.data!
                                                    ? 'Conectado'
                                                    : 'Não conectado',
                                                style: TextStyle(
                                                    color:
                                                        devices[i].connected &&
                                                                snapshot.data!
                                                            ? CustomColors
                                                                .lightGreen
                                                            : Colors.black)),
                                            trailing: IconButton(
                                              icon: Icon(Icons.settings,
                                                  color: devices[i].connected &&
                                                          snapshot.data!
                                                      ? CustomColors.lightGreen
                                                      : Colors.black),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          StreamBuilder<bool>(
                                                            stream: btConn,
                                                            initialData: true,
                                                            builder: (context,
                                                                snapshot) {
                                                              return RichText(
                                                                text: TextSpan(
                                                                  text:
                                                                      devices[i]
                                                                          .name,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      color: devices[i].connected &&
                                                                              snapshot
                                                                                  .data!
                                                                          ? CustomColors
                                                                              .lightGreen
                                                                          : Colors
                                                                              .black),
                                                                  children: [
                                                                    TextSpan(
                                                                      text: devices[i].connected &&
                                                                              snapshot.data!
                                                                          ? '\nConectado'
                                                                          : '\nNão conectado',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontStyle:
                                                                            FontStyle.italic,
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          StreamBuilder<bool>(
                                                            stream: connecting
                                                                .stream,
                                                            initialData: false,
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .data!) {
                                                                return CircularProgressIndicator(
                                                                  color: CustomColors
                                                                      .lightBlue,
                                                                );
                                                              } else {
                                                                return Switch(
                                                                  activeColor:
                                                                      CustomColors
                                                                          .lightGreen,
                                                                  value: devices[
                                                                          i]
                                                                      .connected,
                                                                  onChanged:
                                                                      (value) {
                                                                    connectDevice(
                                                                        value,
                                                                        i);
                                                                  },
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      ///// TEMPORARIO
                                                      content:
                                                          ValueListenableBuilder(
                                                        valueListenable:
                                                            _source,
                                                        builder: (context,
                                                                bool value,
                                                                child) =>
                                                            Row(
                                                          children: [
                                                            Text(value
                                                                ? 'Leonardo'
                                                                : 'Patrick'),
                                                            Switch(
                                                              value: value,
                                                              onChanged: (v) {
                                                                BluetoothHelper
                                                                    .instance
                                                                    .source = v;
                                                                _source.value =
                                                                    v;
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      /////
                                                      actionsAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      actions: [
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.arrow_back),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, i) {
                                          return Divider(
                                            color: Colors.grey,
                                          );
                                        },
                                      );
                                    },
                                  );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: btState,
          initialData: false,
          builder: (context, snapshot) {
            return Visibility(
              visible: snapshot.data!,
              child: StreamBuilder<bool>(
                stream: btScan,
                initialData: false,
                builder: (context, snapshot) {
                  VoidCallback? onPressed;
                  Color color = Colors.grey;
                  if (!snapshot.data!) {
                    color = CustomColors.lightBlue;
                    onPressed = initScan;
                  }
                  return FloatingActionButton(
                    backgroundColor: color,
                    child: Icon(Icons.refresh),
                    onPressed: onPressed,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
