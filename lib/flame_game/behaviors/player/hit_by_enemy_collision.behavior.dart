import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

import '../../entities/enemy.entity.dart';
import '../../entities/player.entity.dart';
import '../../game.dart';

class HitByEnemy extends CollisionBehavior<EnemyEntity, PlayerAnimationEntity> with HasGameReference<DestroyerGame> {
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, EnemyEntity other) {
    if (game.playerData.health.value > 0 &&
        !other.isDamaging &&
        !game.playerData.effects.value.any(
            (effect) => effect.name == 'invincible' || effect.name == 'timeWalk' || effect.name == 'ballLightning')) {
      parent.hit();
      other.isDamaging = true;
      game.playerData.health.value -= (other.enemy.damage - game.playerData.armor.value * 3).round();
    }
    // Vector2 collisionDirection = other.position - position;
    // collisionDirection.normalize(); // Normalize to get a unit vector

    // // Apply the pushback force or change the position
    // // You can adjust the pushbackStrength to your liking
    // double pushbackStrength = 10.0;
    // other.position += collisionDirection * pushbackStrength;
  }
}
