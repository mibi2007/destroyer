import 'dart:async';

import 'package:destroyer/level_selection/level.dart';
import 'package:destroyer/models/equipments.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/image_composition.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

import '../../models/enemies.dart';
import '../behaviors/enemy/attacked_by_player.behavior.dart';
import '../behaviors/enemy/enemy_collision.dart';
import '../components/damage_text.dart';
import '../components/health_bar.dart';
import '../game.dart';

class EnemyEntity extends SpriteComponent
    with
        ParentIsA<SceneComponent>,
        CollisionCallbacks,
        HasGameReference<DestroyerGame>,
        HealthBar,
        EnemyCollision,
        EntityMixin,
        ShowDamageText {
  static final Vector2 _left = Vector2(-1, 0);
  Vector2 direction = _left;

  // bool isHit = false;
  // bool isShockElectric = false;
  // bool isBurned = false;
  // bool isDamaging = false;

  final Enemy enemy;
  SequenceEffect? effect;
  void Function()? onKilled;
  final Vector2? targetPosition;
  // bool isInsideChronosphere = false;

  EnemyEntity(
    this.enemy,
    Image image, {
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
    // if (targetPosition != null && position != null) {
    //   // Need to sequence two move to effects so that we can
    //   // tap into the onFinishCallback and flip the component.
    //   effect = SequenceEffect(
    //     [
    //       MoveToEffect(
    //         targetPosition,
    //         EffectController(speed: 100),
    //         onComplete: () {
    //           flipHorizontallyAroundCenter();
    //           direction = _right;
    //         },
    //       ),
    //       MoveToEffect(
    //         position + Vector2(32, 0), // Need to offset by 32 due to flip
    //         EffectController(speed: 100),
    //         onComplete: () {
    //           flipHorizontallyAroundCenter();
    //           direction = _left;
    //         },
    //       ),
    //     ],
    //     infinite: true,
    //   );
    //   add(effect!);
    // }
    initHealthBar(enemy.maxHealth, width);
  }

  @override
  bool get debugMode => false;

  @override
  void update(double dt) {
    super.update(dt);

    if (isHit || isInsideChronosphere || isElectricShocked || isBurned) {
      effect?.pause();
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
  Future<void> onLoad() async {
    addAll([
      PropagatingCollisionBehavior(CircleHitbox(collisionType: CollisionType.passive, isSolid: true)),
      ...attackedBehaviors(),
    ]);
    // await add(CircleHitbox()..collisionType = CollisionType.passive);
    maxHealth = enemy.maxHealth;
    currentHealth = maxHealth;
    // add(EnemyBehavior());
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
    with HasGameRef<DestroyerGame>, HealthBar, CollisionCallbacks, EnemyCollision, EntityMixin, ShowDamageText {
  final Enemy enemy;

  void Function()? onKilled;

  EnemyAnimationEntity({required this.enemy, required super.size, required super.position, required super.priority});
  late final Timer _timer;

  int _secondCount = 0;

  @override
  FutureOr<void> onLoad() {
    addAll([
      PropagatingCollisionBehavior(CircleHitbox(collisionType: CollisionType.passive, isSolid: true)),
      ...attackedBehaviors(),
    ]);
    initHealthBar(enemy.maxHealth, width);
    _timer = Timer(1, repeat: true, onTick: () {
      if (currentHealth == 0) {
        add(TimerComponent(
          period: 1, // The period in seconds
          onTick: () {
            removeFromParent();
          },
        ));
      }
      if (_secondCount % 5 == 0) {
        attack();
        add(TimerComponent(
          period: 0.6, // The period in seconds
          onTick: () {
            move();
          },
        ));
      }
      // if (_secondCount % 2 == 0) {
      //   if (game.playerData.position.value.x > position.x) {
      //     attack();
      //   }
      // }
      _secondCount++;
    });
    move();
  }

  @override
  removeFromParent() {
    onKilled?.call();
    super.removeFromParent();
  }

  move() {
    if (enemy is Boss) animation = (enemy as Boss).moveAnimation;
  }

  attack() {
    if (enemy is Boss) animation = (enemy as Boss).attackAnimation;
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  @override
  void onRemove() {
    _timer.stop();
    super.onRemove();
  }

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
