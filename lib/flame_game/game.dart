import 'dart:ui';

import 'package:destroyer/flame_game/entities/enemy.entity.dart';
import 'package:destroyer/level_selection/levels.dart';
import 'package:destroyer/models/equipments.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/player_data/player_data.dart';
import '../player_progress/player_progress.dart';
import '../utils/disabler.dart';
import 'components/background.dart';
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
    with
        HasCollisionDetection,
        HasKeyboardHandlerComponents,
        MouseMovementDetector,
        LongPressDetector,
        RiverpodGameMixin {
  /// What the properties of the level that is played has.

  /// A helper for playing sound effects and background audio.

  /// In the [onLoad] method you load different type of assets and set things
  /// that only needs to be set once when the level starts up.

  final GameLevel level;
  final int sceneIndex;
  final Size screenSize;
  late BuildContext context;
  late bool isTesting;
  late final double zoom;
  late final bool isMobile;

  DestroyerGame(this.level, this.sceneIndex, {required this.screenSize, this.isTesting = false}) {
    images.prefix = '';
    // print(screenSize.height);
    // print(fixedResolution.x);
    fixedResolution = screenSize.height < 500
        ? Vector2(screenSize.width, screenSize.height) * 0.94
        : Vector2(screenSize.width, screenSize.height) * 0.57;
    isMobile = screenSize.height < 500;
  }
  late Image spriteSheet;

  final playerData = PlayerData();
  // final ratio = 454 / 640;
  // final fixedResolution = Vector2(640, 330 + 240 * 330 / 640);
  late final Vector2 fixedResolution;
  double _timer = 0;
  late Background background;
  // late TiledComponent mapTiled;

  Vector2 cameraSpeed = Vector2.zero();
  Vector2 cameraMaxSpeed = Vector2.all(200);

  @override
  void onMouseMove(PointerHoverInfo info) {
    // if (_timer > 0.045 && isMounted) {
    if (isMounted) {
      // _timer = 0;

      // Fix bug where the mouse position is not correct with different screen sizes and resolutions
      double x = info.eventPosition.global.x;
      double y = info.eventPosition.global.y;
      if (fixedResolution.x > size.x) {
        x = x - (fixedResolution.x - size.x) / 2;
      } else if (fixedResolution.y > size.y) {
        y = y - (fixedResolution.y - size.y) / 2;
      }
      playerData.currentMousePosition.value = Vector2(x, y);
    }
  }

  @override
  void onLongPressEnd(LongPressEndInfo info) {
    playerData.autoAttack.value = true;
  }

  void leftClickHandler() {
    playerData.selectedLocation.value = null;
    playerData.selectedTarget.value = null;
  }

  void rightClickHandler() {
    final clickPosition = playerData.currentMousePosition.value;
    playerData.selectedLocation.value = clickPosition;
    final enemyList =
        componentsAtPoint(clickPosition).where((com) => (com is EnemyEntity) || com is EnemyAnimationEntity).toList();
    // [
    //   ...componentsAtPoint(clickPosition).whereType<EnemyEntity>(),
    //   ...componentsAtPoint(clickPosition).whereType<EnemyAnimationEntity>()
    // ];
    if (enemyList.isNotEmpty) {
      playerData.selectedTarget.value = enemyList.first as PositionComponent;
      print(objectRuntimeType(playerData.selectedTarget.value, 'selectedTarget'));
    }
  }

  @override
  Future<void> onLoad() async {
    zoom = (fixedResolution.x / 640 * 454) < fixedResolution.y
        ? fixedResolution.x / fixedResolution.x
        : fixedResolution.y / fixedResolution.y;
    // mapTiled = await TiledComponent.load(
    //   level.mapTiled,
    //   Vector2.all(32),
    // );

    // The backdrop is a static layer behind the world that the camera is
    // looking at, so here we add our parallax background.
    background = Background(level, sceneIndex);
    // if (level == GameLevel.lv2) {
    //   background.position = Vector2(background.position.x, background.position.y - 150);
    // }
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
    spriteSheet = await images.load('assets/tiles/Spritesheet.png');
    await images.load('assets/images/hud/hud.png');
    await images.load('assets/images/hud/avatar-frame.png');
    await images.load('assets/images/hud/attack-button.png');
    await images.load('assets/images/hud/jump-button.png');
    await images.load('assets/images/hud/pad.png');

    // Characters
    await images.load('assets/images/npcs/oracle.png');

    // Swords
    await images.load('assets/images/equipments/swords/desolator-sprite.png');
    await images.load('assets/images/equipments/swords/purifier-sprite.png');
    await images.load('assets/images/equipments/swords/time-sprite.png');
    await images.load('assets/images/equipments/swords/flame-sprite.png');
    await images.load('assets/images/equipments/swords/lightning-sprite.png');
    await images.load('assets/images/equipments/swords/fireball.png');

    // Armors
    await images.load('assets/images/equipments/armors/Helmet.webp');
    await images.load('assets/images/equipments/armors/Chestpiece.webp');
    await images.load('assets/images/equipments/armors/Gauntlets.webp');
    await images.load('assets/images/equipments/armors/Leggings.webp');
    await images.load('assets/images/equipments/armors/Boots.webp');

    // Skills and effects
    await images.load('assets/images/skills-and-effects/skill-frame.png');
    await images.load('assets/images/skills-and-effects/boom.png');
    await images.load('assets/images/skills-and-effects/Repel_icon.webp');
    await images.load('assets/images/skills-and-effects/Guardian_Angel_icon.webp');
    await images.load('assets/images/skills-and-effects/Time_Walk_icon.webp');
    await images.load('assets/images/skills-and-effects/Chronosphere_icon.webp');
    await images.load('assets/images/skills-and-effects/Fireblast_icon.webp');
    await images.load('assets/images/skills-and-effects/Flame_Cloak_icon.webp');
    await images.load('assets/images/skills-and-effects/Requiem_of_Souls_icon.webp');
    await images.load('assets/images/skills-and-effects/Ball_Lightning_icon.webp');
    await images.load('assets/images/skills-and-effects/Thunder_Strike_icon.webp');
    await images.load('assets/images/skills-and-effects/Cold_Feet_icon.webp');
    await images.load('assets/images/skills-and-effects/Spell_Immunity_icon.webp');
    await images.load('assets/images/skills-and-effects/Requiem_of_Souls_effect.png');
    await images.load('assets/images/skills-and-effects/Chronosphere_effect.png');
    await images.load('assets/images/skills-and-effects/night.png');
    await images.load('assets/images/skills-and-effects/electrict.png');
    await images.load('assets/images/skills-and-effects/purifier.png');

    // Negative effects
    await images.load('assets/images/skills-and-effects/Kinetic_Field_icon.webp');

    // Other images
    await images.load('assets/images/hand-hold-dark-shard.png');
    await images.load('assets/images/enemies/boss1.png');
    await images.load('assets/images/enemies/garbage1.png');
    await images.load('assets/images/enemies/garbage2.png');
    await images.load('assets/images/enemies/boss-intro.png');
    await images.load('assets/images/enemies/garbage_monster.png');
    await images.load('assets/images/hand-hold-dark-shard.png');
    await images.load('assets/images/dark-shard.png');
    await images.load('assets/animations/slash.png');
    await images.load('assets/animations/electric.png');
    await images.load('assets/animations/flame.png');
    await images.load('assets/tiles/Spritesheet.png');

    add(FpsTextComponent());

    add(DestroyerGameWorld());
  }

  @override
  void update(double dt) {
    super.update(dt);
    // _timer += dt;

    // camera.
  }

  void navigate(String path) {
    print('Navigating to $path');
    context.go(path + (isTesting ? '?test=true' : ''));
  }

  setLevelFinished(int level, int time) {
    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setLevelFinished(level, time);
  }

  setCredits(int newCredits) {
    final playerProgress = context.read<PlayerProgress>();
    playerProgress.setCredits(newCredits);
    // Notify the playerData that the credits have changed
    playerData.credits.change();
  }

  int getCredits() {
    final playerProgress = context.read<PlayerProgress>();
    return playerProgress.credits;
  }

  setEquipments(List<Equipment> newEquipments) {
    final playerProgress = context.read<PlayerProgress>();
    final success = playerProgress.setEquipments(newEquipments);
    // Notify the playerData that the credits have changed
    if (success) playerData.equipments.change();
  }

  addEquipment(Equipment equipment) {
    final playerProgress = context.read<PlayerProgress>();
    final success = playerProgress.addEquipment(equipment);
    // Notify the playerData that the credits have changed
    if (success) playerData.equipments.change();
  }

  List<Equipment> getEquipments() {
    final playerProgress = context.read<PlayerProgress>();
    return playerProgress.getEquipments();
  }

  @override
  void onRemove() {
    rightClick.removeListener(rightClickHandler);
    leftClick.removeListener(leftClickHandler);
    super.onRemove();
  }
}
