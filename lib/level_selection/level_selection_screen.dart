import 'package:destroyer/level_selection/instructions_dialog.dart';
import 'package:destroyer/models/equipments.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../player_progress/player_progress.dart';
import '../style/palette.dart';
import '../style/wobbly_button.dart';
import 'levels.dart';

class LevelSelectionScreen extends StatelessWidget {
  final bool isTesting;
  const LevelSelectionScreen({super.key, this.isTesting = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final playerProgress = context.watch<PlayerProgress>();
    final levelTextStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);

    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection.color,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select level',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 16),
                  NesButton(
                    type: NesButtonType.normal,
                    child: NesIcon(iconData: NesIcons.questionMark),
                    onPressed: () {
                      NesDialog.show(
                        context: context,
                        builder: (_) => const InstructionsDialog(),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: SizedBox(
              width: 600,
              child: ListView(
                children: [
                  for (final level in gameLevels)
                    ListTile(
                      enabled: playerProgress.levels.length >= level.number - 1 || isTesting,
                      onTap: () {
                        final audioController = context.read<AudioController>();
                        audioController.playSfx(SfxType.buttonTap);

                        GoRouter.of(context).go('/play/session/${level.number}/0${isTesting ? '?test=true' : ''}');
                      },
                      leading: Text(
                        level.number.toString(),
                        style: levelTextStyle,
                      ),
                      title: Row(
                        children: [
                          Text(
                            level.title,
                            style: levelTextStyle,
                          ),
                          if (playerProgress.levels.length < level.number - 1 && !isTesting) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.lock, size: 20),
                          ] else if (playerProgress.levels.length >= level.number) ...[
                            const SizedBox(width: 50),
                            Text(
                              '${playerProgress.levels[level.number - 1]}s',
                              style: levelTextStyle,
                            ),
                          ],
                        ],
                      ),
                    )
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Credits: ${playerProgress.credits}', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 16),
              WobblyButton(
                onPressed: () {
                  NesDialog.show(
                    context: context,
                    builder: (_) => EquipmentPickedDialog(
                      equipments: playerProgress.getEquipments(),
                    ),
                  );
                },
                child: const Text('Equipments'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          WobblyButton(
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            child: const Text('Back'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class EquipmentPickedDialog extends StatelessWidget {
  final List<Equipment> equipments;

  const EquipmentPickedDialog({super.key, required this.equipments});

  @override
  Widget build(BuildContext context) {
    if (equipments.isEmpty) {
      return const Text('Start game to get equipments!');
    }
    return SizedBox(
      height: 300,
      width: 400,
      child: ListView.builder(
        itemCount: equipments.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.asset(
              'images/${equipments[index].iconAsset}',
              filterQuality: FilterQuality.none,
              fit: BoxFit.contain,
            ),
            title: Text(
              equipments[index].name,
              style: TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
