import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

Random rnd = Random();

Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 200;

class LightningParticle extends Particle {
  // double duration;
  final Vector2 start;
  final Vector2 end;
  final Paint paint;
  // double _time = 0;

  LightningParticle({
    // required this.duration,
    required this.start,
    required this.end,
    required double lifespan,
  })  : paint = Paint()
          ..color = const Color(0xffa8fff6)
          ..strokeWidth = 10.0
          ..style = PaintingStyle.stroke,
        super(lifespan: lifespan);

  @override
  void render(Canvas canvas) {
    // Custom rendering logic for the lightning strike
    // Draw a jagged line from positionA to positionB
    // Implement flickering by changing paint color's alpha over time
    // final alpha = lifespan > _time ? ((lifespan - _time)) / lifespan : 0;
    paint.color = paint.color.withAlpha((155 + rnd.nextDouble() * 100).toInt());

    drawJaggedLine(canvas, start, end, paint, 30, 10, 1, 1);
  }

  // @override
  // void update(double dt) {
  //   // Update the duration of the lightning strike
  //   _time += dt;
  // }
}

void drawJaggedLine(Canvas canvas, Vector2 start, Vector2 end, Paint paint, int segments, double amplitude,
    double minStrokeWidth, double maxStrokeWidth) {
  // Define the number of segments and the amplitude of the zigzag
  double segmentLength = (end - start).length / segments;
  Vector2 current = start.clone();

  Path path = Path()..moveTo(start.x, start.y);
  for (int i = 1; i < segments; i++) {
    // Calculate the target point for the current segment
    Vector2 target = start + (end - start) * (i / segments);
    // Apply randomness to create the jagged effect
    target += randomVector2().normalized() * (rnd.nextDouble() * amplitude - amplitude / 2);
    // Random stroke width from 10 to 30
    paint.strokeWidth = minStrokeWidth + rnd.nextDouble() * maxStrokeWidth;
    path.lineTo(target.x, target.y);
    current = target;
  }
  path.lineTo(end.x, end.y);

  canvas.drawPath(path, paint);
}

extension OffsetExtensions on Offset {
  Offset normalize() {
    final length = sqrt(dx * dx + dy * dy);
    return Offset(dx / length, dy / length);
  }
}
