import 'package:flutter/material.dart';

class BezierClipper extends CustomClipper<Path> {
  double height;
  BezierClipper({this.height = 0.4});

  @override
  Path getClip(Size size) {
    var controlPoint = Offset(size.width * 0.5, size.height);
    var endPoint = Offset(size.width, size.height * height);

    Path path = Path()
      ..lineTo(0, size.height * height)
      ..quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CubicClipper extends CustomClipper<Path> {
  double height;
  CubicClipper({this.height = 0.5});

  @override
  Path getClip(Size size) {
    var controlPoint1 = Offset(size.width * 0.15, size.height);
    var controlPoint2 = Offset(size.width * 0.85, size.height);
    var endPoint = Offset(size.width, size.height * height);

    Path path = Path()
      ..lineTo(0, size.height * height)
      ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
          controlPoint2.dy, endPoint.dx, endPoint.dy)
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
