// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:destroyer/flame_game/components/brick.dart';
import 'package:destroyer/flame_game/entities/garbage_monster.entity.dart';
import 'package:destroyer/flame_game/scripts/intro.dart';
import 'package:destroyer/utils/tileset.dart';
import 'package:destroyer/utils/utils.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../flame_game/components/coin.dart';
import '../flame_game/components/door.dart';
import '../flame_game/components/equipment.dart';
import '../flame_game/components/equipments/armor.dart';
import '../flame_game/components/platform.dart';
import '../flame_game/entities/garbage.entity.dart';
import '../flame_game/entities/player.entity.dart';
import '../flame_game/game.dart';
import '../flame_game/game_world.dart';
import '../flame_game/scripts/level_1a.dart';
import '../flame_game/scripts/level_1b.dart';
import '../flame_game/scripts/level_4b.dart';
import '../flame_game/scripts/level_6.dart';
import '../flame_game/scripts/script.dart';
import '../models/enemies.dart';
import '../models/equipments.dart';
import '../overlays/game_over.dart';
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
  late final PlayerEntity _player;
  late final Artboard artboard;
  late final Artboard garbageArtboard;
  late final TiledComponent mapTiled;
  late final Cursor cursor;

  int? sceneIndex;
  void Function(PositionComponent boss)? onBossKilled;
  void Function(EquipmentComponent item)? onRewardPicked;

  late Script script;

  SceneComponent(this.level, {this.sceneIndex = 0});

  // @override
  // bool containsLocalPoint(Vector2 point) => true;
  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    cursor = Cursor();
    // cursor.debugMode = true;
    // add(cursor);
    _startScript();

    _setupStartLevel(game.isTesting);

    artboard = await loadArtboard(RiveFile.asset('assets/animations/character.riv'));
    garbageArtboard = await loadArtboard(RiveFile.asset('assets/animations/garbage_monster.riv'));
    mapTiled = await TiledComponent.load(
      level.scenes[sceneIndex!].mapTiled,
      Vector2.all(32),
    );
    await add(mapTiled);

    _spawnActors();
    leftClick.addListener(_onLeftClickHander);

    // Wait until the _player is added to the scene
    // add(TimerComponent(
    //   period: 1, // The period in seconds
    //   onTick: () {
    //   },
    // ));

    game.playerData.isDead.addListener(() {
      if (game.playerData.isDead.value) {
        game.setCredits(0);
        game.overlays.add(GameOver.id);
        // _player.removeFromParent();
        parent.customCamera.stop();
      }
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
    for (final equipment in game.getEquipments()) {
      if (equipment is Armor) {
        game.playerData.inventory.add(equipment);
      }
    }
    game.playerData.armor.value = 5 * game.playerData.inventory.value.length;
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

          _player = PlayerEntity(
            artboard: artboard,
            position: position,
            size: size,
          );
          // script.player = _player;
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
          movePlayerToPosition(_player.position);
          // if (settings != null) {
          // _player.animation.gravity = double.parse(settings.properties.first.value.toString());
          // }
          break;

        case 'Coin':
          final coin = Coin(
            game.spriteSheet,
            position: position,
            size: size,
            priority: 1,
          );
          add(coin);

          break;

        case 'Enemy':
          // Find the target object.
          final targetObjectId = spawnPoint.properties.getValue<int>('Target');
          final type = spawnPoint.properties.getValue<String>('Type');
          TiledObject? target = getObjectFromTargetById(spawnPointsLayer.objects, targetObjectId);
          Enemy enemy;
          Vector2 enemySize = Vector2.all(32);
          PositionComponent enemyComponent;
          if (type == 'Boss') {
            script.boss!.position = position;
            enemyComponent = script.boss!;
            script.boss!.onKilled = () {
              onBossKilled?.call(script.boss!);
            };
          } else if (type == 'Garbage') {
            enemy = Garbage(
              level: level.number,
              asset: rnd.nextDouble() * 2 < 1
                  ? 'assets/images/enemies/garbage1.png'
                  : 'assets/images/enemies/garbage2.png',
              maxHealth: 100,
              armor: level.number * 3,
            );
            enemyComponent = GarbageEntity(
              enemy,
              game.images.fromCache(enemy.asset),
              position: position,
              targetPosition: target?.position,
              size: enemySize,
              priority: 1,
              anchor: Anchor.topCenter,
            );
          } else {
            enemy = GarbageMonster(level: level.number);
            enemyComponent = GarbageMonsterEntity(
              enemy,
              game.images.fromCache(enemy.asset),
              // isAutonomous: true,
              position: position - Vector2(0, 50),
            );
          }
          // if (flip == true) enemyComponent.flipHorizontallyAroundCenter();
          add(enemyComponent);

          break;

        case 'Door':
          final nextDoor = spawnPoint.properties.getValue<int>('Target');
          final nextScene = spawnPoint.properties.getValue<bool>('NextScene');
          final nextLevel = spawnPoint.properties.getValue<bool>('NextLevel');
          final door = Door(
            game.spriteSheet,
            position: position,
            size: size,
            onPlayerEnter: () {
              _player.animation.isOnGround = false;
              if (nextDoor != null) {
                final targetObjectId = spawnPoint.properties.getValue<int>('Target');
                TiledObject target = getObjectFromTargetById(spawnPointsLayer.objects, targetObjectId)!;
                movePlayerToPosition(Vector2(target.x, target.y));
              }
              if (nextScene == true) parent.nextScene();
              if (nextLevel == true) parent.nextLevel();
            },
          );
          if (nextScene != null || nextLevel != null) {
            if (script is IntroScript) {
              (script as IntroScript).door = door;
            } else if (script is Level1AScript) {
              (script as Level1AScript).door = door;
            } else if (script is Level4BScript) {
              (script as Level4BScript).door = door;
            } else if (script is Level6Script) {
              (script as Level6Script).door = door;
            } else {
              add(door);
            }
          } else {
            add(door);
          }

          break;

        case 'Equipment':
          final equipment = Armor.fromName(spawnPoint.name);
          final equipmentComponent = ArmorComponent(
            item: equipment,
            sprite: Sprite(game.images.fromCache(equipment.iconAsset)),
            position: position + Vector2.all(16),
            size: size,
          );
          add(equipmentComponent);
          break;

        case 'Brick':
          final offsetX = spawnPoint.properties.getValue<int>('TileOffsetX');
          final offsetY = spawnPoint.properties.getValue<int>('TileOffsetY');
          final brick = BrickComponent(game.spriteSheet,
              offsetX: offsetX, offsetY: offsetY, position: position, size: size, priority: 0);
          add(brick);

        case 'Oracle':
          final oracle = SpriteComponent.fromImage(game.images.fromCache('assets/images/npcs/oracle.png'),
              position: position, size: size, priority: 0, srcPosition: Vector2.zero(), srcSize: Vector2(64, 64));
          if (level == GameLevel.lv1) {
            (script as IntroScript).oracle = oracle;
          }
      }
    }
  }

  // This method is responsible for making the camera
  // follow the player component and also for keeping
  // the camera within level bounds.
  /// NOTE: Call only after [_spawnActors].
  // void _setupCamera() {
  // parent.camera.follow(_player, maxSpeed: 200, snap: true);
  // parent.camera.setBounds(
  //   Rectangle.fromLTRB(
  //     game.fixedResolution.x / 2,
  //     game.fixedResolution.y / 2,
  //     game.mapTiled.width - game.fixedResolution.x / 2,
  //     game.mapTiled.height - game.fixedResolution.y / 4,
  //   ),
  // );
  // }

  // @override
  // void update(double dt) {
  //   super.update(dt);
  //   _timer += dt;
  // }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyN) {
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
    leftClick.removeListener(_onLeftClickHander);

    super.onRemove();
  }

  void _startScript() {
    // Component script;
    if (level == GameLevel.lv1) {
      script = IntroScript();
      onBossKilled = (script as IntroScript).onBossKilled;
      onRewardPicked = (script as IntroScript).onRewardPicked;
    } else if ((level == GameLevel.lv2 || level == GameLevel.lv3) && sceneIndex == 0) {
      script = Level1AScript();
    } else if ((level == GameLevel.lv2 || level == GameLevel.lv3) && sceneIndex == 1) {
      script = Level1BScript();
      onBossKilled = (script as Level1BScript).onBossKilled;
      onRewardPicked = (script as Level1BScript).onRewardPicked;
    } else if (level == GameLevel.lv4 && sceneIndex == 1) {
      script = Level4BScript();
      onBossKilled = (script as Level4BScript).onBossKilled;
    } else if (level == GameLevel.lv5 && sceneIndex == 1) {
      script = Level4BScript();
      onBossKilled = (script as Level4BScript).onBossKilled;
    } else if (level == GameLevel.lv6) {
      script = Level6Script();
      onBossKilled = (script as Level6Script).onBossKilled;
      // onRewardPicked = (script as Level6Script).onRewardPicked;
    } else {
      script = Script();
    }
    add(script);
  }

  void movePlayerToPosition(Vector2 position) {
    _player.animation.resetLast2Second();
    _player.position = position + Vector2(30, -30);
    parent.customCamera.moveTo(_player.position, speed: double.infinity);
    parent.customCamera.follow(_player, maxSpeed: kCameraSpeed, snap: true);
  }
}

class Cursor extends CircleComponent with CollisionCallbacks {
  Cursor()
      : super(
          radius: 5,
          anchor: Anchor.center,
          paint: Paint()..color = const Color(0x00000000),
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(CircleHitbox());
  }
}
