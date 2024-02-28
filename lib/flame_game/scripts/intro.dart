import 'dart:async';

import 'package:destroyer/models/equipments.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nes_ui/nes_ui.dart';

import '../../level_selection/level.dart';
import '../components/equipment.dart';
import '../components/equipments/weapon.dart';
import '../game.dart';
import '../game_world.dart';

class IntroScript extends Component
    with HasGameRef<DestroyerGame>, HasWorldReference<DestroyerGameWorld>, ParentIsA<SceneComponent> {
  final textBoxConfig = TextBoxConfig(
    timePerChar: 0.05, // Time in seconds to wait before showing the next character
    // Other configurations for your text box...
  );

  late Timer _timer;
  int _seconds = 0;
  late TextBoxComponent firstDialog;
  int _afterClosedFirstDialogSecond = -1;

  @override
  FutureOr<void> onLoad() {
    firstDialog = TextBoxComponent(
      text: 'This place is', // The text you want to display
      boxConfig: textBoxConfig,
      anchor: Anchor.bottomLeft,
    );
    _timer = Timer(1, onTick: () {
      _seconds++;
      if (_seconds == 3) {
        showPlayerFirstDialog();
      }
      if (_afterClosedFirstDialogSecond >= 0) {
        _afterClosedFirstDialogSecond++;
      }
      if (_afterClosedFirstDialogSecond == 3) {}
    });
  }

  void showPlayerFirstDialog() {
    firstDialog.position = game.playerData.position.value;
    parent.add(firstDialog);

    // Start the timer to next action
    _afterClosedFirstDialogSecond = 0;
  }

  void onBossKilled(PositionComponent boss) {
    final newSword = Sword.purifier(1);
    final swordImage = game.images.fromCache(newSword.iconAsset);
    final sword = SwordComponent(
      item: newSword,
      position: Vector2(boss.position.x, boss.position.y - 100),
      size: Vector2.all(24),
      sprite: Sprite(swordImage),
    );
    parent.add(sword);
    sword.add(MoveByEffect(Vector2(0, 180), CurvedEffectController(1.0, Curves.easeInOut)));
  }

  void onRewardPicked(EquipmentComponent equipment) {
    final newEquipments = game.getEquipments();
    newEquipments.removeWhere((item) => item is Sword && item.type == SwordType.desolator);
    game.setEquipments(newEquipments);
    world.finishedLevel();
    add(TimerComponent(
      period: 1, // The period in seconds
      onTick: () {
        game.overlays.add(PurifySwordPickedDialog.id);
      },
    ));
  }

  // void _showDialog(String s) {
  //   final dialog = TextBoxComponent(
  //     text: s,
  //     boxConfig: textBoxConfig,
  //     position: Vector2(100, 100),
  //   );
  //   parent.add(dialog);
  // }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
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
