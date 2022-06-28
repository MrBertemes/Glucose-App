// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, prefer_const_constructors

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:async_button_builder/async_button_builder.dart';
import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/services/authapi.dart';
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
      appBar: defaultAppBar(title: 'E-Gluco', centertitle: true),
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
                                '${HistoryVO.currentMeasurement.sats}%',
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
                                '${HistoryVO.currentMeasurement.bpm} bpm',
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
                // só pra dar tempo de ver a animação de carregando
                await Future.delayed(Duration(seconds: 1));
                setState(() {
                  readData();
                });
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

  void readData() async {
    HistoryVO.currentMeasurement.id++;
    HistoryVO.currentMeasurement.bpm = random.nextInt(110) + 60;
    HistoryVO.currentMeasurement.date = DateTime.now();
    HistoryVO.currentMeasurement.glucose =
        (((random.nextInt(110) + 60) + random.nextDouble()) * 100)
                .truncateToDouble() /
            100;
    HistoryVO.currentMeasurement.sats = random.nextInt(101) + 96;
    HistoryVO.currentMeasurement.temperature =
        (((random.nextInt(38) + 35) + random.nextDouble()) * 100)
                .truncateToDouble() /
            100;

    HistoryVO.updateMeasurementsMap();

    if (await db.insertMeasurement(
        AuthAPI.instance.currentUser!, HistoryVO.currentMeasurement)) {
      print('Success :D');
    } else {
      throw ('Error while adding measurements to database!');
    }
  }
}
