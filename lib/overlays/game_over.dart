import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';

import '../flame_game/game.dart';

class GameOver extends StatelessWidget {
  static const id = 'GameOver';
  final DestroyerGame game;

  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withAlpha(100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const NesContainer(
              width: 400,
              // child: ElevatedButton(
              //   onPressed: () {
              //     final path = GoRouter.of(context).routeInformationProvider.value.uri.toString();
              //     context.pushReplacement(path);
              //   },
              //   child: const Text('Restart'),
              // ),
              child: Text(
                'You died, reset coin',
                style: TextStyle(),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('Exit'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
