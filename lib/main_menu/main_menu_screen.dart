import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../settings/settings.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';
import '../style/wobbly_button.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settingsController = context.watch<SettingsController>();
    final audioController = context.watch<AudioController>();

    return Scaffold(
      backgroundColor: palette.backgroundMain.color,
      body: ResponsiveScreen(
        squarishMainArea: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Destroyer',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Press Start 2P',
                    fontSize: MediaQuery.of(context).size.height < 500 ? 24 : 32,
                    height: 1,
                    color: Colors.black),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.height * 0.6,
                height: MediaQuery.of(context).size.height * 0.6,
                child: RiveAnimation.asset(
                  'assets/animations/character.riv',
                  fit: BoxFit.cover,
                  placeHolder: Center(child: CircularProgressIndicator()),
                ),
              ),
              Transform.rotate(
                angle: -0.1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Text(
                    'A Flutter Game.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Press Start 2P',
                      fontSize: MediaQuery.of(context).size.height < 500 ? 24 : 32,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        rectangularMenuArea: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WobblyButton(
              onPressed: () {
                audioController.playSfx(SfxType.buttonTap);
                GoRouter.of(context).go('/play');
              },
              child: const Text('Play'),
            ),
            _gap,
            WobblyButton(
              onPressed: () => GoRouter.of(context).push('/settings'),
              child: const Text('Settings'),
            ),
            _gap,
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: ValueListenableBuilder<bool>(
                valueListenable: settingsController.audioOn,
                builder: (context, audioOn, child) {
                  return IconButton(
                    onPressed: () => settingsController.toggleAudioOn(),
                    icon: Icon(audioOn ? Icons.volume_up : Icons.volume_off),
                  );
                },
              ),
            ),
            _gap,
            const Text('Built with Flame'),
            const Text('and Rive'),
          ],
        ),
      ),
    );
  }

  static const _gap = SizedBox(height: 10);
}
