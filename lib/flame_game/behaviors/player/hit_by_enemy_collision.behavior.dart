import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

import '../../entities/enemy.entity.dart';
import '../../entities/player.entity.dart';
import '../../game.dart';

class HitByEnemy extends CollisionBehavior<EntityMixin, PlayerAnimationEntity> with HasGameReference<DestroyerGame> {
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, EntityMixin other) {
    if (other is EnemyEntity) {
      if (game.playerData.health.value > 0 &&
          other.currentHealth > 0 &&
          !game.playerData.effects.value.any((effect) =>
              effect.name == 'invincible' ||
              effect.name == 'timeWalk' ||
              effect.name == 'ballLightning' ||
              effect.name == 'guardianEngel')) {
        parent.hit();
        final dmg = other.enemy.damage - game.playerData.armor.value;
        game.playerData.health.value -= max(dmg.round(), 0);
      }
    }
    if (other is EnemyAnimationEntity) {
      if (game.playerData.health.value > 0 &&
          other.currentHealth > 0 &&
          !game.playerData.effects.value.any(
              (effect) => effect.name == 'invincible' || effect.name == 'timeWalk' || effect.name == 'ballLightning')) {
        parent.hit();
        final dmg = other.enemy.damage - game.playerData.armor.value;
        game.playerData.health.value -= max(dmg.round(), 0);
      }
    }
    // Vector2 collisionDirection = other.position - position;
    // collisionDirection.normalize(); // Normalize to get a unit vector

    // // Apply the pushback force or change the position
    // // You can adjust the pushbackStrength to your liking
    // double pushbackStrength = 10.0;
    // other.position += collisionDirection * pushbackStrength;
  }
}
