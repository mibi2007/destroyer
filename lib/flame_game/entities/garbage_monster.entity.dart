import 'dart:async';

import 'package:destroyer/flame_game/entities/player.entity.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

import '../behaviors/enemy/attacked_by_player.behavior.dart';
import '../behaviors/enemy/move_on_platform.behavior.dart';
import 'enemy.entity.dart';

const relativeValue = 16.0;
const double g = 150;

class GarbageMonsterEntity extends EnemyEntity with Steerable {
  bool isRolling = false;
  Vector2 collisionNormal = Vector2.zero();
  bool isOnGround = false;
  GarbageMonsterEntity(super.enemy, super.image, {super.position})
      : super(
          srcPosition: Vector2.zero(),
          srcSize: Vector2(128, 128),
          size: Vector2(32, 32),
        );

  late final Timer _timer;
  int seconds = 0;

  @override
  Future<FutureOr<void>> onLoad() async {
    await addAll([
      PropagatingCollisionBehavior(CircleHitbox(isSolid: true)),
      ...attackedBehaviors(),
      MoveOnPlatform(),
      SeparationBehavior(
        parent.children.query<GarbageMonsterEntity>(),
        maxDistance: 2 * relativeValue,
        maxAcceleration: 10 * relativeValue,
      ),
      PursueBehavior(parent.children.whereType<PlayerEntity>().first, pursueRange: 250),
    ]);
    _timer = Timer(1, onTick: () {
      seconds++;
      if (seconds % 3 == 0) {
        isRolling = false;
      } else if (seconds % 3 == 2) {
        isRolling = true;
      }
      // print('isHit $isHit, isBurned $isBurned, isElectricShocked $isElectricShocked, isRolling $isRolling');
    }, repeat: true);
  }

  @override
  void update(double dt) {
    if (!isOnGround) {
      velocity.y += g * dt;
    }
    if (isRolling || isHit || isBurned || isElectricShocked) {
      velocity.x = 0;
      velocity.y = 0;
    }
    _timer.update(dt);
    super.update(dt);
  }

  @override
  double get maxVelocity => 10 * relativeValue;

  @override
  void onRemove() {
    _timer.stop();
    super.onRemove();
  }
}
