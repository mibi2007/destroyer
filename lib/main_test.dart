import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomPaint(
        painter: Painter(),
      ),
    );
  }
}

class Painter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c1 = Offset(size.width / 2 - 50, size.height / 2);
    final c2 = Offset(size.width / 2 + 50, size.height / 2);

    final rect1 = Rect.fromCenter(center: c1, width: 100, height: 100);

    final rect2 = Rect.fromCenter(center: c2, width: 100, height: 100);

    canvas.drawRect(
      rect1,
      Paint()
        ..blendMode = BlendMode.dstOut
        ..shader = const RadialGradient(
          colors: [Colors.green, Colors.transparent],
        ).createShader(rect1),
    );

    canvas.drawRect(
      rect2,
      Paint()
        ..blendMode = BlendMode.srcOut
        ..shader = const RadialGradient(
          colors: [Colors.green, Colors.transparent],
        ).createShader(rect1),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
