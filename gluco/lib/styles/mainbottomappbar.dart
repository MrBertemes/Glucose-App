// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gluco/styles/customcolors.dart';

enum MainBottomAppBar { home, history }

BottomAppBar mainBottomAppBar(BuildContext context, MainBottomAppBar page) =>
    BottomAppBar(
      color: CustomColors.scaffWhite,
      elevation: 0.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: page == MainBottomAppBar.home
                      ? BorderSide(
                          width: 5.0,
                          color: CustomColors.lightBlue.withOpacity(1.0))
                      : BorderSide.none,
                ),
              ),
              child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Medir',
                    style: TextStyle(
                      color: page == MainBottomAppBar.home
                          ? CustomColors.lightBlue.withOpacity(1.0)
                          : Colors.grey,
                      fontWeight: page == MainBottomAppBar.home
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ),
                onPressed: () async {
                  if (page != MainBottomAppBar.home) {
                    Navigator.popUntil(context, ModalRoute.withName('/home'));
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: page == MainBottomAppBar.history
                      ? BorderSide(
                          width: 5.0,
                          color: CustomColors.lightBlue.withOpacity(1.0))
                      : BorderSide.none,
                ),
              ),
              child: TextButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Histórico',
                    style: TextStyle(
                      color: page == MainBottomAppBar.history
                          ? CustomColors.lightBlue.withOpacity(1.0)
                          : Colors.grey,
                      fontWeight: page == MainBottomAppBar.history
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ),
                onPressed: () async {
                  if (page != MainBottomAppBar.history) {
                    await Navigator.pushNamed(context, '/history');
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
