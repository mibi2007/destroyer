import 'package:destroyer/flame_game/entities/garbage_monster.entity.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/sprite.dart';

import '../../models/enemies.dart';
import 'enemy.entity.dart';

const String curseAsset = 'assets/animations/flame.png';

class GarbageEntity extends EnemyEntity {
  final Vector2 curseSrcSize = Vector2(16, 16);
  // final double curseDimension = 16;
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

  void curse() {
    isCursed = true;
    addAll([
      SpriteAnimationComponent(
        animation: getCurseAnimation(game.images),
      ),
      SpriteAnimationComponent(
        animation: getCurseAnimation(game.images),
        size: Vector2.all(32),
        position: Vector2(2, 2),
      ),
      SpriteAnimationComponent(
        animation: getCurseAnimation(game.images),
        position: Vector2(16, 0),
      ),
    ]);
    add(TimerComponent(
      period: 3, // The period in seconds
      onTick: () {
        parent.add(GarbageMonsterEntity(enemy, game.images.fromCache('assets/images/enemies/garbage_monster.png'),
            position: position));
        removeFromParent();
      },
    ));
  }

  @override
  void onRemove() {
    game.playerData.garbages.value++;
    super.onRemove();
  }

  GarbageEntity cloneCursed(Garbage newGarbage, Vector2 newPosition) {
    return GarbageEntity(
      newGarbage,
      image,
      position: newPosition,
      targetPosition: targetPosition,
      size: size,
      scale: scale,
      angle: angle,
      anchor: anchor,
      priority: priority,
    );
  }
}

SpriteAnimation getCurseAnimation(Images images) {
  const columns = 7;
  const rows = 1;
  const frames = columns * rows;
  final spriteImage = images.fromCache(curseAsset);
  final spriteSheet = SpriteSheet.fromColumnsAndRows(
    image: spriteImage,
    columns: columns,
    rows: rows,
  );
  final sprites = List<Sprite>.generate(frames, spriteSheet.getSpriteById);
  return SpriteAnimation.spriteList(sprites, stepTime: 0.1, loop: true);
}
