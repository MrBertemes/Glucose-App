// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

AppBar appBarTest({title}) => AppBar(
      elevation: 4,
      centerTitle: true,
      backgroundColor: Color.fromARGB(255, 98, 114, 250),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'OpenSans',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
