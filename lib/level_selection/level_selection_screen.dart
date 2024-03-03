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
    final gap = MediaQuery.of(context).size.height < 500
        ? const SizedBox(height: 20, width: 20)
        : const SizedBox(height: 50, width: 50);
    final gap2 =
        MediaQuery.of(context).size.height < 500 ? const SizedBox(height: 10, width: 10) : const SizedBox(height: 30);
    const gapBig = SizedBox(width: 100);
    final contentWidth =
        MediaQuery.of(context).size.width * 0.8 > 600 ? 600.0 : MediaQuery.of(context).size.width * 0.8;

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
                    child: NesIcon(
                        iconData: NesIcons.questionMark,
                        size: MediaQuery.of(context).size.height < 500 ? const Size(14, 14) : null),
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
          gap2,
          Expanded(
            child: SizedBox(
              width: contentWidth,
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
                            gap,
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
          gap2,
          Flex(
            direction: MediaQuery.of(context).size.height < 500 ? Axis.horizontal : Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (MediaQuery.of(context).size.height < 500) ...[
                WobblyButton(
                  onPressed: () {
                    GoRouter.of(context).go('/');
                  },
                  child: const Text('Back'),
                ),
                gapBig,
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/coin.png', width: 40, height: 40, fit: BoxFit.contain),
                  Text(':${playerProgress.credits}', style: Theme.of(context).textTheme.bodyMedium),
                  MediaQuery.of(context).size.height < 500 ? gap : gapBig,
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
              if (MediaQuery.of(context).size.height > 500) ...[
                gap2,
                WobblyButton(
                  onPressed: () {
                    GoRouter.of(context).go('/');
                  },
                  child: const Text('Back'),
                ),
              ],
            ],
          ),
          gap2,
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
              equipments[index].iconAsset,
              filterQuality: FilterQuality.none,
              fit: BoxFit.contain,
            ),
            title: Text(
              equipments[index].name,
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
