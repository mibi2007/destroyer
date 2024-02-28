import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';

mixin ShowDamageText on PositionComponent {
  void showDamage(double dmg) {
    // Show damage text
    final textComp = TextComponent(
      position: Vector2(position.x, position.y - 10),
      textRenderer: TextPaint(
          style: const TextStyle(
        fontSize: 8,
        color: Color(0xFFFF0000),
      )),
      size: Vector2(100, 10),
      text: dmg.toString(),
      anchor: Anchor.topCenter,
      priority: 1,
    );

    final moveEffect = MoveEffect.to(
      Vector2(position.x, position.y - 15), // New position
      EffectController(duration: 0.3),
      onComplete: () {
        textComp.removeFromParent();
      },
    );
    if (parent != null) {
      parent!.add(
        textComp..addAll([moveEffect]),
      );
    }
  }
}
