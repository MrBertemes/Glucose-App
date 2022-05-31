// ignore_for_file: use_key_in_widget_constructors, must_be_immutable, prefer_const_constructors, deprecated_member_use, sized_box_for_whitespace, prefer_final_fields, unused_import, unused_local_variable, avoid_print, prefer_typing_uninitialized_variables, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter_blue/gen/flutterblue.pb.dart' as pb;
import 'package:gluco/styles/defaultappbar.dart';
import 'package:http/http.dart';
import '../styles/colors.dart';
import '../view/historicoteste.dart';
import '../widgets/sidebar.dart';
import '../models/collected.dart';
import '../widgets/chartbox.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  final AppBar appBar = defaultAppBar(title: "E-Gluco");
  Collected dataCollected;
  FlutterBlue bluetooth;
  HomePage({required this.dataCollected, required this.bluetooth});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  Random random = Random();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      appBar: widget.appBar,
      drawer: SideBar(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: fundoScaf2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                height: (MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        widget.appBar.preferredSize.height) *
                    0.7,
                child: Card(
                  child: ChartBox(collectedData: widget.dataCollected),
                  elevation: 2,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width * 0.7,
                height: (MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        widget.appBar.preferredSize.height) *
                    0.3,
                child: AsyncButtonBuilder(
                  child: Text(
                    'MEDIR',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () async {
                    setState(
                      () {
                        readData(widget.bluetooth);
                        // readData(widget.bluetooth);
                      },
                    );
                  },
                  builder: (context, child, callback, _) {
                    return ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(azulEsverdeado),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                            side: BorderSide(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                      ),
                      onPressed: callback,
                      child: child,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void readData(FlutterBlue bluetooth) {
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
    HistoricoTeste().saveCollected(widget.dataCollected);
  }
}
