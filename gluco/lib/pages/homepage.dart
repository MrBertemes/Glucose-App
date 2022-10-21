// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:async_button_builder/async_button_builder.dart';
// import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/models/measurement.dart';
import 'package:gluco/services/api.dart';
import 'package:gluco/services/bluetoothhelper.dart';
import 'package:gluco/styles/defaultappbar.dart';
import 'package:gluco/styles/mainbottomappbar.dart';
import 'package:gluco/styles/customcolors.dart';
import 'package:gluco/views/historyvo.dart';
import 'package:gluco/widgets/iconcard.dart';
import 'package:gluco/widgets/sidebar.dart';
import 'package:intl/intl.dart';
import 'package:gluco/app_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<bool> btConn;

  @override
  void initState() {
    btConn = BluetoothHelper.instance.connected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.scaffLightBlue,
      appBar: imageAppBar(
        imagename: 'assets/images/logoblue.png',
        width: MediaQuery.of(context).size.width * 0.25,
      ),
      bottomNavigationBar: mainBottomAppBar(context, MainBottomAppBar.home),
      drawer: SideBar(),
      body: Container(
        margin: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment:
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? MainAxisAlignment.spaceEvenly
                  : MainAxisAlignment.spaceBetween,
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text:
                          'Última medição: ${MediaQuery.of(context).orientation == Orientation.portrait ? '\n' : ' '}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16.0,
                      ),
                      children: [
                        TextSpan(
                          text: HistoryVO.currentMeasurement.id != -1
                              ? DateFormat('d MMM, E. H:mm', 'pt_BR')
                                  .format(HistoryVO.currentMeasurement.date)
                                  .toUpperCase()
                              : 'Sem dados',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconCard(
                  icon: Icon(AppIcons.molecula, color: Colors.white, size: 32),
                  label: Text(
                    'Glicose',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  data: HistoryVO.currentMeasurement.id != -1
                      ? Text(
                          '${HistoryVO.currentMeasurement.glucose} mg/dL',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text('Sem dados'),
                  color: CustomColors.lightBlue.withOpacity(1.0),
                  size:
                      Size.fromHeight(MediaQuery.of(context).size.height * 0.2),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                Row(
                  children: [
                    Expanded(
                      child: IconCard(
                        icon: Icon(Icons.air, color: Colors.white),
                        label: Text(
                          'Saturação de Oxigênio',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        data: HistoryVO.currentMeasurement.id != -1
                            ? Text(
                                '${HistoryVO.currentMeasurement.spo2}%',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text('Sem dados'),
                        color: CustomColors.lightGreen.withOpacity(1.0),
                        size: Size.fromHeight(
                            MediaQuery.of(context).size.height * 0.2),
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                    Expanded(
                      child: IconCard(
                        icon: Icon(Icons.favorite, color: Colors.white),
                        label: Text(
                          'Frequência Cardíaca',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        data: HistoryVO.currentMeasurement.id != -1
                            ? Text(
                                '${HistoryVO.currentMeasurement.pr_rpm} bpm',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text('Sem dados'),
                        color: CustomColors.greenBlue.withOpacity(1.0),
                        size: Size.fromHeight(
                            MediaQuery.of(context).size.height * 0.2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StreamBuilder<bool>(
              stream: btConn,
              initialData: false,
              builder: (context, snapshot) {
                return AsyncButtonBuilder(
                  child: Text(
                    'Medir',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loadingWidget: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.0,
                  ),
                  successWidget: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    // mapa com o que é lido do stm
                    late Map measurement;
                    // late MeasurementCollected measurement;
                    try {
                      measurement = await BluetoothHelper.instance.collect();
                    } catch (e) {
                      showDialog(
                          useRootNavigator: false,
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: Text(
                                    'Ocorreu um erro na coleta dos dados do dispositivo Bluetooth...'),
                                actions: [
                                  TextButton(
                                    child: Text('Retornar'),
                                    onPressed: (() {
                                      Navigator.pop(context);
                                    }),
                                  )
                                ]);
                          });
                      throw 'Erro na coleta da medição';
                    }
                    try {
                      // if (await API.instance.postMeasurements(measurement)) {
                      // ignore: dead_code
                      if (false) {
                        //não é pra enviar nada por enquanto
                        showDialog(
                            useRootNavigator: false,
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                  title: Text('Medição enviada com sucesso'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                            Text(
                                              'Dados enviados:\n',
                                            ),
                                          ] +
                                          measurement
                                              // .toMap()
                                              .entries
                                              .map((e) =>
                                                  Text('${e.key}: ${e.value}'))
                                              .toList(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('Ok!'),
                                      onPressed: (() {
                                        Navigator.pop(context);
                                      }),
                                    )
                                  ]);
                            });
                      } else {
                        throw 'Erro no envio da medição';
                      }
                    } catch (e) {
                      showDialog(
                          useRootNavigator: false,
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                title: Text(
                                    'Ocorreu um erro no envio dos dados coletados...'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                          Text(
                                            'Dados coletados:\n',
                                          ),
                                        ] +
                                        measurement
                                            // .toMap()
                                            .entries
                                            .map((e) =>
                                                Text('${e.key}: ${e.value}'))
                                            .toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Retornar'),
                                    onPressed: (() {
                                      Navigator.pop(context);
                                    }),
                                  )
                                ]);
                          });
                      throw 'Erro ao realizar medição';
                    }
                    /////////////////// futuro
                    // MeasurementCompleted measurement = await API.instance.getMeasurement();
                    // DatabaseHelper.instance
                    //     .insertMeasurement(API.instance.currentUser!, measurement);
                    ///////////////////
                  },
                  builder: (context, child, callback, _) {
                    Color color = CustomColors.greenBlue.withOpacity(1.0);
                    if (!snapshot.data!) {
                      color = Colors.grey;
                      callback = () async {
                        showDialog(
                          useRootNavigator: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Dispositivo não conectado'),
                              content: Text(
                                  'Escolha um dispositivo para conectar na página de dispositivos...'),
                              actions: [
                                TextButton(
                                  child: Text('Ir à página de dispositivos'),
                                  onPressed: () async {
                                    await Navigator.popAndPushNamed(
                                      context,
                                      '/devices',
                                    );
                                  },
                                )
                              ],
                            );
                          },
                        );
                      };
                    }
                    return TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: color,
                        minimumSize: Size.fromHeight(
                            MediaQuery.of(context).size.height * 0.09),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: callback,
                      child: child,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
