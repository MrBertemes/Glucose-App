// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, deprecated_member_use, unused_import, avoid_print, sized_box_for_whitespace, non_constant_identifier_names, unused_local_variable, unused_field, prefer_final_fields, deprecated_member_use_from_same_package

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gluco/pages/devicepage.dart';
import 'package:gluco/pages/profilepage.dart';
import 'package:gluco/pages/signuppage.dart';
import 'package:gluco/styles/colors.dart';
import 'package:gluco/widgets/chartbox.dart';
import 'package:gluco/pages/homepage.dart';
import 'package:gluco/view/historicoteste.dart';
import 'package:gluco/widgets/sidebar.dart';
import 'package:gluco/widgets/valuecard.dart';
import 'package:flutter_blue/flutter_blue.dart';
import './models/collected.dart';
import 'db/authdb.dart';
import 'pages/historypage.dart';
import 'pages/loginpage.dart';
import 'pages/initscreen.dart';

String _defaultHome = '/login';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);

  bool _auth = await AuthDB.isLoggedIn();
  if (_auth) {
    _defaultHome = '/home';
  }

  runApp(
    MaterialApp(
      home: Main(),
    ),
  );
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  // Só pra popular as medições (nem serve pra nada essa bool init mas tive que botar pq o vscode brigou cmg)
  Future<bool> init = HistoricoTeste().initHistoricoTeste();
  // Coleta a ultima medição realizada
  Collected _dataCollected = HistoricoTeste.getLastCollected();

  FlutterBlue bluetooth = FlutterBlue.instance;

  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: fundoScaf,
        backgroundColor: Colors.white,
        primarySwatch: Colors.green,
        accentColor: Colors.grey[600],
        errorColor: Colors.red[900],
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline6: TextStyle(
                color: Colors.black,
                fontFamily: 'OpenSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              button: TextStyle(color: Colors.white),
            ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                  color: Colors.white,
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
      routes: {
        '/': (context) => InitScreen(route: _defaultHome),
        '/home': (context) =>
            HomePage(dataCollected: _dataCollected, bluetooth: bluetooth),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/devices': (context) => DevicePage(blue: bluetooth),
        '/history': (context) => HistoryPage(),
        '/profile': (context) => ProfilePage(),
      },
    );
  }
}
