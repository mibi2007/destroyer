// import 'dart:async';

import 'package:destroyer/flame_game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class JumpButton extends PositionComponent with HasGameReference<DestroyerGame>, TapCallbacks {
  late final SpriteComponent imageBtn;
  late final CircleComponent shadow;
  JumpButton({required super.position, required super.size}) : super(priority: 3);

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
      game.images.fromCache('assets/images/hud/jump-button.png'),
      size: Vector2(64, 64),
      srcSize: Vector2(64, 64),
      priority: 1,
    );
    add(imageBtn);
    add(shadow);
  }

  @override
  void onTapUp(TapUpEvent event) {
    add(shadow);
    super.onTapUp(event);
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.playerData.jump.trigger();
    if (shadow.isMounted) remove(shadow);
    super.onTapDown(event);
  }
}
