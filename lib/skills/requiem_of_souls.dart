import 'dart:ui' as ui;

import 'package:destroyer/flame_game/game.dart';
import 'package:destroyer/models/skills.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

class RequiemOfSoulsSkillComponent extends SpriteComponent with CollisionCallbacks, HasGameRef<DestroyerGame> {
  // double radious = 100;
  final skill = Skills.requiemOfSouls;
  final double duration;
  final double delayCast;

  late ui.Image image;
  RequiemOfSoulsSkillComponent({required this.duration, required this.delayCast, required super.position})
      : super(priority: 3, anchor: Anchor.center);

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    sprite = Sprite(game.images.fromCache('assets/images/skills-and-effects/Requiem_of_Souls_effect.png'));
    final animationController = CurvedEffectController(duration, Curves.easeOutCubic);
    size = Vector2(0, 0);
    add(CircleHitbox());
    add(SizeEffect.to(Vector2(1200, 1200), animationController));
    add(TimerComponent(
      period: duration, // The period in seconds
      onTick: () {
        add(OpacityEffect.fadeOut(
          LinearEffectController(0.5),
          onComplete: () {
            game.playerData.souls.value = 0;
            add(RemoveEffect());
          },
        ));
      },
    ));
  }
}
