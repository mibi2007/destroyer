import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import '../equipment.dart';
import '../player.dart';

class ArmorComponent extends EquipmentComponent with CollisionCallbacks {
  ArmorComponent({
    required super.item,
    required super.sprite,
    required super.size,
    required super.position,
  });

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    // Load your sword sprite and set up animations here
  }

  @override
  void update(double dt) {
    // Update the position or animation of the sword attack
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
}
