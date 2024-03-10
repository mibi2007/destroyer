import 'package:destroyer/models/player_data/player_data.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';
import 'package:flutter/animation.dart';

import '../../models/enemies.dart';
import '../../utils/utils.dart';
import '../behaviors/move_on_platform.behavior.dart';
import '../entities/enemy.entity.dart';
import 'garbage.entity.dart';
import 'garbage_monster.entity.dart';
import 'player.entity.dart';

class BossEntity extends EnemyAnimationEntity with Steerable, OnGround {
  final bool isAutonomous;
  late final Direction direction;
  BossEntity({
    this.isAutonomous = true,
    required this.boss,
    required super.size,
    required super.position,
    required super.priority,
  }) : super(enemy: boss);

  final Boss boss;
  late final GarbageEntity garbageBullet;
  late final Garbage garbage;

  late final Timer _timer;

  int _secondCount = 0;
  @override
  Future<void> onLoad() async {
    garbage = Garbage(
      level: game.level.number,
      asset: rnd.nextDouble() * 2 < 1 ? 'assets/images/enemies/garbage1.png' : 'assets/images/enemies/garbage2.png',
      maxHealth: 100,
      armor: game.level.number * 5,
      damage: 10 + game.level.number * 5,
    );
    garbageBullet = GarbageEntity(garbage, game.images.fromCache(garbage.asset),
        position: Vector2(0, 0), size: Vector2.all(32), anchor: Anchor.center);
    super.onLoad();
    direction = Direction(Vector2(-game.playerData.direction.value.x, 0));

    _timer = Timer(1, repeat: true, onTick: () {
      if (!isMounted) return;
      if (direction.x * (position.x - game.playerData.position.value.x) < 0) {
        flipHorizontallyAroundCenter();
      }
      if (currentHealth == 0) {
        add(TimerComponent(
          period: 1, // The period in seconds
          onTick: () {
            removeFromParent();
          },
          removeOnFinish: true,
        ));
      }
      if (isAutonomous && game.level.number > 2) {
        final distanceToPlayer = position.distanceTo(game.playerData.position.value);
        if (_secondCount % 5 == 0 && distanceToPlayer < 1000) {
          attack();
          add(TimerComponent(
            period: 0.6, // The period in seconds
            onTick: () {
              move();
            },
            removeOnFinish: true,
          ));
        }
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
  Future<void> onActivate() async {
    super.onActivate();

    await addAll([
      MoveOnPlatform(),
      if (isAutonomous) ...[
        SeparationBehavior(
          parent.children.query<GarbageMonsterEntity>(),
          maxDistance: 2 * relativeValue,
          maxAcceleration: 10 * relativeValue,
        ),
        PursueBehavior(parent.children.whereType<PlayerEntity>().first, pursueRange: 700),
      ]
    ]);
  }

  @override
  removeFromParent() {
    onKilled?.call();
    super.removeFromParent();
  }

  @override
  move() {
    animation = boss.moveAnimation;
  }

  @override
  attack() {
    if (!isMounted) return;
    animation = boss.attackAnimation;
    garbageBullet.sprite = Sprite(game.images.fromCache(
        rnd.nextDouble() * 2 < 1 ? 'assets/images/enemies/garbage1.png' : 'assets/images/enemies/garbage2.png'));
    garbageBullet.position = position + Vector2(-width / 2, height - 32);
    parent.add(garbageBullet);
    garbageBullet
        .add(MoveEffect.to(game.playerData.position.value + Vector2(0, -20), CurvedEffectController(1, Curves.easeIn)));
    garbageBullet.curse();
  }

  @override
  void update(double dt) {
    if (isInsideChronosphere) {
      velocity = Vector2.zero();
      return;
    }
    _timer.update(dt);
    super.update(dt);
  }

  @override
  void onRemove() {
    _timer.stop();
    super.onRemove();
  }

  @override
  void flipHorizontallyAroundCenter() {
    direction.x = -direction.x;
    if (direction.x > 0) {
      healthBar.flipHorizontally();
      healthBar.position.x = width;
    } else {
      healthBar.flipHorizontally();
      healthBar.position.x = 0;
    }
    super.flipHorizontallyAroundCenter();
  }

  @override
  double get maxVelocity => 3 * relativeValue;
}
