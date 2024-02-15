import 'package:destroyer/utils/tileset.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';

import '../flame_game/components/coin.dart';
import '../flame_game/components/door.dart';
import '../flame_game/components/enemy.dart';
import '../flame_game/components/platform.dart';
import '../flame_game/components/player.dart';
import '../flame_game/game.dart';
import '../flame_game/game_world.dart';
import '../models/enemies.dart';
import '../utils/disabler.dart';
import 'levels.dart';

// Represents a level in game. Should only be added as child of DestroyerGameWorld
class SceneComponent extends Component
    with
        HasGameReference<DestroyerGame>,
        ParentIsA<DestroyerGameWorld>,
        TapCallbacks,
        KeyboardHandler,
        RiverpodComponentMixin {
  final GameLevel level;
  late PlayerComponent _player;
  late Artboard artboard;
  late TiledComponent mapTiled;
  int lastRightClickCount = 0;
  // double _timer = 0;
  TapDownEvent? lastTapDownEvent;
  GameLevel nextLevel = GameLevel.intro;

  int? sceneIndex;

  SceneComponent(this.level, {this.sceneIndex = 0});

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    print('Loading level: ${level.title}');

    artboard = await loadArtboard(RiveFile.asset('assets/animations/character.riv'));
    mapTiled = await TiledComponent.load(
      level.scenes[sceneIndex!].mapTiled,
      Vector2.all(32),
    );
    await add(mapTiled);

    await _spawnActors();
    leftClick.addListener(() {
      _player.animation.isAutoAttack = false;
      _player.animation.attack();
    });
    _setupCamera();
    _setupAllLevels();

    nextLevel = level.next();
  }

  void _setupAllLevels() {
    print('_setupAllLevels');
    game.playerData.skills.value = [];
    game.playerData.skillCountdown.value = [];
    game.playerData.effects.value = [];
    game.playerData.casting.value = null;
    game.playerData.skillCountdown.value = [];
    game.playerData.equipments.value = level.equipments;
    // if (level.mapTiled == 'Level1.tmx') {
    //   game.level.value = 1;
    //   game.playerData.equipments.value = [
    //     // Sword.desolator(1),
    //     Sword.purifier(4),
    //     Sword.time(4),
    //     Sword.flame(4),
    //     Sword.lightning(4),
    //   ];
    // } else if (level.mapTiled == 'Level2.tmx') {
    //   game.level.value = 2;
    //   game.playerData.equipments.value = [
    //     // Sword.desolator(),
    //     // Sword.purifier(4),
    //     Sword.flame(2),
    //   ];
    // }
    // add(SpriteComponent(
    //   sprite: Sprite(game.images.fromCache('skills-and-effects/Chronosphere_icon.webp'), srcSize: Vector2(500, 500)),
    //   position: Vector2(0, 0),
    //   size: Vector2(32, 32),
    // ));
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    _player.animation.isAutoAttack = true;
    _player.animation.onAttackDelay = true;
  }

  // Remove PointerMoveCallbacks because of the performance issue, use
  // MouseMovementDetector instead
  // @override
  // void onPointerMove(PointerMoveEvent event) {
  // if (_timer > 0.045) {
  // game.playerData.currentMousePosition.value = event.localPosition;
  // _timer = 0;
  // }
  // }

  // This method takes care of spawning
  // all the actors in the game world.
  Future<void> _spawnActors() async {
    final platformsLayer = mapTiled.tileMap.getLayer<ObjectGroup>('Platforms');
    final settings = mapTiled.tileMap.getLayer<ObjectGroup>('Settings');

    for (final platformObject in platformsLayer!.objects) {
      final platform = Platform(
        position: Vector2(platformObject.x, platformObject.y),
        size: Vector2(platformObject.width, platformObject.height),
      );
      await add(platform);
    }

    final spawnPointsLayer = mapTiled.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    for (final spawnPoint in spawnPointsLayer!.objects) {
      final position = Vector2(spawnPoint.x, spawnPoint.y - spawnPoint.height);
      final size = Vector2(spawnPoint.width, spawnPoint.height);

      switch (spawnPoint.class_) {
        case 'Player':
          // final halfSize = size * 0.5;
          // final levelBounds = Rect.fromLTWH(
          //   halfSize.x,
          //   halfSize.y,
          //   game.mapTiled.size.x - halfSize.x,
          //   game.mapTiled.size.y - halfSize.y,
          // );

          _player = PlayerComponent(
            artboard: artboard,
            position: position,
            size: size,
          );

          // _player.add(BoundedPositionBehavior(
          //   bounds: Rectangle.fromRect(levelBounds),
          // ));

          //}
          // _player = PlayerAnimationComponent(
          //   artboard,
          //   anchor: Anchor.center,
          //   position: position,
          //   size: size,
          //   // children: [
          //   //   BoundedPositionBehavior(
          //   //     bounds: Rectangle.fromRect(levelBounds),
          //   //   ),
          //   // ],
          // );
          Future.delayed(const Duration(milliseconds: 500)).then((_) async {
            add(_player);
          });
          if (settings != null) {
            _player.animation.gravity = double.parse(settings.properties.first.value.toString());
          }
          break;

        case 'Coin':
          final coin = Coin(
            game.spriteSheet,
            position: position,
            size: size,
          );
          add(coin);

          break;

        case 'Enemy':
          // Find the target object.
          print('Find the target object');
          final targetObjectId = spawnPoint.properties.getValue<int>('Target');
          final flip = spawnPoint.properties.getValue<bool>('Flip');
          final type = spawnPoint.properties.getValue<String>('Type');
          final health = type == 'Boss' ? 8000.0 : 100.0;
          TiledObject? target = getObjectFromTargetById(spawnPointsLayer.objects, targetObjectId);
          final enemy = EnemySpriteComponent(
            Garbage(maxHealth: health),
            game.spriteSheet,
            position: position,
            targetPosition: target != null ? Vector2(target.x, target.y) : null,
            size: size,
          );
          if (flip == true) enemy.flipHorizontally();
          add(enemy);

          break;

        case 'Door':
          final door = Door(
            game.spriteSheet,
            position: position,
            size: size,
            onPlayerEnter: () {
              parent.nextScene(level, currentIndex: sceneIndex!);
            },
          );
          add(door);
          break;
      }
    }
  }

  // This method is responsible for making the camera
  // follow the player component and also for keeping
  // the camera within level bounds.
  /// NOTE: Call only after [_spawnActors].
  void _setupCamera() {
    parent.camera.follow(_player, maxSpeed: 200, snap: true);
    // parent.camera.setBounds(
    //   Rectangle.fromLTRB(
    //     game.fixedResolution.x / 2,
    //     game.fixedResolution.y / 2,
    //     game.mapTiled.width - game.fixedResolution.x / 2,
    //     game.mapTiled.height - game.fixedResolution.y / 4,
    //   ),
    // );
  }

  // @override
  // void update(double dt) {
  //   super.update(dt);
  //   _timer += dt;
  // }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyN) {
        game.navigate('/play/session/${nextLevel.number}');
      }
    }
    return true;
  }
}
