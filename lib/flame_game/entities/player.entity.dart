import 'dart:async';
import 'dart:math';

import 'package:destroyer/flame_game/behaviors/move_on_platform.behavior.dart';
import 'package:destroyer/flame_game/components/equipments/armor.dart';
import 'package:destroyer/flame_game/entities/garbage_monster.entity.dart';
import 'package:destroyer/flame_game/game_world.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/components.dart';

import '../../level_selection/level.dart';
import '../../level_selection/levels.dart';
// import 'package:rive/src/rive_core/transform_component.dart' as rive_core;

// import '../game.dart';
// import '../model/equipments.dart';
// import '../model/skills.dart';
import '../../models/equipments.dart';
import '../../models/player_data/player_data.dart';
import '../../models/skills.dart';
import '../../skills/chronosphere.dart';
import '../../skills/lightning_particle.dart';
import '../../skills/requiem_of_souls.dart';
import '../behaviors/player/hit_by_enemy_collision.behavior.dart';
import '../components/equipment.dart';
import '../components/equipments/weapon.dart';
import '../components/skills.dart';
import '../game.dart';

const double jumpSpeed = 250;
const double defaultMoveSpeed = 150;
const double flySpeed = 75;
const double timeWalkSpeed = 350;
const double playerGravity = 800;
const slashTime = 0.25;

class PlayerEntity extends PositionComponent with ParentIsA<SceneComponent> {
  final Artboard artboard;
  late PlayerAnimationEntity animation;

  PlayerEntity({required this.artboard, super.position, super.size, super.anchor = Anchor.center})
      : super(scale: Vector2.all(3), priority: 1);

  @override
  Future<FutureOr<void>> onLoad() async {
    animation = PlayerAnimationEntity(
      artboard,
      position: Vector2(size.x / 2, size.y / 2),
      size: size,
      priority: 1,
    );
    await add(animation);
  }

  @override
  bool get debugMode => false;
}

class PlayerAnimationEntity extends RiveComponent
    with
        HasGameRef<DestroyerGame>,
        HasWorldReference<DestroyerGameWorld>,
        CollisionCallbacks,
        KeyboardHandler,
        HasPaint,
        ParentIsA<PlayerEntity>,
        EntityMixin,
        OnGround {
  int _hAxisInput = 0;
  int _vAxisInput = 0;
  bool _jumpInput = false;
  // bool isOnGround = false;
  final double _moveSpeed = defaultMoveSpeed;
  @override
  get terminalVelocity => 150;
  int _jumpCount = 0;
  // Direction direction = Direction(Vector2(1, 0));
  // double aim = 0;
  // double angleToSigned = 0;

  @override
  bool get debugMode => false;

  final Vector2 _velocity = Vector2.zero();
  late StateMachineController _movesController;
  late StateMachineController _swordsController;
  late StateMachineController _effectsController;
  SMITrigger? _jumpTrigger;
  SMITrigger? _landTrigger;
  SMITrigger? _walkTrigger;
  SMITrigger? _attack1Trigger;
  SMITrigger? _attackedTrigger;
  SMINumber? _sword;

  SMITrigger? _desolatorTrigger;
  SMITrigger? _purifierTrigger;
  SMITrigger? _timeTrigger;
  SMITrigger? _flameTrigger;
  SMITrigger? _lightningTrigger;
  SMITrigger? _backwardTrigger;
  SMITrigger? _defaultEffectTrigger;
  SMITrigger? _purifiedTrigger;
  SMITrigger? _poisonedTrigger;
  SMITrigger? _invincibleTrigger;
  SMITrigger? _flashTrigger;
  SMITrigger? _flyTrigger;
  late List<SMITrigger?> _swordTriggers = [];
  late List<SMITrigger?> _effectsTriggers = [];

  // Skill Triggers
  SMITrigger? _repelTrigger;
  SMITrigger? _guardianEngelTrigger;
  SMITrigger? _timeWalkTrigger;
  SMITrigger? _cronosphereTrigger;
  SMITrigger? _requiemOfSoulsTrigger;
  SMITrigger? _ballLightningTrigger;
  SMITrigger? _thunderStrikeTrigger;
  late List<SMITrigger?> _skillsTriggers = [];

  // List<Equipment> equipments = [];
  // List<Skill> skills = [];
  // late Sword sword;

  TransformComponent? joystickDelta;

  // late Image purifierSprite;
  bool isAutoAttack = false;
  double _attackTimer = 0.0;
  final double fireSpeed = 200;
  bool has0 = false;
  bool has1 = false;
  bool has2 = false;
  bool has3 = false;
  bool has4 = false;
  bool has5 = false;

  bool onAttackDelay = false;
  List<Vector2> _last2SecondPositions = [];
  List<int> _last2SecondHealth = [];
  Timer? _savePositionTimer;
  Timer? interval;
  final test1 = TextComponent();
  final test2 = TextComponent();
  final test3 = TextComponent();
  double? selectDistance;

  @override
  get position => parent.position;

  @override
  set position(Vector2 value) {
    parent.position = value;
  }

  bool isInsideChronosphere = false;
  bool isLightning = false;

  PlayerAnimationEntity(
    Artboard artboard, {
    super.position,
    super.size,
    super.priority,
    super.children,
  }) : super(
          artboard: artboard,
          anchor: Anchor.center,
        );

  // @override
  // void onMount() {
  //   super.onMount();
  //   game.playerData.sword.value = game.getEquipments().firstWhere((e) => e is Sword) as Sword;
  // }

  void _onMousePositionChanged() {
    Vector2 mousePosition = game.camera.globalToLocal(game.playerData.currentMousePosition.value);
    game.playerData.angleToSigned.value = (mousePosition).angleToSigned(Vector2(0, 1));
    double angle = (mousePosition).angleToSigned(game.playerData.direction.value.direction) * 180 / pi;
    if (angle > 90 || angle < -90) {
      if (game.playerData.casting.value == null) {
        flipHorizontally();
        // After fliping the player, the angle should be flipped as well
        angle = -angle;
      }
    }
    if (game.playerData.casting.value == null) {
      game.playerData.aim.value =
          -game.playerData.direction.value.x * (mousePosition).angleToSigned(game.playerData.direction.value.direction);
      print(game.playerData.aim.value);
      joystickDelta!.rotation = -game.playerData.direction.value.x * angle * pi / 180;
    }
  }

  void _onDragJoystick() {
    // print(game.playerData.joystickDelta.value);
    if (joystickDelta == null) return;
    final mousePosition = game.playerData.joystickDelta.value;
    if (mousePosition != Vector2.zero()) {
      game.playerData.angleToSigned.value = (mousePosition).angleToSigned(Vector2(0, 1));
    }
    double angle = (mousePosition).angleToSigned(game.playerData.direction.value.direction) * 180 / pi;
    if (angle > 90 || angle < -90) {
      if (game.playerData.casting.value == null) {
        flipHorizontally();
        // After fliping the player, the angle should be flipped as well
        angle = -angle;
      }
    }
    if (game.playerData.casting.value == null && mousePosition != Vector2.zero()) {
      game.playerData.aim.value =
          -game.playerData.direction.value.x * (mousePosition).angleToSigned(game.playerData.direction.value.direction);
      joystickDelta!.rotation = -game.playerData.direction.value.x * angle * pi / 180;
    }
    _hAxisInput = 0;
    _vAxisInput = 0;
    if (mousePosition.x > 0.5) {
      _hAxisInput += 1;
      _walkTrigger?.fire();
    }
    ;
    if (mousePosition.x < -0.5) {
      _hAxisInput -= 1;
      _walkTrigger?.fire();
    }
    ;
    _vAxisInput += mousePosition.y > 0.5 ? 1 : 0;
    _vAxisInput += mousePosition.y < -0.5 ? -1 : 0;
  }

  void onTick() {
    if (game.playerData.casting.value != Skills.timeWalk) {
      // print(last2SecondPositions);
      _last2SecondPositions.add(Vector2(position.x, position.y));
      // print('first: ${last2SecondPositions.first} last: ${last2SecondPositions.last}');
      // print(last2SecondPositions.last);
      _last2SecondHealth.add(game.playerData.health.value);
      if (_last2SecondPositions.length > 20) {
        _last2SecondPositions.removeAt(0);
        _last2SecondHealth.removeAt(0);
      }
    }
  }

  @override
  Future<void> onLoad() async {
    // Player behaviors
    await addAll([
      PropagatingCollisionBehavior(CircleHitbox(), key: ComponentKey.named('player')),
      MoveOnPlatform(),
      HitByEnemy(),
    ]);
    // add(test1);
    // add(test2);
    // add(test3);
    _savePositionTimer = Timer(0.1, onTick: onTick, repeat: true);

    if (game.isMobile) {
      game.playerData.joystickDelta.addListener(_onDragJoystick);
    } else {
      game.playerData.currentMousePosition.addListener(_onMousePositionChanged);
    }
    game.playerData.equipments.addListener(_onEquipmentsChangeHandler);
    game.playerData.casting.addListener(_onCastingHandler);
    game.playerData.effects.addListener(_onEffectsChangeHandler);
    game.playerData.autoAttack.addListener(_autoAttackHandler);
    game.playerData.jump.addListener(_onJumpHandler);
    game.playerData.revertDead.addListener(_revertDeadHandler);
    game.playerData.changeSwordAnimation.addListener(changeSwordAnimation);
    _onEquipmentsChangeHandler();

    // game.playerData.sword.addListener(_onSwordChangeHandler);
    // rightClick.addListener(rightClickHandler);
    // add(CircleHitbox());
    // await add(PositionComponent(position: Vector2.all(x / 2), children: [CircleHitbox()]));
    final controller = StateMachineController.fromArtboard(artboard, 'movesStateMachine');
    if (controller != null) {
      _movesController = controller;
      // _controller.isActive = true;
      artboard.addController(_movesController);
      _jumpTrigger = _movesController.findSMI('jumpTrigger');
      _landTrigger = _movesController.findSMI('landTrigger');
      _walkTrigger = _movesController.findSMI('walkTrigger');
      _attackedTrigger = _movesController.findSMI('attackedTrigger');
      _backwardTrigger = _movesController.findSMI('backwardTrigger');
    } else {
      throw Exception('Could not load StateMachineController');
    }
    final controller2 = StateMachineController.fromArtboard(
      artboard,
      "swordsStateMachine",
    );
    if (controller2 != null) {
      _swordsController = controller2;
      // _controller.isActive = true;
      artboard.addController(_swordsController);
      _attack1Trigger = _swordsController.findSMI('attack1Trigger');

      _desolatorTrigger = _swordsController.findSMI('desolatorTrigger');
      _purifierTrigger = _swordsController.findSMI('purifierTrigger');
      _timeTrigger = _swordsController.findSMI('timeTrigger');
      _flameTrigger = _swordsController.findSMI('flameTrigger');
      _lightningTrigger = _swordsController.findSMI('lightningTrigger');
      _sword = _swordsController.findSMI('sword');
      _swordTriggers = [_desolatorTrigger, _purifierTrigger, _timeTrigger, _flameTrigger, _lightningTrigger];
      // Init sword animation
      _sword?.value = game.playerData.sword.value.triggerIndex.toDouble();
      _swordTriggers[game.playerData.sword.value.triggerIndex]?.fire();

      // Skill Triggers
      _repelTrigger = _swordsController.findSMI('RepelTrigger');
      _guardianEngelTrigger = _swordsController.findSMI('GuardianEngelTrigger');
      _timeWalkTrigger = _swordsController.findSMI('TimeWalkTrigger');
      _cronosphereTrigger = _swordsController.findSMI('CronosphereTrigger');
      _requiemOfSoulsTrigger = _swordsController.findSMI('RequiemOfSoulsTrigger');
      _ballLightningTrigger = _swordsController.findSMI('BallLightningTrigger');
      _thunderStrikeTrigger = _swordsController.findSMI('ThunderStrikeTrigger');
      _skillsTriggers = [
        _repelTrigger,
        _guardianEngelTrigger,
        _timeWalkTrigger,
        _cronosphereTrigger,
        _requiemOfSoulsTrigger,
        _ballLightningTrigger,
        _thunderStrikeTrigger
      ];
    } else {
      throw Exception('Could not load StateMachineController');
    }

    final controller3 = StateMachineController.fromArtboard(artboard, 'effectsStateMachine');
    if (controller3 != null) {
      _effectsController = controller3;
      // _controller.isActive = true;
      artboard.addController(_effectsController);
      _defaultEffectTrigger = _effectsController.findSMI('defaultTrigger');
      _purifiedTrigger = _effectsController.findSMI('purifiedTrigger');
      _poisonedTrigger = _effectsController.findSMI('poisonedTrigger');
      _invincibleTrigger = _effectsController.findSMI('invincibleTrigger');
      _flashTrigger = _effectsController.findSMI('flashTrigger');
      _flyTrigger = _effectsController.findSMI('flyTrigger');
      _effectsTriggers = [
        _defaultEffectTrigger,
        _purifiedTrigger,
        _poisonedTrigger,
        _invincibleTrigger,
        _flashTrigger,
        _flyTrigger
      ];
    }

    joystickDelta = artboard.component('LookingConstraint');

    // Start with the first sword, trigger _changeToSword after all animations are initialized
    // print(game.playerData.sword.value);

    // For super hero landing animation
    gravity = 0;
    final newSword = game.getEquipments().firstWhere((e) => e is Sword) as Sword;
    // });
    add(TimerComponent(
      period: 1, // The period in seconds
      onTick: () {
        gravity = playerGravity;
        changeToSword(newSword);
      },
      removeOnFinish: true,
    ));
  }

  @override
  void flipHorizontally() {
    game.playerData.direction.value = Direction(Vector2(-game.playerData.direction.value.x, 0));
    super.flipHorizontally();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.playerData.isDead.value || game.playerData.casting.value != null) {
      moveBackground(Vector2(0, 0));
      if (game.playerData.isDead.value) {
        isAutoAttack = false;
        onAttackDelay = false;
      }
    }

    if (interval != null) interval!.update(dt);

    _attackTimer += dt;
    if (_savePositionTimer != null) _savePositionTimer!.update(dt);
    final sword = game.playerData.sword.value;
    if (isAutoAttack && onAttackDelay) {
      if (_attackTimer >= sword.delay) {
        onAttackDelay = false;
        attack(); // Run your function
        _attackTimer = 0.0; // Reset the timer
      }
    } else if (onAttackDelay) {
      if (_attackTimer >= sword.delay) {
        onAttackDelay = false;
        _attackTimer = 0.0; // Reset the timer
      }
    }

    if (game.playerData.effects.value.contains(SkillEffects.fly)) {
      _velocity.x = _hAxisInput * flySpeed;
      _velocity.y = _vAxisInput * flySpeed;
      position.x += _velocity.x * dt;
      position.y += _velocity.y * dt;
      moveBackground(_velocity);
      game.playerData.position.value = position;
      return;
    } else if (game.playerData.effects.value.contains(SkillEffects.timeWalk5s) &&
        game.playerData.effects.value.contains(SkillEffects.chronosphere)) {
      _velocity.x = _hAxisInput * timeWalkSpeed;
      _velocity.y = _vAxisInput * timeWalkSpeed;
      position.x += _velocity.x * dt;
      position.y += _velocity.y * dt;
      moveBackground(_velocity);
      game.playerData.position.value = position;
      return;
    }

    // Stop moving when casting
    if (game.playerData.casting.value != null) {
      return;
      // if (game.playerData.sword.value.type != SwordType.time) {
      //   position = _velocity * dt;
      // } else {
      //   return;
      // }
    }
    // Modify components of velocity based on
    // inputs and gravity.
    _velocity.x = _hAxisInput * _moveSpeed;
    // Allow jump only if jump input is pressed
    // and player is already on ground.
    if (_jumpInput) {
      if (_jumpCount == 0) {
        isOnGround = false;
        isPendingAfterJump = true;
        _jumpCount++;
        // AudioManager.playSfx('Jump_15.wav');
        // _velocity.y = -jumpSpeed;
        // _controller.findInput<double>('Level')?.value = 1;
        velocity.y = -jumpSpeed;
        _jumpTrigger?.fire();
      } else if (_jumpCount == 1) {
        _jumpCount++;
        // _velocity.y = -jumpSpeed;
        velocity.y = -jumpSpeed;
        _jumpTrigger?.fire();
      } else {
        _landTrigger?.fire();
      }
      // _velocity.y = velocity.y;
      _jumpInput = false;
    } else {}
    if (_velocity.x == 0) {
      _landTrigger?.fire();
    }
    // through platforms at very high velocities.
    // print('isOnGround: $isOnGround');
    if (isOnGround || isLightning) {
      _velocity.y = 0;
      _jumpCount = 0;
      // _landTrigger?.fire();
    } else {
      _velocity.y = velocity.y;
    }

    if (game.isMobile) {
      // _velocity.x = _velocity.x;
      // position += _velocity * dt;
      // game.playerData.position.value = position;
      // return;
    } else {
      // print(_velocity * dt);
    }
    // delta movement = velocity * time
    position += _velocity * dt;
    game.playerData.position.value = position;
    moveBackground(_velocity);
  }

  void moveBackground(Vector2 velocity) {
    if (collisionNormal.x > -0.9 && collisionNormal.x < 0.9) {
      game.background.parallax!.baseVelocity.x = velocity.x / 50;
    } else {
      game.background.parallax!.baseVelocity.x = 0;
    }
    if (game.level == GameLevel.lv2) return;
    if (collisionNormal.y > -0.9 && collisionNormal.y < 0.9) {
      game.background.parallax!.baseVelocity.y = velocity.y / 50;
    } else {
      game.background.parallax!.baseVelocity.y = 0;
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (game.playerData.casting.value != null) return false;
    _hAxisInput = 0;
    _vAxisInput = 0;

    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.keyA) ? -1 : 0;
    _hAxisInput += keysPressed.contains(LogicalKeyboardKey.keyD) ? 1 : 0;
    _vAxisInput += keysPressed.contains(LogicalKeyboardKey.keyW) ? -1 : 0;
    _vAxisInput += keysPressed.contains(LogicalKeyboardKey.keyS) ? 1 : 0;

    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
        if (game.playerData.direction.value.isLeft) {
          _walkTrigger?.fire();
        } else if (game.playerData.direction.value.isRight) {
          _backwardTrigger?.fire();
        }
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        if (game.playerData.direction.value.isLeft) {
          _backwardTrigger?.fire();
        } else if (game.playerData.direction.value.isRight) {
          _walkTrigger?.fire();
        }
      }
      if (keysPressed.any((key) {
        return [LogicalKeyboardKey.control, LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.controlRight]
            .contains(key);
      })) {
        // print(keysPressed);
        if (keysPressed.contains(LogicalKeyboardKey.digit1) && has1) {
          moveSwordToSlot(0);
        } else if (keysPressed.contains(LogicalKeyboardKey.digit2) && has2) {
          moveSwordToSlot(1);
        } else if (keysPressed.contains(LogicalKeyboardKey.digit3) && has3) {
          moveSwordToSlot(2);
        } else if (keysPressed.contains(LogicalKeyboardKey.digit4) && has4) {
          moveSwordToSlot(3);
        } else if (keysPressed.contains(LogicalKeyboardKey.digit5) && has5) {
          moveSwordToSlot(4);
        }
      } else {
        if (keysPressed.contains(LogicalKeyboardKey.digit1) && has1) {
          final newSword = (game.getEquipments()[0] as Sword);
          changeToSword(newSword);
        } else if (keysPressed.contains(LogicalKeyboardKey.digit2) && has2) {
          final newSword = (game.getEquipments()[1] as Sword);
          changeToSword(newSword);
        } else if (keysPressed.contains(LogicalKeyboardKey.digit3) && has3) {
          final newSword = (game.getEquipments()[2] as Sword);
          changeToSword(newSword);
        } else if (keysPressed.contains(LogicalKeyboardKey.digit4) && has4) {
          final newSword = (game.getEquipments()[3] as Sword);
          changeToSword(newSword);
        } else if (keysPressed.contains(LogicalKeyboardKey.digit5) && has5) {
          final newSword = (game.getEquipments()[4] as Sword);
          changeToSword(newSword);
        }
      }

      if (keysPressed.contains(LogicalKeyboardKey.space)) {
        if (_jumpCount < 2) {
          _jumpInput = true;
        }
      }

      if (keysPressed.contains(LogicalKeyboardKey.tab)) {
        switchNextSword();
      }

      if (keysPressed.contains(LogicalKeyboardKey.keyB)) {
        for (var index = 0; index < game.playerData.skillCountdown.value.length; index++) {
          game.playerData.skillCountdown.updateAt(index, false);
        }
      }
    }

    return true;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is EquipmentComponent) {
      game.addEquipment(other.item);
      if (other is SwordComponent) {
        final newSword = other.item as Sword;
        changeToSword(newSword);
        parent.parent.onRewardPicked?.call(other);
      }
      if (other is ArmorComponent) {
        game.playerData.inventory.add(other.item, shouldNotify: true);
      }
      other.removeFromParent();
    }

    if (other is ChronosphereSkillComponent) {
      isInsideChronosphere = true;
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  void _onEquipmentsChangeHandler() {
    final equipments = game.getEquipments();

    for (int i = 0; i < equipments.whereType<Sword>().length; i++) {
      if (i == 0) has1 = true;
      if (i == 1) has2 = true;
      if (i == 2) has3 = true;
      if (i == 3) has4 = true;
      if (i == 4) has5 = true;
    }
  }

  // This method runs an opacity effect on player
  // to make it blink.
  void hit() {
    _attackedTrigger?.fire();
  }

  void attack() {
    if (onAttackDelay || game.playerData.casting.value != null || isLightning) return;
    onAttackDelay = true;
    _attack1Trigger?.fire();
    final sword = game.playerData.sword.value;
    final slash = HalfCircleHitbox(
      radius: 10,
      position: Vector2(size.x / 2, size.y / 2),
      sword: sword,
      paint: Paint()..color = const Color(0x00FFFFFF),
      angle: game.playerData.aim.value,
    );
    add(slash);
    add(TimerComponent(
      period: 0.2, // The period in seconds
      onTick: () {
        if (!slash.isRemoved) remove(slash);
      },
      removeOnFinish: true,
    ));
    if (game.playerData.effects.value.contains(SkillEffects.fireball)) {
      final firePosition = Vector2(position.x, position.y);
      final fireAngle = game.playerData.angleToSigned.value;
      final fireballVelocity = Vector2(sin(fireAngle) * fireSpeed, cos(fireAngle) * fireSpeed);
      Fireball bullet = Fireball(
        position: firePosition,
        velocity: fireballVelocity,
        angle: game.playerData.aim.value,
        speed: fireSpeed,
        damage: game.playerData.sword.value.damage,
      );
      parent.parent.add(bullet);
    }
  }

  // Makes the player jump forcefully.
  void jump() {
    _jumpInput = true;
    _jumpTrigger?.fire();
  }

  void switchNextSword() {
    final sword = game.playerData.sword.value;
    final equipments = game.getEquipments();
    final currentIndex = equipments.indexWhere((element) => (element as Sword).type == sword.type);
    final nextIndex = (currentIndex + 1) % equipments.length;
    final nextSword = equipments[nextIndex] as Sword;
    changeToSword(nextSword);
  }

  @override
  void onRemove() {
    game.playerData.equipments.removeListener(_onEquipmentsChangeHandler);
    game.playerData.casting.removeListener(_onCastingHandler);
    game.playerData.effects.removeListener(_onEffectsChangeHandler);
    game.playerData.autoAttack.removeListener(_autoAttackHandler);
    game.playerData.jump.removeListener(_onJumpHandler);
    game.playerData.revertDead.removeListener(_revertDeadHandler);
    game.playerData.changeSwordAnimation.removeListener(changeSwordAnimation);

    if (interval != null) interval!.stop();
    if (_savePositionTimer != null) _savePositionTimer!.stop();
    super.onRemove();
  }

  void changeSwordAnimation() {
    final triggerIndex = game.playerData.changeSwordAnimation.value;
    _sword?.value = triggerIndex.toDouble();
    _swordTriggers[triggerIndex]?.fire();
  }

  void _onCastingHandler() {
    // test1.text = game.playerData.casting.value == null ? 'null' : game.playerData.casting.value!.name;
    if (game.playerData.casting.value != null) {
      final skill = game.playerData.casting.value!;
      if (skill.swordType != null && skill.swordType != game.playerData.sword.value.type) {
        final newSword = game.getEquipments().firstWhere((e) => e is Sword && e.type == skill.swordType) as Sword;
        final triggerIndex = newSword.triggerIndex;
        _sword?.value = triggerIndex.toDouble();
        _swordTriggers[newSword.triggerIndex]?.fire();
      }
      _attackTimer = 0;
      if (skill.triggerIndex != null) {
        _skillsTriggers[skill.triggerIndex!]?.fire();

        // Set posture to cast skill
        game.playerData.aim.value = 0;
        joystickDelta!.rotation = pi / 180;
      }
      if (skill.name == 'Repel') {
        add(TimerComponent(
          period: 0.5, // The period in seconds
          onTick: () {
            if (game.playerData.selectedTarget.value != null) {
              final target = game.playerData.selectedTarget.value!;
              if (target is GarbageMonsterEntity) {
                target.purge();
              }
            }
          },
        ));
      } else if (skill.name == 'Guardian Engel') {
        add(TimerComponent(
          period: 2, // The period in seconds
          onTick: () {
            final visibleGarbageMonster =
                parent.parent.children.whereType<GarbageMonsterEntity>().where((e) => world.customCamera.canSee(e));
            for (final monster in visibleGarbageMonster) {
              monster.purge();
            }
          },
          removeOnFinish: true,
        ));
      } else if (skill.name == 'Time Walk') {
        _castTimeWalk(skill);
      } else if (skill.name == 'Chronosphere') {
        final selectedLocation = game.playerData.selectedLocation.value != null
            ? game.camera.globalToLocal(game.playerData.selectedLocation.value!)
            : null;
        final skillComponent = ChronosphereSkillComponent(
            duration: skill.duration,
            delayCast: skill.castTime,
            position: selectedLocation != null ? position + selectedLocation / game.zoom : position);
        parent.parent.add(skillComponent);
      } else if (skill.name == 'Requiem of Souls') {
        final skillComponent =
            RequiemOfSoulsSkillComponent(duration: skill.duration, delayCast: skill.castTime, position: position);
        add(TimerComponent(
          period: skill.castTime, // The period in seconds
          onTick: () {
            parent.parent.add(skillComponent);
          },
          removeOnFinish: true,
        ));
      } else if (skill.name == 'Ball Lightning') {
        _castLightning(skill);
      } else if (skill.name == 'Thunder Strike') {
        _castThunderStrike(skill);
      }
    }
  }

  void changeToSword(Sword newSword) {
    // print('_changeToSword: $type');
    if (game.playerData.sword.value == newSword) {
      game.playerData.sword.change();
      return;
    }
    game.playerData.lastSword.value = game.playerData.sword.value;
    game.playerData.sword.value = newSword;

    final triggerIndex = newSword.triggerIndex;
    _sword?.value = triggerIndex.toDouble();
    _swordTriggers[triggerIndex]?.fire();
  }

  void _onEffectsChangeHandler() {
    _effectsTriggers[0]?.fire();
    isOnGround = false;
    final effects = game.playerData.effects.value;
    for (var e in effects) {
      // print(e);
      if (e.name == 'purified' || e.name == 'guardianEngel') {
        game.playerData.health.value = min(100, game.playerData.health.value + e.healPoint!);
      }
      if (e.triggerIndex != null) {
        _effectsTriggers[e.triggerIndex!]?.fire();
      }
    }
  }

  void resetLast2Second() {
    _last2SecondHealth = [];
    _last2SecondPositions = [];
  }

  void _autoAttackHandler() {
    isAutoAttack = game.playerData.autoAttack.value;
    onAttackDelay = isAutoAttack;
    // if (!isAutoAttack) {
    //   attack();
    // }
  }

  void _castLightning(Skill skill) {
    _jumpTrigger?.fire();
    final selectedLocation = game.playerData.selectedLocation.value != null
        ? game.camera.globalToLocal(game.playerData.selectedLocation.value!)
        : null;
    final end =
        selectedLocation != null ? (position + selectedLocation / game.zoom) : position; // Ending point of the line
    // final Vector2 start = Vector2(position.x, position.y);
    // final lightningParticle = ParticleSystemComponent(
    //     particle: LightningParticle(lifespan: 1, start: Vector2(position.x, position.y), end: position));
    final lightningParticle = SmallLightningParticle(start: Vector2(position.x, position.y), end: position);
    // final lightningParticle = ThunderStrikeParticle(start: Vector2(position.x, position.y), end: end);
    isLightning = true;

    // Stay in Ball Lightning for 1.5 seconds then move to the end point
    add(TimerComponent(
      period: 0.5, // The period in seconds
      onTick: () {
        add(MoveEffect.to(end, LinearEffectController(1)));
        parent.parent.add(lightningParticle);
      },
      removeOnFinish: true,
    ));
    add(TimerComponent(
      period: 1.5, // The period in seconds
      onTick: () {
        lightningParticle.removeFromParent();
        isLightning = false;
      },
      removeOnFinish: true,
    ));
  }

  void _castThunderStrike(Skill skill) {
    isLightning = true;

    final totalDuration = skill.castTime + skill.duration;
    final effect = NightHighlightEffect(position: position);
    parent.parent.add(effect);
    add(TimerComponent(
      period: totalDuration, // The period in seconds
      onTick: () {
        effect.removeFromParent();
      },
      removeOnFinish: true,
    ));

    final lightningEffect = ThunderStrikeEffects(
      size: Vector2(game.fixedResolution.x / 2, game.fixedResolution.y),
      position: Vector2(position.x, position.y - game.fixedResolution.y / 2),
      direction: game.playerData.direction.value,
      gap: 18,
      delay: 0.1,
    );
    add(TimerComponent(
      period: 1.7, // The period in seconds
      onTick: () {
        parent.parent.add(lightningEffect);
      },
      removeOnFinish: true,
    ));
    add(TimerComponent(
      period: totalDuration, // The period in seconds
      onTick: () {
        lightningEffect.removeFromParent();
        isLightning = false;
        game.playerData.casting.value = null;
      },
      removeOnFinish: true,
    ));
  }

  void _revertDeadHandler() {
    final newSword = game.getEquipments().firstWhere((e) => e is Sword && e.type == SwordType.time) as Sword;
    changeToSword(newSword);
  }

  void _castTimeWalk(Skill skill) {
    game.playerData.casting.value = Skills.timeWalk;

    interval = Timer(
      skill.duration / 20, // Interval duration in seconds
      onTick: () {
        // _velocity.x = last2SecondPositions.last.x;
        // _velocity.y = last2SecondPositions.last.y;
        position = _last2SecondPositions.last;
        _last2SecondPositions.removeLast();
        game.playerData.health.value = _last2SecondHealth.last;
        _last2SecondHealth.removeLast();
        if (_last2SecondPositions.isEmpty) interval!.stop();
      }, // Callback function to execute
      repeat: true, // Whether the timer should repeat
    );
    if (skill.effects.isNotEmpty) {
      for (var effect in skill.effects) {
        if (effect.triggerIndex != null) _effectsTriggers[effect.triggerIndex!]?.fire();
      }
    }
  }

  void moveSwordToSlot(int i) {
    final sword = game.playerData.sword.value;
    final newEquipments = game.getEquipments();
    newEquipments.removeWhere((e) => e is Sword && e.type == sword.type);
    newEquipments.insert(i, sword);
    game.setEquipments(newEquipments);
    game.playerData.equipments.change();
    add(TimerComponent(
      period: 0.2, // The period in seconds
      onTick: () {
        changeToSword(sword);
      },
    ));
  }

  void _onJumpHandler() {
    _jumpInput = true;
  }
}

class NightHighlightEffect extends PositionComponent with ParentIsA<SceneComponent> {
  NightHighlightEffect({
    required super.position,
  }) : super(anchor: Anchor.center, size: Vector2.all(1000), priority: 0);
  @override
  FutureOr<void> onLoad() {
    final night = RectangleComponent(
      size: size,
      position: Vector2(size.x / 2, size.y / 2),
      paint: Paint()..color = const Color(0x88000000),
      anchor: Anchor.center,
      priority: 0,
    );
    add(night);
    // night.add(OpacityEffect.fadeIn(LinearEffectController(0.5)));
  }
}

class HalfCircleHitbox extends CircleComponent {
  final Sword sword;
  HalfCircleHitbox(
      {required this.sword, required double super.radius, required Vector2 super.position, super.paint, super.angle})
      : super(
          anchor: Anchor.centerLeft,
        );

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(Slash(radius, sword: sword));
  }
}

class Slash extends PolygonComponent with CollisionCallbacks {
  // Define the number of points to approximate the half-circle
  static const int numberOfPoints = 10;
  final double radius;
  final Sword sword;

  Slash(this.radius, {Vector2? position, required this.sword})
      : super(
          // Generate points for the half-circle
          List.generate(numberOfPoints, (i) {
            final theta = pi * i / (numberOfPoints - 1) - pi / 2; // Half-circle (180 degrees)
            return Vector2(radius * cos(theta), radius * sin(theta));
          }),
          position: Vector2(-radius, radius),
          anchor: Anchor.centerLeft,
          paint: Paint()..color = const Color(0x00FFFFFF),
        );

  @override
  Future<void> onLoad() async {
    // Add a hitbox to the component
    final hitbox = PolygonHitbox(vertices, position: Vector2(size.x / 2, size.y / 2), anchor: Anchor.center);
    add(hitbox);
    add(MoveEffect.by(Vector2(30, 0), LinearEffectController(slashTime)));
  }
}
