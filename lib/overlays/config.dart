import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../flame_game/game.dart';
import '../settings/settings.dart';

class Config extends StatelessWidget {
  static const id = 'Config';
  final DestroyerGame game;

  const Config({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: ValueListenableBuilder<bool>(
                valueListenable: settings.gamepadOn,
                builder: (context, gamepadOn, child) => SwitchListTile(
                  title: const Text('Enable Gamepad for mobile devices'),
                  value: gamepadOn,
                  onChanged: (value) => settings.toggleGamepadOn(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
