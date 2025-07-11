import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';

import '../../level_selection/level.dart';
import '../entities/boss.entity.dart';
import '../game.dart';
import '../game_world.dart';

class Script extends Component
    with
        HasGameReference<DestroyerGame>,
        HasWorldReference<DestroyerGameWorld>,
        ParentIsA<SceneComponent> {
  BossEntity? boss;
  final boxConfig = TextBoxConfig(
    timePerChar:
        0.05, // Time in seconds to wait before showing the next character
    maxWidth: 200,
    // growingBox: true,
  );
  final textRenderer = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 12,
      fontFamily: 'Press Start 2P',
      height: 1.5,
      backgroundColor: Color(0xCC000000),
    ),
  );
}
