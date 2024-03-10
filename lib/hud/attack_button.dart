// import 'dart:async';

import 'dart:math';

import 'package:destroyer/flame_game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class AttackButton extends PositionComponent with HasGameReference<DestroyerGame>, TapCallbacks {
  late final SpriteComponent imageBtn;
  late final CircleComponent shadow;
  final effectController = LinearEffectController(0.2);
  // late final RotateEffect effect;
  AttackButton({required super.position, required super.size});

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    shadow = CircleComponent(
      position: Vector2(5, 5),
      radius: 28,
      paint: Paint()..color = Colors.black,
      priority: 0,
    );
    imageBtn = SpriteComponent.fromImage(
      game.images.fromCache('assets/images/hud/attack-button.png'),
      size: Vector2.all(64),
      srcSize: Vector2.all(64),
      priority: 1,
      anchor: Anchor.center,
      position: Vector2.all(32),
    );
    add(imageBtn);
    add(shadow);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (game.playerData.autoAttack.value) {
      game.playerData.autoAttack.value = false;
      add(shadow);
      effectController.setToStart();
      final effect = RotateEffect.by(pi / 6, effectController);
      imageBtn.add(effect);
    } else {
      game.playerData.autoAttack.value = true;
      effectController.setToStart();
      final effect = RotateEffect.by(-pi / 6, effectController);
      imageBtn.add(effect);
      remove(shadow);
    }
    super.onTapDown(event);
  }

  stop() {
    if (!game.playerData.autoAttack.value) return;
    game.playerData.autoAttack.value = false;
    add(shadow);
    effectController.setToStart();
    final effect = RotateEffect.by(pi / 6, effectController);
    imageBtn.add(effect);
  }

  // @override
  // void onTapDown(TapDownEvent event) {
  //   add(shadow);
  //   game.playerData.autoAttack.trigger();
  //   super.onTapDown(event);
  // }
}
