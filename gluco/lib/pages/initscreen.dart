import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/collected.dart';
import 'homepage.dart';
import 'loginpage.dart';

class InitScreen extends StatefulWidget {
  // não sei se tá certo isso
  final AppBar appBar;
  final Collected dataCollected;
  final FlutterBlue bluetooth;
  const InitScreen(
      {Key? key,
      required this.appBar,
      required this.dataCollected,
      required this.bluetooth})
      : super(key: key);

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        CircularProgressIndicator(),
        Padding(
            padding: EdgeInsets.all(24.0),
            child: Text("*finge que é uma animação*")),
      ],
    )));
  }

  @override
  void initState() {
    super.initState();
    animationDelay();
  }

  animationDelay() async {
    return Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => // MainState.auth
                  // ? LoginPage(
                  //     appBar: widget.appBar,
                  //     dataCollected: widget.dataCollected,
                  //     bluetooth: widget.bluetooth,
                  //   ):
                  HomePage(
                    appBar: widget.appBar,
                    dataCollected: widget.dataCollected,
                    bluetooth: widget.bluetooth,
                  )));
    });
  }
}
