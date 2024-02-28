import 'dart:async';

import 'package:destroyer/flame_game/components/door.dart';
import 'package:flame/components.dart';

import '../../level_selection/level.dart';
import '../game.dart';
import '../game_world.dart';

class Level1AScript extends Component
    with HasGameRef<DestroyerGame>, HasWorldReference<DestroyerGameWorld>, ParentIsA<SceneComponent> {
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
      if (game.playerData.garbages.value == 13) {
        parent.add(door);
      }
    });
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
