import 'package:destroyer/flame_game/components/coin.dart';
import 'package:destroyer/flame_game/entities/enemy.entity.dart';
import 'package:destroyer/flame_game/entities/player.entity.dart';
import 'package:destroyer/flame_game/game.dart';
import 'package:destroyer/models/skills.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class ChronosphereSkillComponent extends SpriteComponent with CollisionCallbacks, HasGameRef<DestroyerGame> {
  // double radious = 100;
  final double duration;
  final double delayCast;

  ChronosphereSkillComponent({required this.duration, required this.delayCast, required super.position})
      : super(priority: 3, anchor: Anchor.center);

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final animationController = CurvedEffectController(delayCast, Curves.easeOutCubic);
    size = Vector2(0, 0);
    add(CircleHitbox(isSolid: true));
    final image = game.images.fromCache('assets/images/skills-and-effects/Chronosphere_effect.png');
    sprite = Sprite(image, srcPosition: Vector2.all(width));
    // paint = ui.Paint()
    //   ..color = const ui.Color(0xcc000000)
    //   ..style = ui.PaintingStyle.fill;
    add(SizeEffect.to(Vector2(400, 400), animationController));
    add(TimerComponent(
      period: duration, // The period in seconds
      onTick: () {
        add(OpacityEffect.fadeOut(
          animationController..duration = 2,
          onComplete: () {
            game.playerData.effects.removeAll([SkillEffects.chronosphere, SkillEffects.invincible5s]);
            add(RemoveEffect());
          },
        ));
      },
      removeOnFinish: true,
    ));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlayerAnimationEntity) {
      game.playerData.effects.add(SkillEffects.timeWalk5s, shouldNotify: true);
    }
    if (other is EnemyEntity) {
      other.isInsideChronosphere = true;
    }
    if (other is EnemyAnimationEntity) {
      other.isInsideChronosphere = true;
    }
    if (other is Coin) {
      other.isInsideChronosphere = true;
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is PlayerAnimationEntity) {
      game.playerData.effects.remove(SkillEffects.timeWalk5s, shouldNotify: true);
    }
    if (other is EnemyEntity) {
      other.isInsideChronosphere = false;
    }
    if (other is EnemyAnimationEntity) {
      other.isInsideChronosphere = false;
    }
    if (other is Coin) {
      other.isInsideChronosphere = false;
    }
    super.onCollisionEnd(other);
  }

  @override
  void update(double dt) {
    // schrono.size = size;
    super.update(dt);
  }
}
