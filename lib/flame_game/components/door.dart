import 'package:destroyer/flame_game/entities/player.entity.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

// Represents a door in the game world.
class Door extends SpriteComponent with CollisionCallbacks {
  Function? onPlayerEnter;

  Door(
    super.image, {
    this.onPlayerEnter,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.priority,
  }) : super.fromImage(
          srcPosition: Vector2(2 * 32, 0),
          srcSize: Vector2.all(32),
        );

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox.relative(0.5, parentSize: size, position: Vector2(width / 4, height / 4)));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlayerAnimationEntity) {
      // AudioManager.playSfx('Blop_1.wav');
      onPlayerEnter?.call();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
