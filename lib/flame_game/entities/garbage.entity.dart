import 'package:flame/effects.dart';

import 'enemy.entity.dart';

class GarbageEntity extends EnemyEntity {
  GarbageEntity(
    super.enemy,
    super.image, {
    super.position,
    super.targetPosition,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.priority,
    super.arrmor,
    super.srcPosition,
    super.srcSize,
  });

  bool isDropped = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    garbageLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isDropped) return;
    if (game.playerData.position.value.x > position.x) {
      add(effect!);
    }
  }

  Future<void> garbageLoad() async {
    effect = SequenceEffect([
      if (targetPosition != null)
        MoveToEffect(
          targetPosition!,
          EffectController(speed: 800),
        ),
    ]);
  }
}
