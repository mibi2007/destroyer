import 'dart:async';

import 'package:destroyer/flame_game/entities/player.entity.dart';
import 'package:flame/components.dart';
import 'package:flame_steering_behaviors/flame_steering_behaviors.dart';

import '../../models/player_data/player_data.dart';
import '../behaviors/move_on_platform.behavior.dart';
import 'enemy.entity.dart';

const relativeValue = 16.0;

class GarbageMonsterEntity extends EnemyEntity with Steerable, OnGround {
  bool isRolling = false;
  GarbageMonsterEntity(super.enemy, super.image, {super.position})
      : super(
          srcPosition: Vector2.zero(),
          srcSize: Vector2(128, 128),
          size: Vector2(32, 32),
        );

  late final Timer _timer;
  int seconds = 0;
  late final Direction direction;

  @override
  Future<FutureOr<void>> onLoad() async {
    super.onLoad();
    direction = Direction(Vector2(game.playerData.direction.value.x, 0));
    await addAll([
      MoveOnPlatform(),
      SeparationBehavior(
        parent.children.query<GarbageMonsterEntity>(),
        maxDistance: 2 * relativeValue,
        maxAcceleration: 10 * relativeValue,
      ),
      PursueBehavior(parent.children.whereType<PlayerEntity>().first, pursueRange: 250),
    ]);
    _timer = Timer(1, onTick: () {
      if (direction.x * (position.x - game.playerData.position.value.x) < 0) {
        flipHorizontallyAroundCenter();
      }
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
    if (isInsideChronosphere) {
      velocity = Vector2.zero();
      return;
    }
    super.update(dt);
    if (isRolling || isHit || isBurned || isElectricShocked) {
      velocity.x = 0;
      velocity.y = 0;
    }
    _timer.update(dt);
  }

  @override
  double get maxVelocity => 10 * relativeValue;

  @override
  void onRemove() {
    _timer.stop();
    super.onRemove();
  }

  @override
  void flipHorizontallyAroundCenter() {
    direction.x = -direction.x;
    if (direction.x < 0) {
      healthBar.flipHorizontally();
      healthBar.position.x = width;
    } else {
      healthBar.flipHorizontally();
      healthBar.position.x = 0;
    }
    super.flipHorizontallyAroundCenter();
  }
}
