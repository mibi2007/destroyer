import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';

import '../audio/audio_controller.dart';
import '../level_selection/levels.dart';
import '../overlays/game_over.dart';
import '../overlays/pause_menu.dart';
import '../utils/disabler.dart';
import 'game.dart';
import 'game_win_dialog.dart';
import 'scripts/intro.dart';
import 'scripts/level_1b.dart';
import 'scripts/level_4b.dart';

// A single instance to avoid creation of
// multiple instances in every build.
// final _game = DestroyerGame();

/// This widget defines the properties of the game screen.
///
/// It mostly sets up the overlays (widgets shown on top of the Flame game) and
/// the gets the [AudioController] from the context and passes it in to the
/// [DestroyerGame] class so that it can play audio.
class GameScreen extends StatelessWidget {
  final int sceneIndex;
  final bool isTesting;
  const GameScreen({required this.level, this.sceneIndex = 0, this.isTesting = false, super.key});

  final GameLevel level;

  static const String winDialogKey = 'win_dialog';
  static const String backButtonKey = 'back_buttton';

  @override
  Widget build(BuildContext context) {
    final myGame = DestroyerGame(level, sceneIndex, screenSize: MediaQuery.of(context).size);
    myGame.context = context;
    // if (isTesting) {
    myGame.isTesting = true;
    // }
    // double width;
    // double height;
    // if ((MediaQuery.of(context).size.width / 640 * 454) > MediaQuery.of(context).size.height) {
    //   height = MediaQuery.of(context).size.height;
    //   width = height * 640 / 454;
    // } else {
    //   width = MediaQuery.of(context).size.width;
    //   height = width * 454 / 640;
    // }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Listener(        onPointerDown: MediaQuery.of(context).size.height < 500
            ? null
            : (PointerDownEvent event) {
                if (event.kind == PointerDeviceKind.mouse) {
                  if (event.buttons == kPrimaryMouseButton) {
                    leftClick.update();
                  } else if (event.buttons == kSecondaryMouseButton) {
                    rightClick.update();
                  }
                }
              },
            child: GameWidget<DestroyerGame>(
              game: myGame,
              overlayBuilderMap: {
                backButtonKey: (BuildContext context, DestroyerGame game) {
                  return Positioned(
                    top: 00,
                    right: 0,
                    child: NesButton(
                      type: NesButtonType.normal,
                      onPressed: GoRouter.of(context).pop,
                      child: NesIcon(iconData: NesIcons.leftArrowIndicator),
                    ),
                  );
                },
                winDialogKey: (BuildContext context, DestroyerGame game) {
                  return GameWinDialog(
                    level: level,
                  );
                },
                PurifySwordPickedDialog.id: (context, game) => PurifySwordPickedDialog(game: game),
                PurifySword2PickedDialog.id: (context, game) => PurifySword2PickedDialog(game: game),
                LightningSwordPickedDialog.id: (context, game) => LightningSwordPickedDialog(game: game),
                GameOver.id: (context, game) => GameOver(game: game),
                PauseMenu.id: (context, game) => PauseMenu(game: game),
              },
            ),
          ),
        ),
      ),
    );
  }
}
