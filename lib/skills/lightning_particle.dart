import 'dart:async';

import 'package:destroyer/models/player_data/player_data.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';

Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 200;

class LightningParticle extends Particle {
  // double duration;
  final Vector2 start;
  final Vector2 end;
  final Paint paint;
  final int segments;
  final double amplitude;
  final double minStrokeWidth;
  final double maxStrokeWidth;

  // double _time = 0;

  LightningParticle({
    // required this.duration,
    required this.start,
    required this.end,
    required double lifespan,
    this.segments = 30,
    this.amplitude = 10.0,
    this.minStrokeWidth = 1.0,
    this.maxStrokeWidth = 1.0,
  })  : paint = Paint()
          ..color = const Color.fromARGB(255, 230, 233, 255)
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

    drawJaggedLine(canvas, start, end, paint, segments, amplitude, minStrokeWidth, maxStrokeWidth);
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
  double segmentLength = (end - start).length / 10;
  // Vector2 current = start.clone();

  Path path = Path()..moveTo(start.x, start.y);
  for (int i = 0; i < segmentLength; i++) {
    // Calculate the target point for the current segment
    Vector2 target = start + (end - start) * (i / segmentLength);
    // Apply randomness to create the jagged effect
    target += randomVector2().normalized() * (rnd.nextDouble() * amplitude - amplitude / 2);
    // Random stroke width from 10 to 30
    paint.strokeWidth = minStrokeWidth + rnd.nextDouble() * maxStrokeWidth;
    path.lineTo(target.x, target.y);
    // current = target;
  }
  path.lineTo(end.x, end.y);

  canvas.drawPath(path, paint);
}

class SmallLightningParticle extends ParticleSystemComponent {
  final Vector2 start;
  final Vector2 end;
  double? lifespan;
  SmallLightningParticle({
    required this.start,
    required this.end,
    this.lifespan,
  }) : super(
          particle: LightningParticle(
            start: start,
            end: end,
            lifespan: lifespan ?? 1,
          ),
        );
}

class LargeLightningParticle extends ParticleSystemComponent {
  final Vector2 start;
  final Vector2 end;
  LargeLightningParticle({
    required this.start,
    required this.end,
  }) : super(
          particle: LightningParticle(
            start: start,
            end: end,
            lifespan: 0.1,
            segments: 10,
            amplitude: 12,
            minStrokeWidth: 1,
            maxStrokeWidth: 20,
          ),
        );
}

class ThunderStrikeEffects extends PositionComponent with CollisionCallbacks {
  final Direction direction;
  Timer? _timer;
  int _tickCount = 0;
  final double gap;
  final double delay;

  ThunderStrikeEffects({
    required this.direction,
    required super.size,
    required super.position,
    required this.gap,
    required this.delay,
  });

  @override
  bool get debugMode => false;

  @override
  FutureOr<void> onLoad() {
    _timer = Timer(delay, onTick: onTick, repeat: true);
  }

  void onTick() {
    final hitbox = RectangleHitbox(position: Vector2(_tickCount * gap * direction.x, 0), size: Vector2(1, height));
    add(hitbox);

    final start = Vector2(_tickCount * gap * direction.x, 0);
    final end = Vector2(_tickCount * gap * direction.x, height);

    final lightning1 = SmallLightningParticle(
        start: start + Vector2(gap * direction.x, 0), end: end + Vector2(gap * direction.x, 0), lifespan: 0.1);
    final lightning2 = SmallLightningParticle(start: start, end: end, lifespan: 0.2);
    add(lightning1);
    add(lightning2);

    add(LargeLightningParticle(start: start, end: end));
    _tickCount++;
    add(TimerComponent(
      period: delay, // The period in seconds
      onTick: () {
        if (isMounted) remove(hitbox);
      },
    ));
  }

  @override
  update(double dt) {
    super.update(dt);
    if (_timer != null) _timer!.update(dt);
  }

  @override
  void onRemove() {
    if (_timer != null) _timer!.stop();
    super.onRemove();
  }
}
