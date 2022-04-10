// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, use_key_in_widget_constructors, must_be_immutable, unnecessary_string_interpolations, prefer_typing_uninitialized_variables, deprecated_member_use

import 'package:flutter/material.dart';
// import 'package:gluco/models/collected.dart';


class ValuesCard extends StatelessWidget {
  // int valor = 0;
  final String label;
  var dados;
  ValuesCard({
    // required this.valor,
    required this.dados,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: constraints.maxWidth,
            alignment: AlignmentDirectional.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Theme.of(context).accentColor, width: 3),
            ),
            child: FittedBox(
              child: Text(
                '$label: ${dados.toString()}',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ],
      );
    });
  }
}
