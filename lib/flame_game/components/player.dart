import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:destroyer/level_selection/level.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/services.dart';
import 'package:rive/components.dart';

// import 'package:rive/src/rive_core/transform_component.dart' as rive_core;

// import '../game.dart';
// import '../model/equipments.dart';
// import '../model/skills.dart';
import '../../models/equipments.dart';
import '../../models/player_data/player_data.dart';
import '../../models/skills.dart';
import '../../skills/chronosphere.dart';
import '../../skills/requiem_of_souls.dart';
import '../game.dart';
import 'equipment.dart';
import 'equipments/weapon.dart';
import 'platform.dart';
import 'skills.dart';

const double jumpSpeed = 250;
const double defaultMoveSpeed = 150;
const double flySpeed = 75;
const double timeWalkSpeed = 350;
const double g = 800;

class PlayerComponent extends PositionComponent with ParentIsA<SceneComponent> {
  final Artboard artboard;
  late PlayerAnimationComponent animation;

  PlayerComponent({required this.artboard, super.position, super.size, super.anchor = Anchor.center})
      : super(
          scale: Vector2.all(3),
        );

  @override
  Future<FutureOr<void>> onLoad() async {
    animation = PlayerAnimationComponent(
      artboard,
      position: Vector2(size.x / 2, size.y / 2),
      size: size,
      priority: 1,
    );
    print('PlayerComponent onLoad');
    await add(animation);
  }

  @override
  bool get debugMode => false;

  @override
  void onRemove() {
    print('PlayerComponent onRemove');
    super.onRemove();
  }
}

class PlayerAnimationComponent extends RiveComponent
    with HasGameRef<DestroyerGame>, CollisionCallbacks, KeyboardHandler, HasPaint, ParentIsA<PlayerComponent> {
  int _hAxisInput = 0;
  int _vAxisInput = 0;
  bool _jumpInput = false;
  bool _isOnGround = false;
  double _moveSpeed = defaultMoveSpeed;
  int _jumpCount = 0;
  // Direction direction = Direction(Vector2(1, 0));
  // double aim = 0;
  // double angleToSigned = 0;

  @override
  bool get debugMode => false;

  double gravity = 0;

  final Vector2 _up = Vector2(0, -1);
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

  TransformComponent? lookingConstraint;

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

  Vector2 collisionNormal = Vector2.zero();

  bool isInsideChronosphere = false;

  PlayerAnimationComponent(
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

  // Updates score text on hud.
  void _onMousePositionChanged() {
    if (lookingConstraint == null) return;
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
      lookingConstraint!.rotation = -game.playerData.direction.value.x * angle * pi / 180;
    }
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
    print('PlayerAnimationComponent onLoad');
    // add(test1);
    // add(test2);
    // add(test3);

    _savePositionTimer = Timer(0.1, onTick: onTick, repeat: true);

    game.playerData.currentMousePosition.addListener(_onMousePositionChanged);
    game.playerData.equipments.addListener(_onEquipmentsChangeHandler);
    game.playerData.casting.addListener(_onCastingHandler);
    game.playerData.effects.addListener(_onEffectsChangeHandler);
    game.playerData.autoAttack.addListener(_onDoubleTapHandler);
    _onEquipmentsChangeHandler();

    // game.playerData.sword.addListener(_onSwordChangeHandler);
    // rightClick.addListener(rightClickHandler);
    add(CircleHitbox());
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

    lookingConstraint = artboard.component('LookingConstraint');

    // Start with the first sword, trigger _changeToSword after all animations are initialized
    // print(game.playerData.sword.value);

    // For super hero landing animation
    gravity = 0;
    // Future.delayed(const Duration(milliseconds: 100)).then((_) {
    final sword = game.getEquipments().firstWhere((e) => e is Sword) as Sword;
    // });
    _changeToSword(sword.type);
    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      gravity = g;
    });
  }

  @override
  void flipHorizontally() {
    game.playerData.direction.value = Direction(Vector2(-game.playerData.direction.value.x, 0));
    super.flipHorizontally();
  }

  @override
  void update(double dt) {
    super.update(dt);

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
      moveBackgound(_velocity);
      return;
    } else if (game.playerData.effects.value.contains(SkillEffects.timeWalk5s) &&
        game.playerData.effects.value.contains(SkillEffects.chronosphere)) {
      _velocity.x = _hAxisInput * timeWalkSpeed;
      _velocity.y = _vAxisInput * timeWalkSpeed;
      position.x += _velocity.x * dt;
      position.y += _velocity.y * dt;
      moveBackgound(_velocity);
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
      if (_isOnGround && _jumpCount == 0) {
        _isOnGround = false;
        _jumpCount++;
        // AudioManager.playSfx('Jump_15.wav');
        _velocity.y = -jumpSpeed;
        // _controller.findInput<double>('Level')?.value = 1;
        _jumpTrigger?.fire();
      } else if (!_isOnGround && _jumpCount == 1) {
        _jumpCount++;
        _velocity.y = -jumpSpeed;
        _jumpTrigger?.fire();
      } else {
        _landTrigger?.fire();
      }
      _jumpInput = false;
    } else {}
    if (_velocity.x == 0) {
      _landTrigger?.fire();
    }
    // Clamp velocity along y to avoid player tunneling
    // through platforms at very high velocities.
    if (_isOnGround && isColliding) {
      _velocity.y = 0;
      // _landTrigger?.fire();
    } else {
      _velocity.y += gravity * dt;
    }
    // delta movement = velocity * time
    position += _velocity * dt;
    moveBackgound(_velocity);
  }

  void moveBackgound(Vector2 v) {
    if (collisionNormal.x > -0.9 && collisionNormal.x < 0.9) {
      game.background.parallax!.baseVelocity.x = v.x / 50;
    } else {
      game.background.parallax!.baseVelocity.x = 0;
    }
    if (collisionNormal.y > -0.9 && collisionNormal.y < 0.9) {
      game.background.parallax!.baseVelocity.y = v.y / 50;
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
        if (game.playerData.direction.value.isleft) {
          _walkTrigger?.fire();
        } else if (game.playerData.direction.value.isright) {
          _backwardTrigger?.fire();
        }
      }
      if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
        if (game.playerData.direction.value.isleft) {
          _backwardTrigger?.fire();
        } else if (game.playerData.direction.value.isright) {
          _walkTrigger?.fire();
        }
      }
      if (keysPressed.contains(LogicalKeyboardKey.digit0) && has0) {
        _changeToSword(SwordType.desolator);
      } else if (keysPressed.contains(LogicalKeyboardKey.digit1) && has1) {
        _changeToSword(SwordType.purifier);
      } else if (keysPressed.contains(LogicalKeyboardKey.digit2) && has2) {
        _changeToSword(SwordType.time);
      } else if (keysPressed.contains(LogicalKeyboardKey.digit3) && has3) {
        _changeToSword(SwordType.flame);
      } else if (keysPressed.contains(LogicalKeyboardKey.digit4) && has4) {
        _changeToSword(SwordType.lightning);
      } else if (keysPressed.contains(LogicalKeyboardKey.digit5) && has5) {
        _sword?.value = 5;
        _swordTriggers[5]?.fire();
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
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;

        final newCollisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - newCollisionNormal.length;
        newCollisionNormal.normalize();
        // If collision normal is almost upwards,
        // player must be on ground.
        if (_up.dot(newCollisionNormal) > 0.7) {
          _isOnGround = true;
          _jumpCount = 0;
        }

        // Resolve collision by moving player along
        // collision normal by separation distance.
        position += newCollisionNormal.scaled(separationDistance);
        collisionNormal = newCollisionNormal;
      }
    }

    if (other is EquipmentComponent) {
      game.addEquipment(other.item);
      if (other is SwordComponent) {
        final newSword = other.item as Sword;
        _changeToSword(newSword.type);
        parent.parent.onRewardPicked?.call(other);
      }
      other.removeFromParent();
    }

    if (other is ChronosphereSkillComponent) {
      isInsideChronosphere = true;
    }

    super.onCollision(intersectionPoints, other);
  }

  void _onEquipmentsChangeHandler() {
    final equipments = game.getEquipments();
    for (var e in equipments) {
      if (e is Sword) {
        if (e.type == SwordType.desolator) {
          has0 = true;
        } else if (e.type == SwordType.purifier) {
          has1 = true;
        } else if (e.type == SwordType.time) {
          has2 = true;
        } else if (e.type == SwordType.flame) {
          has3 = true;
        } else if (e.type == SwordType.lightning) {
          has4 = true;
        }
      }
    }
  }

  // This method runs an opacity effect on player
  // to make it blink.
  void hit() {
    _attackedTrigger?.fire();
  }

  void attack() {
    if (onAttackDelay || game.playerData.casting.value != null) return;
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
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!slash.isRemoved) remove(slash);
      // slash.removeFromParent();
    });
    if (game.playerData.effects.value.contains(SkillEffects.fireball)) {
      final firePosition = Vector2(position.x, position.y);
      final fireAngle = game.playerData.angleToSigned.value;
      final fireballVelocity = Vector2(sin(fireAngle) * fireSpeed, cos(fireAngle) * fireSpeed);
      Fireball bullet = Fireball(
          position: firePosition, velocity: fireballVelocity, angle: game.playerData.aim.value, speed: fireSpeed);
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
    game.playerData.sword.value = nextSword;
    _sword?.value = nextSword.triggerIndex.toDouble();
    _swordTriggers[nextSword.triggerIndex]?.fire();
    game.playerData.sword.value = nextSword;
  }

  @override
  void onRemove() {
    print('PlayerAnimationComponent onRemove');
    game.playerData.credits.removeListener(_onMousePositionChanged);
    game.playerData.equipments.removeListener(_onEquipmentsChangeHandler);
    game.playerData.casting.removeListener(_onCastingHandler);
    game.playerData.effects.removeListener(_onEffectsChangeHandler);
    game.playerData.autoAttack.removeListener(_onDoubleTapHandler);

    if (interval != null) interval!.stop();
    if (_savePositionTimer != null) _savePositionTimer!.stop();
    super.onRemove();
  }

  void _onCastingHandler() {
    test1.text = game.playerData.casting.value == null ? 'null' : game.playerData.casting.value!.name;
    if (game.playerData.casting.value != null) {
      final skill = game.playerData.casting.value!;
      _attackTimer = 0;
      if (skill.triggerIndex != null) {
        _skillsTriggers[skill.triggerIndex!]?.fire();

        // Set posture to cast skill
        game.playerData.aim.value = 0;
        lookingConstraint!.rotation = pi / 180;
      }
      if (skill.name == 'Repel') {
        print('Repel');
      } else if (skill.name == 'Guardian Engel') {
        print('Guardian Engel');
      } else if (skill.name == 'Time Walk') {
        print('unser null');
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
        // Future.delayed(Duration(milliseconds: skill.duration.toInt())).then((_) {
        //   print('reset time walk');
        //   _effectsTriggers[0]?.fire();
        // });
      } else if (skill.name == 'Chronosphere') {
        final selectedLocation = game.playerData.selectedLocation.value != null
            ? game.camera.globalToLocal(game.playerData.selectedLocation.value!)
            : null;
        final skillCpmponent = ChronosphereSkillComponent(
            duration: skill.duration,
            delayCast: skill.casttime,
            position: selectedLocation != null ? position + selectedLocation / game.zoom : position);
        parent.parent.add(skillCpmponent);
      } else if (skill.name == 'Requiem of Souls') {
        final skillComponent =
            RequiemOfSoulsSkillComponent(duration: skill.duration, delayCast: skill.casttime, position: position);
        Future.delayed(Duration(milliseconds: skill.casttime.toInt() * 1000)).then((_) {
          parent.parent.add(skillComponent);
        });
      } else if (skill.name == 'Ball Lightning') {
        print('Ball Lightning');
      } else if (skill.name == 'Thunder Strike') {
        print('Thunder Strike');
      }
    }
  }

  void _changeToSword(SwordType type) {
    // print('_changeToSword: $type');
    if (game.playerData.sword.value.type == type) return;
    game.playerData.lastSword.value = game.playerData.sword.value;
    final newSword = game.getEquipments().firstWhere((e) => e is Sword && e.type == type) as Sword;
    game.playerData.sword.value = newSword;

    final triggerIndex = newSword.triggerIndex;
    _sword?.value = triggerIndex.toDouble();
    _swordTriggers[triggerIndex]?.fire();
  }

  void _onEffectsChangeHandler() {
    _effectsTriggers[0]?.fire();
    final effects = game.playerData.effects.value;
    for (var e in effects) {
      // print(e);
      if (e.name == 'purified') {
        game.playerData.health.value =
            game.playerData.health.value + 30 < 100 ? game.playerData.health.value + 30 : 100;
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

  void _onDoubleTapHandler() {
    isAutoAttack = true;
    onAttackDelay = true;
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
          position: Vector2.all(radius),
          anchor: Anchor.centerLeft,
          paint: Paint()..color = const Color(0x00FFFFFF),
        );

  @override
  Future<void> onLoad() async {
    // Add a hitbox to the component
    final hitbox = PolygonHitbox(vertices, position: Vector2(size.x / 2, size.y / 2), anchor: Anchor.center);
    add(hitbox);
  }
}
