// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, prefer_const_constructors

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:async_button_builder/async_button_builder.dart';
import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/models/collected.dart';
import 'package:gluco/styles/defaultappbar.dart';
import 'package:gluco/styles/mainbottomappbar.dart';
import 'package:gluco/styles/colors.dart';
import 'package:gluco/widgets/iconcard.dart';
import 'package:gluco/widgets/sidebar.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final AppBar appBar = defaultAppBar(title: 'E-Gluco', centertitle: true);
  Collected dataCollected;
  HomePage({required this.dataCollected});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Random random = Random();
  DatabaseHelper db = DatabaseHelper.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      bottomNavigationBar: mainBottomAppBar(context, 'home'),
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
                          text: widget.dataCollected.glicose == 0
                              ? 'Sem dados'
                              : DateFormat('d MMM, E. H:mm', 'pt_BR')
                                  .format(widget.dataCollected.data)
                                  .toUpperCase(),
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
                  data: widget.dataCollected.glicose != 0
                      ? Text(
                          '${widget.dataCollected.glicose} mg/dL',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text('Sem dados'),
                  color: azulClaro.withOpacity(1.0),
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
                        data: widget.dataCollected.saturacao != 0
                            ? Text(
                                '${widget.dataCollected.saturacao}%',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text('Sem dados'),
                        color: verdeClaro.withOpacity(1.0),
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
                        data: widget.dataCollected.batimento != 0
                            ? Text(
                                '${widget.dataCollected.batimento} bpm',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text('Sem dados'),
                        color: verdeAzulado.withOpacity(1.0),
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
                    backgroundColor: verdeAzulado.withOpacity(1.0),
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
    widget.dataCollected.id++;
    widget.dataCollected.batimento = random.nextInt(110) + 60;
    widget.dataCollected.data = DateTime.now();
    widget.dataCollected.glicose =
        (((random.nextInt(110) + 60) + random.nextDouble()) * 100)
                .truncateToDouble() /
            100;
    widget.dataCollected.saturacao = random.nextInt(101) + 96;
    widget.dataCollected.temperatura =
        (((random.nextInt(38) + 35) + random.nextDouble()) * 100)
                .truncateToDouble() /
            100;
    // HistoricoTeste().saveCollected(widget.dataCollected);

    var res = await db.addMeasurement(widget.dataCollected);
    if (res == 0) {
      throw ('Error while adding measurements to database!');
    } else {
      print('Success :D');
    }
  }
}
