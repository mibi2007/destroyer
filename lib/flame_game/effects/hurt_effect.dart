import 'package:destroyer/flame_game/entities/player.entity.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// The [HurtEffect] is an effect that is composed of multiple different effects
/// that are added to the [Player] when it is hurt.
/// It spins the player, shoots it up in the air and makes it blink in white.
class HurtEffect extends Component with ParentIsA<PlayerEntity> {
  @override
  void onMount() {
    super.onMount();
    const effectTime = 0.5;
    parent.addAll(
      [
        ColorEffect(
          Colors.white,
          EffectController(
            duration: effectTime / 8,
            alternate: true,
            repeatCount: 2,
          ),
          opacityTo: 0.9,
        ),
      ],
    );
  }
}
