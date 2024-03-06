import 'dart:async';

import 'package:destroyer/flame_game/components/door.dart';
import 'package:destroyer/flame_game/entities/garbage.entity.dart';
import 'package:destroyer/flame_game/entities/garbage_monster.entity.dart';
import 'package:destroyer/flame_game/scripts/script.dart';
import 'package:flame/components.dart';

class Level1AScript extends Script {
  final textBoxConfig = TextBoxConfig(
    timePerChar: 0.05, // Time in seconds to wait before showing the next character
    // Other configurations for your text box...
  );

  Door? door;
  late final Timer _timer;
  int seconds = 0;
  bool isShownDialog = false;
  bool isCursed = false;
  late final SpriteComponent handWithDarkShard;
  bool isGarbageToHead = false;
  final List<TextBoxComponent> playerDialogs = [];

  @override
  FutureOr<void> onLoad() {
    playerDialogs.addAll([
      TextBoxComponent(
        text: 'OMG, don\'t litter trash like this. It\'s hurt',
        textRenderer: textRenderer,
        boxConfig: boxConfig,
        anchor: Anchor.bottomCenter,
        priority: 2,
      ),
      TextBoxComponent(
        text: 'Burning Garbage is too dangerous',
        textRenderer: textRenderer,
        boxConfig: boxConfig,
        anchor: Anchor.bottomCenter,
        priority: 2,
      ),
    ]);
    handWithDarkShard = SpriteComponent.fromImage(
      game.images.fromCache('assets/images/hand-hold-dark-shard.png'),
      srcSize: Vector2(50, 50),
      // position: Vector2(game.fixedResolution.x / 2, parent.player.position.y),
      position: game.playerData.position.value,
      size: Vector2(32, 32),
    )..anchor = Anchor.bottomRight;
    // game.overlays.add(PurifySwordPicked.id);
    _timer = Timer(1, onTick: () {
      seconds++;
      if (seconds == 2) {
        // parent.add(handWithDarkShard);
      }
      if (game.playerData.garbages.value > 5 && !isCursed) {
        isCursed = true;
        parent.add(handWithDarkShard);
        parent.children.whereType<GarbageEntity>().forEach((garbage) {
          if (garbage.isMounted) garbage.curse();
        });
        add(TimerComponent(
          period: 3.5, // The period in seconds
          onTick: () {
            handWithDarkShard.removeFromParent();
            playerDialogs[0].removeFromParent();
            playerDialogs[1].position = game.playerData.position.value + Vector2(0, -50);
            parent.add(playerDialogs[1]);
          },
          removeOnFinish: true,
        ));
      }
      if (isCursed && parent.children.whereType<GarbageMonsterEntity>().isEmpty) {
        if (door != null) parent.add(door!);
      }
      if (!isGarbageToHead && game.playerData.health.value < 100) {
        isGarbageToHead = true;
        playerDialogs[0].position = game.playerData.position.value + Vector2(0, -50);
        parent.add(playerDialogs[0]);
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
    handWithDarkShard.position = game.playerData.position.value + Vector2(game.fixedResolution.x / 2 + 5, 0);
    _timer.update(dt);
    super.update(dt);
  }
}
