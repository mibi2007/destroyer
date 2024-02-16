import 'dart:ui';

import 'package:destroyer/level_selection/levels.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/player_data/player_data.dart';
import '../player_progress/player_progress.dart';
import '../utils/disabler.dart';
import 'components/background.dart';
import 'components/enemy.dart';
import 'game_world.dart';

/// This is the base of the game which is added to the [GameWidget].
///
/// This class defines a few different properties for the game:
///  - That it should run collision detection, this is done through the
///  [HasCollisionDetection] mixin.
///  - That it should have a [FixedResolutionViewport] with a size of 1600x720,
///  this means that even if you resize the window, the game itself will keep
///  the defined virtual resolution.
///  - That the default world that the camera is looking at should be the
///  [DestroyerGameWorld].
///
/// Note that both of the last are passed in to the super constructor, they
/// could also be set inside of `onLoad` for example.
class DestroyerGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents, MouseMovementDetector, TapCallbacks, RiverpodGameMixin {
  /// What the properties of the level that is played has.

  /// A helper for playing sound effects and background audio.

  /// In the [onLoad] method you load different type of assets and set things
  /// that only needs to be set once when the level starts up.

  final GameLevel level;
  final int sceneIndex;
  late BuildContext context;

  DestroyerGame(this.level, this.sceneIndex);
  late Image spriteSheet;

  final playerData = PlayerData();
  final ratio = 454 / 640;
  final fixedResolution = Vector2(640, 330 + 240 * 330 / 640);
  double _timer = 0;
  late Background background;
  // late TiledComponent mapTiled;

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (_timer > 0.045) {
      _timer = 0;
      // print(info.eventPosition.global);
      playerData.currentMousePosition.value = info.eventPosition.global;
    }
  }

  void leftClickHandler() {
    playerData.selectedLocation.value = null;
    playerData.selectedTarget.value = null;
  }

  void rightClickHandler() {
    final clickPosition = playerData.currentMousePosition.value;
    playerData.selectedLocation.value = clickPosition;
    final enemyList = componentsAtPoint(clickPosition).whereType<EnemySpriteComponent>().toList();
    if (enemyList.isNotEmpty) {
      playerData.selectedTarget.value = enemyList.first;
      // print(objectRuntimeType(playerData.selectedTarget.value, 'selectedTarget'));
    }
  }

  @override
  Future<void> onLoad() async {
    // mapTiled = await TiledComponent.load(
    //   level.mapTiled,
    //   Vector2.all(32),
    // );

    // The backdrop is a static layer behind the world that the camera is
    // looking at, so here we add our parallax background.
    background = Background();
    camera.backdrop.add(background);

    rightClick.addListener(rightClickHandler);
    leftClick.addListener(leftClickHandler);
    // playerData.selectedLocation.addListener(() {
    // final clickPosition = game.camera.globalToLocal(game.playerData.selectedLocation.value!);
    // });

    // Device setup
    await Flame.device.fullScreen();
    await Flame.device.setLandscape();

    // Loads all the audio assets
    // await AudioManager.init();
    spriteSheet = await images.load('Spritesheet.png');
    await images.load('hud/hud.png');
    await images.load('hud/avatar-frame.png');

    // Swords
    await images.load('equipments/swords/desolator-sprite.png');
    await images.load('equipments/swords/purifier-sprite.png');
    await images.load('equipments/swords/time-sprite.png');
    await images.load('equipments/swords/flame-sprite.png');
    await images.load('equipments/swords/lightning-sprite.png');
    await images.load('equipments/swords/fireball.png');
    await images.load('equipments/swords/slash-on-enemy.png');

    // Skills and effects
    await images.load('skills-and-effects/skill-frame.png');
    await images.load('skills-and-effects/boom.png');
    await images.load('skills-and-effects/Repel_icon.webp');
    await images.load('skills-and-effects/Guardian_Angel_icon.webp');
    await images.load('skills-and-effects/Time_Walk_icon.webp');
    await images.load('skills-and-effects/Chronosphere_icon.webp');
    await images.load('skills-and-effects/Fireblast_icon.webp');
    await images.load('skills-and-effects/Flame_Cloak_icon.webp');
    await images.load('skills-and-effects/Requiem_of_Souls_icon.webp');
    await images.load('skills-and-effects/Ball_Lightning_icon.webp');
    await images.load('skills-and-effects/Thunder_Strike_icon.webp');
    await images.load('skills-and-effects/Cold_Feet_icon.webp');
    await images.load('skills-and-effects/Spell_Immunity_icon.webp');

    // Negative effects
    await images.load('skills-and-effects/Kinetic_Field_icon.webp');
    add(FpsTextComponent());

    add(DestroyerGameWorld());
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
  }

  void navigate(String path) {
    print('Navigating to $path');
    context.go(path);
  }

  setLevelFinished(int level, int time) {
    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelFinished(level, time);
  }

  @override
  void onRemove() {
    rightClick.removeListener(rightClickHandler);
    leftClick.removeListener(leftClickHandler);
    super.onRemove();
  }
}
