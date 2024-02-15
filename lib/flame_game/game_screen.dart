import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';

import '../audio/audio_controller.dart';
import '../level_selection/levels.dart';
import 'game.dart';
import 'game_win_dialog.dart';

final GlobalKey<RiverpodAwareGameWidgetState<DestroyerGame>> gameWidgetKey =
    GlobalKey<RiverpodAwareGameWidgetState<DestroyerGame>>();
// A single instance to avoid creation of
// multiple instances in every build.
// final _game = DestroyerGame();

/// This widget defines the properties of the game screen.
///
/// It mostly sets up the overlays (widgets shown on top of the Flame game) and
/// the gets the [AudioController] from the context and passes it in to the
/// [DestroyerGame] class so that it can play audio.
class GameScreen extends StatelessWidget {
  const GameScreen({required this.level, super.key});

  final GameLevel level;

  static const String winDialogKey = 'win_dialog';
  static const String backButtonKey = 'back_buttton';

  @override
  Widget build(BuildContext context) {
    final myGame = DestroyerGame(level);
    myGame.context = context;
    double width;
    double height;
    if ((MediaQuery.of(context).size.width / 640 * 454) > MediaQuery.of(context).size.height) {
      height = MediaQuery.of(context).size.height;
      width = height * 640 / 454;
    } else {
      width = MediaQuery.of(context).size.width;
      height = width * 454 / 640;
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: RiverpodAwareGameWidget<DestroyerGame>(
              key: gameWidgetKey,
              game: myGame,
              overlayBuilderMap: {
                backButtonKey: (BuildContext context, DestroyerGame game) {
                  return Positioned(
                    top: 20,
                    right: 10,
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
              },
            ),
          ),
        ),
      ),
    );
  }
}
