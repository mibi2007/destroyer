import 'package:flutter/material.dart';

import '../flame_game/game.dart';

class Info extends StatelessWidget {
  static const id = 'Info';
  final DestroyerGame game;

  const Info({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: Column(
                children: [
                  const Text('Simple Platformer'),
                  const Text('by Luan Nico'),
                  const Text(''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
