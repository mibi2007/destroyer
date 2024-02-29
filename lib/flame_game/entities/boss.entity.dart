import 'package:flame/components.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

import '../../models/enemies.dart';
import '../behaviors/move_on_platform.behavior.dart';
import '../entities/enemy.entity.dart';
import 'garbage_monster.entity.dart';
import 'player.entity.dart';

class BossEntity extends EnemyAnimationEntity with Steerable, OnGround {
  BossEntity({required this.boss, required super.size, required super.position, required super.priority})
      : super(enemy: boss);

  final Boss boss;

  late final Timer _timer;

  int _secondCount = 0;
  @override
  Future<void> onLoad() async {
    super.onLoad();
    await addAll([
      MoveOnPlatform(),
      SeparationBehavior(
        parent.children.query<GarbageMonsterEntity>(),
        maxDistance: 2 * relativeValue,
        maxAcceleration: 10 * relativeValue,
      ),
      PursueBehavior(parent.children.whereType<PlayerEntity>().first, pursueRange: 400),
    ]);
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

  @override
  move() {
    animation = boss.moveAnimation;
  }

  @override
  attack() {
    animation = boss.attackAnimation;
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
  double get maxVelocity => 3 * relativeValue;
}
