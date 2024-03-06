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
import '../../utils/utils.dart';
import '../components/equipments/weapon.dart';
import '../entities/boss.entity.dart';
import '../game.dart';

const _asset = 'assets/images/enemies/boss1.png';
final _srcSize = Vector2.all(128);

class Level6Script extends Script {
  final textBoxConfig = TextBoxConfig(
    timePerChar: 0.05, // Time in seconds to wait before showing the next character
    // Other configurations for your text box...
  );

  Door? door;
  late final Timer _timer;
  int seconds = 0;
  bool isShownDialog = false;
  late final Garbage garbage;
  final List<Vector2> mountain = [
    Vector2.zero(),
    Vector2(-32, 32),
    Vector2(0, 32),
    Vector2(32, 32),
    Vector2(-64, 64),
    Vector2(-32, 64),
    Vector2(0, 64),
    Vector2(32, 64),
    Vector2(64, 64),
    Vector2(-96, 96),
    Vector2(-64, 96),
    Vector2(-32, 96),
    Vector2(0, 96),
    Vector2(32, 96),
    Vector2(64, 96),
    Vector2(96, 96),
  ];

  @override
  Future<FutureOr<void>> onLoad() async {
    garbage = Garbage(
      level: game.level.number,
      asset: rnd.nextDouble() * 2 < 1 ? 'assets/images/enemies/garbage1.png' : 'assets/images/enemies/garbage2.png',
      maxHealth: 100,
      armor: game.level.number * 5,
      damage: 10 + game.level.number * 5,
    );
    boss = BossEntity(
      boss: Boss(asset: _asset, level: 5, maxHealth: 5000, armor: 10),
      size: Vector2.all(128),
      position: Vector2.zero(),
      priority: 1,
    );
    // print(boss!.garbageBullet);
    boss!.currentHealth = boss!.maxHealth * 0.31;
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
      seconds++;
      if (seconds == 1) {
        // garbageMountain = PositionComponent(
        //   position: boss!.position - Vector2(0, 1000),
        // );
        // garbageMountain.add(boss!.garbageBullet);
        // garbageMountain.addAll([
        //   boss!.garbageBullet..position = Vector2(-32, 32),
        //   boss!.garbageBullet..position = Vector2(0, 32),
        //   boss!.garbageBullet..position = Vector2(32, 32),
        // ]);
        // garbageMountain.addAll([
        //   boss!.garbageBullet..position = Vector2(-64, 64),
        //   boss!.garbageBullet..position = Vector2(-32, 64),
        //   boss!.garbageBullet..position = Vector2(0, 64),
        //   boss!.garbageBullet..position = Vector2(32, 64),
        //   boss!.garbageBullet..position = Vector2(64, 64),
        // ]);
      }
      if (boss!.currentHealth < boss!.maxHealth * 0.3 && seconds % 10 == 0) {
        dropCursedGarbage();
      }
    }, repeat: true);
  }

  TextBoxComponent showFirstDialog() {
    return TextBoxComponent(
      text: 'Your text here', // The text you want to display
      boxConfig: textBoxConfig,
      // Other properties for your text box...
    );
  }

  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  void onBossKilled(PositionComponent killedBoss) {
    if (door != null) parent.add(door!);
  }

  void reward() {
    final newSword = Sword.lightning(4);
    final swordImage = game.images.fromCache(newSword.iconAsset);
    final sword = SwordComponent(
      item: newSword,
      position: Vector2(boss!.position.x + boss!.width / 2, boss!.position.y - 100),
      size: Vector2.all(24),
      sprite: Sprite(swordImage),
    );
    final stone = SpriteComponent.fromImage(
      game.images.fromCache('assets/images/dark-shard.png'),
      srcSize: Vector2.all(50),
      size: Vector2.all(50),
      position: Vector2(boss!.position.x + boss!.width / 2 - 25, boss!.position.y),
    );
    parent.add(stone);
    stone.add(MoveByEffect(Vector2(0, -100), CurvedEffectController(1.0, Curves.easeInOut), onComplete: () {
      stone.add(RemoveEffect());
      parent.add(sword);
      sword.add(MoveByEffect(Vector2(0, 215), CurvedEffectController(1.0, Curves.easeInOut),
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

  void dropCursedGarbage() {
    boss!.currentHealth += boss!.maxHealth * 0.3;
    boss!.updateHealthBar(boss!.currentHealth);
    // garbageMountain = PositionComponent(
    //   position: boss!.position - Vector2(0, 1000),
    // );
    for (final pos in mountain) {
      final newBullet = boss!.garbageBullet.cloneCursed(
          garbage.clone(
              rnd.nextDouble() * 2 < 1 ? 'assets/images/enemies/garbage1.png' : 'assets/images/enemies/garbage2.png'),
          boss!.position + pos + Vector2(-boss!.width / 2, -1000));
      parent.add(newBullet);
      newBullet.curse();
      newBullet.add(MoveEffect.by(Vector2(0, 1000), LinearEffectController(1)));
    }
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
