// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:gluco/styles/customcolors.dart';

class IconCard extends StatelessWidget {
  final Icon icon;
  final Text label;
  final Text data;
  final Color color;
  final Size size;

  IconCard({
    required this.icon,
    required this.label,
    required this.data,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    double landscapeCorrection =
        MediaQuery.of(context).orientation == Orientation.landscape
            ? 0.75
            : 1.0;
    return SizedBox(
      height: size.height * landscapeCorrection,
      width: size.width,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              SizedBox(
                height: size.height * 0.15 * landscapeCorrection,
              ),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
                elevation: 4.0,
                child: Container(
                  height: size.height * 0.85 * landscapeCorrection,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: CustomColors.histWhite,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(height: size.height * 0.1),
                      if (MediaQuery.of(context).orientation ==
                          Orientation.portrait) ...[
                        label,
                        data,
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [label, data],
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: size.height * 0.35,
            width: size.height * 0.35,
            child: icon,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
