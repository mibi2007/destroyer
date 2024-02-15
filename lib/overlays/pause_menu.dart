import 'package:destroyer/overlays/config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../flame_game/game.dart';

class PauseMenu extends StatelessWidget {
  static const id = 'PauseMenu';
  final DestroyerGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  // AudioManager.resumeBgm();
                  game.overlays.remove(id);
                  game.resumeEngine();
                },
                child: const Text('Resume'),
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  game.overlays.remove(id);
                  game.overlays.add(Config.id);
                },
                child: const Text('Exit'),
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  game.overlays.remove(id);
                  game.resumeEngine();
                  game.removeAll(game.children);
                  context.go('/');
                },
                child: const Text('Exit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
