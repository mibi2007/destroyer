import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../flame_game/game.dart';
import '../flame_game/game_world.dart';

class MainMenu extends StatelessWidget {
  static const id = 'MainMenu';
  final DestroyerGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  game.overlays.remove(id);
                  game.add(DestroyerGameWorld());
                },
                child: const Text('Play'),
              ),
            ),
            SizedBox(
              width: 100,
              child: ElevatedButton(
                onPressed: () {
                  context.go('settings');
                },
                child: const Text('Main'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
