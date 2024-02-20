import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

import '../game.dart';
import 'player.dart';

// Represents a collectable coin in the game world.
class Coin extends SpriteComponent with CollisionCallbacks, HasGameReference<DestroyerGame> {
  bool isInsideChronosphere = false;
  late MoveEffect effect;
  Coin(
    super.image, {
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.priority,
  }) : super.fromImage(
          srcPosition: Vector2(3 * 32, 0),
          srcSize: Vector2.all(32),
        );

  @override
  Future<void> onLoad() async {
    add(CircleHitbox()..collisionType = CollisionType.passive);

    // Keeps the coin bouncing
    effect = MoveEffect.by(
      Vector2(0, -4),
      EffectController(
        alternate: true,
        infinite: true,
        duration: 1,
        curve: Curves.ease,
      ),
    );
    await add(effect);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlayerAnimationComponent) {
      // AudioManager.playSfx('Collectibles_6.wav');

      // SequenceEffect can also be used here
      add(
        OpacityEffect.fadeOut(
          LinearEffectController(0.3),
          onComplete: () {
            add(RemoveEffect());
          },
        ),
      );

      game.setCredits(game.getCredits() + 1);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    if (isInsideChronosphere) {
      effect.pause();
    } else {
      effect.resume();
    }
    super.update(dt);
  }
}
