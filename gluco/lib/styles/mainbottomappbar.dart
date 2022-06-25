// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gluco/styles/colors.dart';

BottomAppBar mainBottomAppBar(context, page) => BottomAppBar(
      color: fundoScaf2,
      elevation: 0.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: page == 'home'
                      ? BorderSide(
                          width: 5.0, color: azulClaro.withOpacity(1.0))
                      : BorderSide.none,
                ),
              ),
              child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Medir',
                    style: TextStyle(
                      color: page == 'home'
                          ? azulClaro.withOpacity(1.0)
                          : Colors.grey,
                      fontWeight:
                          page == 'home' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ),
                onPressed: () async {
                  if (page != 'home') {
                    await Navigator.popAndPushNamed(context, '/home');
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: page == 'history'
                      ? BorderSide(
                          width: 5.0, color: azulClaro.withOpacity(1.0))
                      : BorderSide.none,
                ),
              ),
              child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Histórico',
                    style: TextStyle(
                      color: page == 'history'
                          ? azulClaro.withOpacity(1.0)
                          : Colors.grey,
                      fontWeight: page == 'history'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ),
                onPressed: () async {
                  if (page != 'history') {
                    await Navigator.pushNamed(context, '/history');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
