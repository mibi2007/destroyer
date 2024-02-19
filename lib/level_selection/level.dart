import 'package:destroyer/flame_game/scripts/intro.dart';
import 'package:destroyer/utils/tileset.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';

import '../flame_game/components/coin.dart';
import '../flame_game/components/door.dart';
import '../flame_game/components/enemy.dart';
import '../flame_game/components/equipment.dart';
import '../flame_game/components/equipments/armor.dart';
import '../flame_game/components/platform.dart';
import '../flame_game/components/player.dart';
import '../flame_game/game.dart';
import '../flame_game/game_world.dart';
import '../models/enemies.dart';
import '../models/equipments.dart';
import '../utils/disabler.dart';
import 'levels.dart';

// Represents a level in game. Should only be added as child of DestroyerGameWorld
class SceneComponent extends Component
    with
        HasGameReference<DestroyerGame>,
        ParentIsA<DestroyerGameWorld>,
        TapCallbacks,
        DoubleTapCallbacks,
        KeyboardHandler {
  final GameLevel level;
  late final PlayerComponent _player;
  late final Artboard artboard;
  late final TiledComponent mapTiled;

  int? sceneIndex;
  void Function(EnemySpriteComponent boss)? onBossKilled;
  void Function(EquipmentComponent item)? onRewardPicked;

  SceneComponent(this.level, {this.sceneIndex = 0});

  // @override
  // bool containsLocalPoint(Vector2 point) => true;

  @override
  Future<void> onLoad() async {
    print('Loading level: ${level.title}');

    _setupStartLevel(game.isTesting);

    artboard = await loadArtboard(RiveFile.asset('assets/animations/character.riv'));
    mapTiled = await TiledComponent.load(
      level.scenes[sceneIndex!].mapTiled,
      Vector2.all(32),
    );
    add(mapTiled);

    _spawnActors();
    leftClick.addListener(_onLeftClickHander);

    // Wait until the _player is added to the scene
    Future.delayed(const Duration(milliseconds: 1000), () {
      _setupCamera();
      _startScript();
    });
  }

  _onLeftClickHander() {
    _player.animation.isAutoAttack = false;
    _player.animation.attack();
  }

  void _setupStartLevel(bool initLevelEquipments) {
    game.playerData.skills.value = [];
    game.playerData.skillCountdown.value = [];
    game.playerData.effects.value = [];
    game.playerData.casting.value = null;
    game.playerData.skillCountdown.value = [];
    if (initLevelEquipments || game.getEquipments().isEmpty) {
      game.setEquipments(level.equipments);
    }
  }

  // @override
  // void onLongTapDown(TapDownEvent event) {
  //   print('onLongTapDown');
  //   _player.animation.isAutoAttack = true;
  //   _player.animation.onAttackDelay = true;
  //   super.onLongTapDown(event);
  // }

  // @override
  // void onDoubleTapDown(DoubleTapDownEvent event) {
  //   print('onDoubleTapDown');
  //   _player.animation.isAutoAttack = false;
  //   _player.animation.onAttackDelay = false;
  //   super.onDoubleTapDown(event);
  // }

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
    // final settings = mapTiled.tileMap.getLayer<ObjectGroup>('Settings');

    for (final platformObject in platformsLayer!.objects) {
      final platform = Platform(
        position: Vector2(platformObject.x, platformObject.y),
        size: Vector2(platformObject.width, platformObject.height),
      );
      add(platform);
    }

    final spawnPointsLayer = mapTiled.tileMap.getLayer<ObjectGroup>('SpawnPoints');

    for (final TiledObject spawnPoint in spawnPointsLayer!.objects) {
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
          add(_player);
          parent.camera.follow(_player, maxSpeed: timeWalkSpeed, snap: true);
          // if (settings != null) {
          // _player.animation.gravity = double.parse(settings.properties.first.value.toString());
          // }
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
          final targetObjectId = spawnPoint.properties.getValue<int>('Target');
          final flip = spawnPoint.properties.getValue<bool>('Flip');
          final type = spawnPoint.properties.getValue<String>('Type');
          final health = type == 'Boss' ? 7000.0 : 100.0;
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
          if (type == 'Boss') {
            enemy.onKilled = () {
              onBossKilled?.call(enemy);
            };
          }

          break;

        case 'Door':
          final nextDoor = spawnPoint.properties.getValue<int>('Target');
          final nextLevel = spawnPoint.properties.getValue<bool>('NextLevel');
          final door = Door(
            game.spriteSheet,
            position: position,
            size: size,
            onPlayerEnter: () {
              if (nextDoor != null) {
                final targetObjectId = spawnPoint.properties.getValue<int>('Target');
                TiledObject target = getObjectFromTargetById(spawnPointsLayer.objects, targetObjectId)!;
                _player.position = Vector2(target.x, target.y - 30);
                parent.camera.moveTo(_player.position);
                // Not allow to go back
                _player.animation.resetLast2Second();
                parent.camera.follow(_player, maxSpeed: timeWalkSpeed, snap: true);
              }
              if (nextLevel == true) parent.nextScene();
            },
          );
          add(door);
          break;

        case 'Equipment':
          final equipment = Armor.fromName(spawnPoint.name);
          final equipmentComponent = ArmorComponent(
            item: equipment,
            sprite: Sprite(game.images.fromCache(equipment.iconAsset)),
            position: position,
            size: size,
          );
          add(equipmentComponent);
          break;
      }
    }
  }

  // This method is responsible for making the camera
  // follow the player component and also for keeping
  // the camera within level bounds.
  /// NOTE: Call only after [_spawnActors].
  void _setupCamera() {
    // parent.camera.follow(_player, maxSpeed: 200, snap: true);
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
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyN) {
        print(level.title);
        print(level.number);
        // game.navigate('/play/session/${level.number}/${sceneIndex! + 1}');
        parent.nextScene();
      } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
        parent.nextLevel();
        // game.navigate('/play/session/${level.next().number}/0');
      }
    }
    return true;
  }

  @override
  void onRemove() {
    print('SceneComponent onRemove');
    leftClick.removeListener(_onLeftClickHander);

    super.onRemove();
  }

  void _startScript() {
    if (level.number == 1) {
      final introScript = IntroScript();
      add(introScript);
      onBossKilled = introScript.onBossKilled;
      onRewardPicked = introScript.onRewardPicked;
    }
  }
}
