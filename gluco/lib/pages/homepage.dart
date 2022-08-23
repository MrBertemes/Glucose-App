// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, prefer_const_constructors

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:async_button_builder/async_button_builder.dart';
import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/models/measurement.dart';
import 'package:gluco/services/api.dart';
import 'package:gluco/styles/defaultappbar.dart';
import 'package:gluco/styles/mainbottomappbar.dart';
import 'package:gluco/styles/customcolors.dart';
import 'package:gluco/views/historyvo.dart';
import 'package:gluco/widgets/iconcard.dart';
import 'package:gluco/widgets/sidebar.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Random random = Random();
  DatabaseHelper db = DatabaseHelper.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  icon: Icon(Icons.hub_outlined, color: Colors.white),
                  label: Text(
                    'Glicose',
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
                          style: TextStyle(
                            fontSize: 18.0,
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
                          style: TextStyle(
                            fontSize: 18.0,
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
            AsyncButtonBuilder(
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
                // setState(() { // setstate não pode ser async
                MeasurementCollected measurement = await readData();
                print('---readdata---\n' +
                    measurement.toMap().toString() +
                    '\n---readdata---\n');
                print(
                    'Status do envio da medição: ${await API.instance.postMeasurements(measurement)}');
                // });
              },
              builder: (context, child, callback, _) {
                return TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: CustomColors.greenBlue.withOpacity(1.0),
                    minimumSize: Size.fromHeight(
                        MediaQuery.of(context).size.height * 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: callback,
                  child: child,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<MeasurementCollected> readData() async {
    List<double> m_4p = <double>[];
    List<double> f_4p = <double>[];
    for (int i = 1; i <= 24; i++) {
      m_4p.add((random.nextDouble() * 10000).truncateToDouble() / 1000 + 5);
      f_4p.add((random.nextDouble() * 10000).truncateToDouble() / 1000 + 5);
    }
    return MeasurementCollected(
      id: -1,
      apparent_glucose:
          (((random.nextInt(110) + 60) + random.nextDouble()) * 100)
                  .truncateToDouble() /
              100,
      spo2: random.nextInt(101) + 96,
      pr_rpm: random.nextInt(110) + 60,
      temperature: (((random.nextInt(38) + 35) + random.nextDouble()) * 100)
              .truncateToDouble() /
          100,
      m_4p: m_4p,
      f_4p: f_4p,
      date: DateTime.now(),
    );
  }
}
