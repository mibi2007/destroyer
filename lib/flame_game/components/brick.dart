import 'dart:async';
import 'dart:ui';

import 'package:destroyer/flame_game/components/platform.dart';
import 'package:flame/components.dart';

class BrickComponent extends PositionComponent {
  final Image image;
  final int? offsetX;
  final int? offsetY;

  BrickComponent(
    this.image, {
    this.offsetX,
    this.offsetY,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.priority,
  });

  @override
  bool get debugMode => false;

  @override
  FutureOr<void> onLoad() {
    final brick = SpriteComponent.fromImage(
      image,
      srcPosition: Vector2((offsetX ?? 2) * 32, (offsetY ?? 2) * 32),
      srcSize: Vector2.all(32),
      position: Vector2.zero(),
    );
    add(brick);
    add(Platform(position: Vector2.zero(), size: Vector2(32, 32), isBrick: true));
    // add(RectangleHitbox());
  }
}
