import 'package:flutter/material.dart';

class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.purple;
    Path path = Path()
      ..relativeLineTo(0, 80)
      ..quadraticBezierTo(size.width / 2, 120, size.width, 80)
      ..relativeLineTo(0, -120)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
