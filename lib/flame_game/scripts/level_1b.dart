import 'dart:async';

import 'package:destroyer/flame_game/components/door.dart';
import 'package:destroyer/flame_game/scripts/script.dart';
import 'package:flame/components.dart';

class Level1BScript extends Script {
  final textBoxConfig = TextBoxConfig(
    timePerChar: 0.05, // Time in seconds to wait before showing the next character
    // Other configurations for your text box...
  );

  late final Door door;
  late final Timer _timer;
  // int seconds = 0;
  bool isShownDialog = false;

  @override
  FutureOr<void> onLoad() {
    // game.overlays.add(PurifySwordPicked.id);
    _timer = Timer(1, onTick: () {
      // seconds++;
      if (game.playerData.garbages.value == 1 && !isShownDialog) {
        isShownDialog = true;
        parent.add(showFirstDialog());
      }
      if (boss.currentHealth <= boss.maxHealth * 0.3) {
        for (int i = 0; i < 10; i++) {
          boss.attack();
        }
      }
      if (boss.currentHealth <= 0) {
        parent.add(door);
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
}
