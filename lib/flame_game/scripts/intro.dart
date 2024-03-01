import 'dart:async';

import 'package:destroyer/flame_game/entities/boss.entity.dart';
import 'package:destroyer/models/equipments.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nes_ui/nes_ui.dart';

import '../../models/enemies.dart';
import '../components/door.dart';
import '../components/equipment.dart';
import '../components/equipments/weapon.dart';
import '../game.dart';
import 'script.dart';

const _asset = 'assets/images/enemies/boss-intro.png';

class IntroScript extends Script {
  late final Door door;
  late final SpriteComponent oracle;
  late final Timer _timer;
  int _seconds = 0;
  // late TextBoxComponent firstDialog;
  bool isShownFirstBossDialog = false;
  bool isBossKilled = false;
  final List<TextBoxComponent> playerDialogs = [];
  final List<TextBoxComponent> bossDialogs = [];
  final List<TextBoxComponent> oracleDialogs = [];
  // @override
  // get boss => BossEntity(boss: Boss.intro(), size: Vector2(64, 64), position: Vector2(800, 100), priority: 1);

  @override
  Future<FutureOr<void>> onLoad() async {
    boss = BossEntity(
      isAutonomous: false,
      boss: Boss(asset: _asset, level: 1, maxHealth: 1000, armor: 5, damage: 30),
      size: Vector2.all(128),
      position: Vector2.zero(),
      priority: 1,
    );
    boss!.boss
      ..moveAnimation = SpriteAnimation.spriteList(
          await Future.wait([
            Sprite.load(_asset, srcSize: Vector2.all(128), srcPosition: Vector2(128 * 0, -20)),
          ]),
          stepTime: 5)
      ..attackAnimation = SpriteAnimation.spriteList(
          await Future.wait([
            Sprite.load(_asset, srcSize: Vector2.all(128), srcPosition: Vector2(128 * 0, -20)),
          ]),
          stepTime: 5);
    playerDialogs.addAll([
      TextBoxComponent(
        text: 'The world are breaking its balance',
        textRenderer: textRenderer,
        boxConfig: boxConfig,
        anchor: Anchor.bottomCenter,
      ),
      TextBoxComponent(
        text: 'I can see the force is very strong here!!!',
        textRenderer: textRenderer,
        boxConfig: boxConfig,
        anchor: Anchor.bottomCenter,
      ),
    ]);
    bossDialogs.addAll([
      TextBoxComponent(
        text: 'Well, Destroyer, not surprise. ToDay is the Day I Die...',
        textRenderer: textRenderer,
        boxConfig: boxConfig,
        anchor: Anchor.bottomCenter,
      ),
      TextBoxComponent(
        text: '...Ups, I mean you die!',
        textRenderer: textRenderer,
        boxConfig: boxConfig,
        anchor: Anchor.bottomCenter,
      ),
      TextBoxComponent(
        text: 'Aah, I die!, But you can not change anything! Ha Ha Ha...',
        textRenderer: textRenderer,
        boxConfig: boxConfig,
        anchor: Anchor.bottomCenter,
      ),
    ]);
    oracleDialogs.addAll([
      TextBoxComponent(
        text: 'The world broke its balance, that cause the Earth Stone explodes into Dark Shard.',
        textRenderer: textRenderer,
        boxConfig: boxConfig,
        anchor: Anchor.bottomCenter,
      ),
      TextBoxComponent(
        text: 'Human will be destroyed when these Dark Entity become stronger.',
        textRenderer: textRenderer,
        boxConfig: boxConfig,
        anchor: Anchor.bottomCenter,
      ),
      TextBoxComponent(
        text: 'You are the only one who can save humanity!!! What is your decision?',
        textRenderer: textRenderer,
        boxConfig: boxConfig,
        anchor: Anchor.bottomCenter,
      ),
    ]);
    _timer = Timer(1, onTick: () {
      _seconds++;
      if (_seconds == 1) {
        bossDialogs[0].position = boss!.position - Vector2(boss!.width / 3, -30);
        bossDialogs[1].position = boss!.position - Vector2(boss!.width / 3, -30);
        bossDialogs[2].position = boss!.position - Vector2(boss!.width / 3, -30);
      }
      // print(game.playerData.position.value);
      if (_seconds == 3) {
        playerDialogs[0].position = game.playerData.position.value - Vector2(0, 60);
        parent.add(playerDialogs[0]);
        add(TimerComponent(
          period: 3, // The period in seconds
          onTick: () {
            playerDialogs[0].removeFromParent();
            playerDialogs[1].position = game.playerData.position.value - Vector2(0, 60);
            if (!isShownFirstBossDialog) {
              parent.add(playerDialogs[1]);
              add(TimerComponent(
                period: 6, // The period in seconds
                onTick: () {
                  playerDialogs[1].removeFromParent();
                },
              ));
            }
          },
        ));
      }
      if (game.playerData.position.value.x > 860 && !isShownFirstBossDialog) {
        isShownFirstBossDialog = true;
        playerDialogs[0].removeFromParent();
        playerDialogs[1].removeFromParent();
        if (!isBossKilled) {
          parent.add(bossDialogs[0]);
          add(TimerComponent(
            period: 4, // The period in seconds
            onTick: () {
              bossDialogs[0].removeFromParent();
              if (!isBossKilled) {
                parent.add(bossDialogs[1]);
                add(TimerComponent(
                  period: 3, // The period in seconds
                  onTick: () {
                    bossDialogs[1].removeFromParent();
                  },
                ));
              }
            },
          ));
        }
      }
    }, repeat: true);
  }

  void onBossKilled(PositionComponent boss) {
    bossDialogs[0].removeFromParent();
    bossDialogs[1].removeFromParent();
    isBossKilled = true;
    parent.add(bossDialogs[2]);
    add(TimerComponent(
      period: 5, // The period in seconds
      onTick: () {
        bossDialogs[2].removeFromParent();
        worldShake();
        for (var dialog in oracleDialogs) {
          dialog.position = oracle.position + Vector2(0, -32);
        }
        // parent.player.position = Vector2(door.x + door.width, door.y);
        // game.remove(game.camera);
        // game.cameraMaxSpeed = Vector2.all(double.infinity);

        // world.customCamera.moveTo(player.position, speed: double.infinity);
        // Not allow to go back
        // player.animation.resetLast2Second();
        // game.camera.stop();
        // world.customCamera.follow(player, maxSpeed: kCameraSpeed, snap: true);
        parent.movePlayerToPosition(Vector2(door.x + door.width / 2, door.y));
        game.background.parallax!.baseVelocity.y = 5;
        // for (int i = 0; i < game.camera.backdrop.children.length; i++) {
        //   if (game.camera.backdrop.children.elementAt(i) is Background) {
        //     add(TimerComponent(
        //       period: i * 0.5, // The period in seconds
        //       onTick: () {
        //         game.camera.backdrop.children.elementAt(i).addAll([
        //           MoveEffect.by(Vector2(0, 1000), LinearEffectController(5)),
        //           // OpacityEffect.fadeOut(LinearEffectController(2))
        //         ]);
        //       },
        //     ));
        //   }
        // }
        add(TimerComponent(
          period: 2, // The period in seconds
          onTick: () {
            parent.add(oracle);
            parent.add(oracleDialogs[0]);
            add(TimerComponent(
              period: 5, // The period in seconds
              onTick: () {
                oracleDialogs[0].removeFromParent();
                parent.add(oracleDialogs[1]);
                add(TimerComponent(
                  period: 5, // The period in seconds
                  onTick: () {
                    oracleDialogs[1].removeFromParent();
                    parent.add(oracleDialogs[2]);
                    reward();
                  },
                ));
              },
            ));
          },
        ));
      },
    ));
  }

  void reward() {
    final newSword = Sword.purifier(1);
    final swordImage = game.images.fromCache(newSword.iconAsset);
    final sword = SwordComponent(
      item: newSword,
      position: Vector2(oracle.position.x + 64, oracle.position.y - 150),
      size: Vector2.all(24),
      sprite: Sprite(swordImage),
    );
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
  }

  void worldShake() {
    world.customCamera.viewport.add(MoveEffect.by(
      Vector2(10, 10),
      LinearEffectController(0.1),
      onComplete: () => world.customCamera.viewport.add(MoveEffect.by(
        Vector2(0, -20),
        LinearEffectController(0.1),
        onComplete: () => world.customCamera.viewport.add(MoveEffect.by(
          Vector2(-20, 0),
          LinearEffectController(0.1),
          onComplete: () => world.customCamera.viewport.add(MoveEffect.by(
            Vector2(0, 20),
            LinearEffectController(0.2),
            onComplete: () =>
                world.customCamera.viewport.add(MoveEffect.by(Vector2(-10, 10), LinearEffectController(1))),
          )),
        )),
      )),
    ));
  }

  void onRewardPicked(EquipmentComponent equipment) {
    final newEquipments = game.getEquipments();
    newEquipments.removeWhere((item) => item is Sword && item.type == SwordType.desolator);
    game.setEquipments(newEquipments);
    world.nextLevel();
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
      child: SizedBox(
        width: 600,
        child: Column(
          children: [
            Text(
              'Exchange Desolator lv5 with a new sword!',
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
