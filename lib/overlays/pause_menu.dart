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
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  // AudioManager.resumeBgm();
                  game.overlays.remove(id);
                  game.resumeEngine();
                },
                child: const Text('Resume'),
              ),
            ),
            const SizedBox(height: 30),
            // SizedBox(
            //   width: 200,
            //   child: ElevatedButton(
            //     onPressed: () {
            //       game.overlays.remove(id);
            //       game.overlays.add(Config.id);
            //     },
            //     child: const Text('Exit'),
            //   ),
            // ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
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
