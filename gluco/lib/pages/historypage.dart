// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final AppBar appBar;

  HistoryPage({required this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Center(
        child: Text(
          "Histórico",
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
    );
  }
}
