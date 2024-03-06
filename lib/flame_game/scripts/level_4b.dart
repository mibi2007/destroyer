import 'dart:async';

import 'package:destroyer/flame_game/components/door.dart';
import 'package:destroyer/flame_game/scripts/script.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nes_ui/nes_ui.dart';

import '../../models/enemies.dart';
import '../../models/equipments.dart';
import '../components/equipments/weapon.dart';
import '../entities/boss.entity.dart';
import '../game.dart';

const _asset = 'assets/images/enemies/boss1.png';
final _srcSize = Vector2.all(128);

class Level4BScript extends Script {
  final textBoxConfig = TextBoxConfig(
    timePerChar: 0.05, // Time in seconds to wait before showing the next character
    // Other configurations for your text box...
  );

  Door? door;
  late final Timer _timer;
  // int seconds = 0;
  bool isShownDialog = false;

  @override
  Future<FutureOr<void>> onLoad() async {
    boss = BossEntity(
      boss: Boss(asset: _asset, level: 4, maxHealth: 1000, armor: 8),
      size: Vector2.all(128),
      position: Vector2.zero(),
      priority: 1,
    );
    boss!.boss
      ..moveAnimation = SpriteAnimation.spriteList(
          await Future.wait([
            Sprite.load(_asset, srcSize: _srcSize, srcPosition: Vector2(128 * 0, 0)),
            Sprite.load(_asset, srcSize: _srcSize, srcPosition: Vector2(128 * 1, 0)),
            Sprite.load(_asset, srcSize: _srcSize, srcPosition: Vector2(128 * 2, 0)),
            Sprite.load(_asset, srcSize: _srcSize, srcPosition: Vector2(128 * 3, 0)),
          ]),
          stepTime: 0.5)
      ..attackAnimation = SpriteAnimation.spriteList(
          await Future.wait([
            Sprite.load(_asset, srcSize: _srcSize, srcPosition: Vector2(128 * 0, 128)),
            Sprite.load(_asset, srcSize: _srcSize, srcPosition: Vector2(128 * 1, 128)),
            Sprite.load(_asset, srcSize: _srcSize, srcPosition: Vector2(128 * 2, 128)),
          ]),
          stepTime: 0.25);
    _timer = Timer(1, onTick: () {
      // seconds++;
      if (boss!.currentHealth <= boss!.maxHealth * 0.3) {
        for (int i = 0; i < 10; i++) {
          boss!.attack();
        }
      }
    }, repeat: true);
  }

  void onBossKilled(PositionComponent killedBoss) {
    if (door != null) parent.add(door!);
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  void reward() {
    final newSword = Sword.purifier(2);
    final swordImage = game.images.fromCache(newSword.iconAsset);
    final sword = SwordComponent(
      item: newSword,
      position: Vector2(boss!.position.x + 64, boss!.position.y - 150),
      size: Vector2.all(24),
      sprite: Sprite(swordImage),
    );
    final stone = SpriteComponent.fromImage(
      game.images.fromCache('assets/images/dark-shard.png'),
      srcSize: Vector2.all(50),
      size: Vector2.all(50),
      position: Vector2(boss!.position.x - 64, boss!.position.y),
    );
    parent.add(stone);
    stone.add(MoveByEffect(Vector2(0, -150), CurvedEffectController(1.0, Curves.easeInOut), onComplete: () {
      stone.add(RemoveEffect());
      parent.add(sword);
      sword.add(MoveByEffect(Vector2(0, 170), CurvedEffectController(1.0, Curves.easeInOut),
          onComplete: () => sword.add(MoveEffect.by(
                Vector2(0, -4),
                EffectController(
                  alternate: true,
                  infinite: true,
                  duration: 1,
                  curve: Curves.ease,
                ),
              ))));
    }));
  }

  @override
  void onRemove() {
    _timer.stop();
    super.onRemove();
  }
}

class LightningSwordPickedDialog extends StatelessWidget {
  static const id = 'LightningSwordPickedDialog';
  final DestroyerGame game;

  const LightningSwordPickedDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final sword = Sword.lightning(4);
    return NesDialog(
      child: SizedBox(
        width: 600,
        child: Column(
          children: [
            Text(
              'You have new sword!',
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
      ),
    );
  }
}
