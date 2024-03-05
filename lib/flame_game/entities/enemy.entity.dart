import 'dart:async';

import 'package:destroyer/level_selection/level.dart';
import 'package:destroyer/models/equipments.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/image_composition.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/foundation.dart';

import '../../models/enemies.dart';
import '../behaviors/enemy/attacked_by_player.behavior.dart';
import '../behaviors/enemy/enemy_collision.dart';
import '../components/damage_text.dart';
import '../components/health_bar.dart';
import '../game.dart';

class EnemyEntity extends SpriteComponent
    with
        ParentIsA<SceneComponent>,
        HasGameReference<DestroyerGame>,
        HealthBar,
        EnemyCollision,
        EntityMixin,
        ShowDamageText {
  // bool isHit = false;
  // bool isShockElectric = false;
  // bool isBurned = false;
  // bool isDamaging = false;

  final Enemy enemy;
  final Image image;
  SequenceEffect? effect;
  void Function()? onKilled;
  final Vector2? targetPosition;
  // bool isInsideChronosphere = false;

  EnemyEntity(
    this.enemy,
    this.image, {
    super.position,
    this.targetPosition,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    int? arrmor,
    super.srcPosition,
    super.srcSize,
  }) : super.fromImage(
          image,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    initHealthBar(enemy.maxHealth, width);
  }

  @override
  bool get debugMode => false;

  @override
  void update(double dt) {
    super.update(dt);

    if (isHit || isInsideChronosphere || isElectricShocked || isBurned) {
      effect?.pause();
      return;
    } else {
      effect?.resume();
    }

    // if (isDamaging && _timerDamaging > 1) {
    //   isDamaging = false;
    //   _timerDamaging = 0;
    // } else {
    //   _timerDamaging += dt;
    // }
  }

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await addAll([
      PropagatingCollisionBehavior(CircleHitbox(isSolid: true)),
      ...attackedBehaviors(),
    ]);
    // await add(CircleHitbox()..collisionType = CollisionType.passive);
    // maxHealth = enemy.maxHealth;
    // currentHealth = maxHealth;
  }

  // @override
  // void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
  //   onEnemyCollisionStart(intersectionPoints, other, game, enemy);

  //   super.onCollisionStart(intersectionPoints, other);
  // }

  @override
  bool checkIfDead() {
    if (currentHealth <= 0) {
      add(OpacityEffect.fadeOut(LinearEffectController(0.5), onComplete: () {
        removeFromParent();

        if (game.playerData.sword.value.type == SwordType.flame && game.playerData.sword.value.level >= 3) {
          game.playerData.souls.value += 1;
        }
      }));
      return true;
    } else {
      return false;
    }
  }

  @override
  removeFromParent() {
    onKilled?.call();
    super.removeFromParent();
  }
}

class EnemyAnimationEntity extends SpriteAnimationComponent
    with
        HasGameRef<DestroyerGame>,
        HealthBar,
        CollisionCallbacks,
        EnemyCollision,
        EntityMixin,
        ShowDamageText,
        ParentIsA<SceneComponent> {
  final Enemy enemy;

  void Function()? onKilled;

  EnemyAnimationEntity({required this.enemy, required super.size, required super.position, required super.priority}) {
    initHealthBar(enemy.maxHealth, width);
  }

  @override
  @mustCallSuper
  FutureOr<void> onLoad() {
    addAll([
      PropagatingCollisionBehavior(CircleHitbox(isSolid: true)),
      ...attackedBehaviors(),
    ]);
  }

  move() {}

  attack() {}

  @override
  bool checkIfDead() {
    if (currentHealth <= 0) {
      add(OpacityEffect.fadeOut(LinearEffectController(0.5), onComplete: () {
        removeFromParent();

        if (game.playerData.sword.value.type == SwordType.flame && game.playerData.sword.value.level >= 3) {
          game.playerData.souls.value += 1;
        }
      }));
      return true;
    } else {
      return false;
    }
  }
}
