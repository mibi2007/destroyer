import 'dart:async';

import 'package:destroyer/models/equipments.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nes_ui/nes_ui.dart';

import '../../level_selection/level.dart';
import '../components/enemy.dart';
import '../components/weapon.dart';
import '../game.dart';
import '../game_world.dart';

class IntroScript extends Component
    with HasGameRef<DestroyerGame>, HasWorldReference<DestroyerGameWorld>, ParentIsA<SceneComponent> {
  final textBoxConfig = TextBoxConfig(
    timePerChar: 0.05, // Time in seconds to wait before showing the next character
    // Other configurations for your text box...
  );

  @override
  FutureOr<void> onLoad() {
    // game.overlays.add(PurifySwordPicked.id);
  }

  TextBoxComponent showFirstDialog() {
    return TextBoxComponent(
      text: 'Your text here', // The text you want to display
      boxConfig: textBoxConfig,
      // Other properties for your text box...
    );
  }

  void onBossKilled(EnemySpriteComponent boss) {
    final newSword = Sword.purifier(1);
    final swordImage = game.images.fromCache(newSword.iconAsset);
    final sword = SwordComponent(
      item: newSword,
      position: Vector2(boss.position.x, boss.position.y - 100),
      size: Vector2.all(24),
      sprite: Sprite(swordImage),
    );
    parent.add(sword);
    sword.add(MoveByEffect(Vector2(0, 120), CurvedEffectController(1.0, Curves.easeInOut)));
  }

  void onRewardPicked(EquipmentComponent equipment) {
    world.finishedLevel();
    Future.delayed(const Duration(milliseconds: 1000), () {
      game.overlays.add(PurifySwordPickedDialog.id);
    });
  }

  // void _showDialog(String s) {
  //   final dialog = TextBoxComponent(
  //     text: s,
  //     boxConfig: textBoxConfig,
  //     position: Vector2(100, 100),
  //   );
  //   parent.add(dialog);
  // }
}

class EquipmentPickedDialog extends StatelessWidget {
  static const id = 'EquipmentPickedDialog';
  final DestroyerGame game;

  const EquipmentPickedDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return const NesDialog(
      child: Text('Picked'),
    );
  }
}

class PurifySwordPickedDialog extends StatelessWidget {
  static const id = 'PurifySwordPickedDialog';
  final DestroyerGame game;

  const PurifySwordPickedDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final sword = Sword.purifier(1);
    return NesDialog(
      child: Column(
        children: [
          Text(
            'You got new sword!',
            style: TextStyle(
              fontFamily: GoogleFonts.pressStart2p().fontFamily,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 20),
          Text('Purifier Sword', style: TextStyle(fontFamily: GoogleFonts.pressStart2p().fontFamily, fontSize: 20)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 7,
                child: Column(
                  children: [
                    Text(
                      'Level: ${sword.level}',
                    ),
                    Text(
                      'Damage: ${sword.damage}',
                    ),
                    Text(
                      'AttackSpeed: ${sword.attackSpeed}',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                flex: 3,
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset(
                    'assets/images/equipments/swords/purifier-sprite.png',
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
