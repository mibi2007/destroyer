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
                valueListenable: settings.quickCastOn,
                builder: (context, quickCastOn, child) => SwitchListTile(
                  title: const Text('On switching weapons, quick cast the autocast spell if available'),
                  value: quickCastOn,
                  onChanged: (value) => settings.toggleQuickCastOn(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
