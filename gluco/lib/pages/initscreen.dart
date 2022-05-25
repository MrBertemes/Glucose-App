// ignore_for_file: use_key_in_widget_constructors

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gluco/styles/colors.dart';

class InitScreen extends StatefulWidget {
  final String route;
  const InitScreen({required this.route});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Text("*finge que é uma animação*"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    animationDelay();
  }

  animationDelay() async {
    return Timer(
      const Duration(seconds: 1),
      () {
        Navigator.popAndPushNamed(context, widget.route);
      },
    );
  }
}
