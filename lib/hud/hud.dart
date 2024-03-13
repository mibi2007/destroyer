import 'dart:async';
import 'dart:math';

import 'package:destroyer/flame_game/game_world.dart';
import 'package:destroyer/models/skills.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../flame_game/components/equipment.dart';
import '../flame_game/components/equipments/armor.dart';
import '../flame_game/components/equipments/weapon.dart';
import '../flame_game/components/skills.dart';
import '../flame_game/game.dart';
import '../models/equipments.dart';
import '../overlays/pause_menu.dart';
import 'attack_button.dart';
import 'jump_button.dart';

const skillGap = 8.0;
const skillSize = 32.0;
const effectSize = 32.0;
const effectGap = -14.0;

class Hud extends PositionComponent
    with HasGameReference<DestroyerGame>, HasWorldReference<DestroyerGameWorld>, KeyboardHandler {
  late final TextComponent creditTextComponent;
  late final TextComponent healthTextComponent;
  late final RectangleComponent healthBarComponent;
  late final JoystickComponent joystick;
  final List<EquipmentComponent> equipments = [];
  final List<SkillComponent> skills = [];
  final List<EffectComponent> effects = [];
  final List<EquipmentComponent> inventory = [];
  final effect = GlowEffect(
    10.0,
    EffectController(duration: 3),
  );

  // Skill? selectedSkill;
  LogicalKeyboardKey? lastKeyPress;
  late final HudCursor cursor;
  AttackButton? attackButton;

  Hud({super.children, super.priority});

  @override
  bool get debugMode => false;
  final backgroundPaint = BasicPalette.white.withAlpha(40).paint();

  @override
  Future<void> onLoad() async {
    cursor = HudCursor();
    add(cursor);
    // print('Loading hud');
    add(SpriteComponent.fromImage(
      game.images.fromCache('assets/images/hud/hud.png'),
      size: Vector2(game.fixedResolution.x, 240 * 330 / 640),
      position: Vector2(0, game.fixedResolution.y - 240 * 330 / 640),
      priority: 2,
    ));
    final artboard = await loadArtboard(RiveFile.asset('assets/animations/character.riv'));
    final controller = StateMachineController.fromArtboard(artboard, 'movesStateMachine');
    artboard.addController(controller!);
    healthBarComponent = RectangleComponent.fromRect(const Rect.fromLTWH(0, 0, 150, 11),
        paint: Paint()..color = const Color(0xFF45c640));
    await add(RectangleComponent.fromRect(const Rect.fromLTWH(60, 20, 150, 11),
        paint: Paint()..color = const Color(0xFF1d2810))
      ..add(healthBarComponent));
    // add(
    //   CircleComponent(
    //       position: Vector2(5, 10),
    //       radius: 16,
    //       paint: Paint()
    //         ..color = const Color(0xFFFFFFFF)
    //         ..strokeWidth = 2
    //         ..style = PaintingStyle.stroke),
    // );

    healthTextComponent = TextComponent(
      text: '100/100',
      position: Vector2(100, 22),
      textRenderer: TextPaint(
          style: const TextStyle(
        fontSize: 8,
        color: Color(0xFFFFFFFF),
        fontFamily: 'Press Start 2P',
      )),
    );
    await add(healthTextComponent);
    add(RectangleComponent(size: Vector2(width / 2, 10), position: Vector2(0, 0), priority: 0));
    add(SpriteComponent.fromImage(
      game.images.fromCache('assets/images/hud/avatar-frame.png'),
      srcSize: Vector2(200, 200),
      size: Vector2(70, 70),
      position: Vector2(-5, 2),
      priority: 1,
    ));
    final player = RiveComponent(
      artboard: artboard,
      anchor: Anchor.center,
      position: Vector2(24, 60),
      size: Vector2(560, 560),
      priority: 0,
    );
    add(ClipComponent.circle(
      children: [
        CircleComponent(
            position: Vector2(20, 20),
            radius: 22,
            children: [player],
            paint: Paint()..color = const Color.fromRGBO(0, 0, 0, 0.5),
            priority: 0,
            anchor: Anchor.center),
      ],
      size: Vector2(44, 44),
      position: Vector2(32, 35),
      anchor: Anchor.center,
      priority: 0,
    ));
    creditTextComponent = TextComponent(
        text: 'x${game.getCredits()}',
        position: Vector2(18, 4),
        textRenderer: TextPaint(
            style: const TextStyle(
          fontSize: 8,
          color: Color(0xFFFFFFFF),
          fontFamily: 'Press Start 2P',
        )));
    await add(SpriteComponent.fromImage(
      game.spriteSheet,
      srcPosition: Vector2(3 * 32, 0),
      srcSize: Vector2.all(32),
      position: Vector2(66, 2),
      size: Vector2.all(16),
    )..add(creditTextComponent));
    joystick = PlayerJoystick(
      knob: SpriteComponent.fromImage(
          game.images.fromCache(
            'assets/images/hud/pad.png',
          ),
          srcSize: Vector2.all(100),
          size: Vector2(game.screenSize.height * 0.2, game.screenSize.height * 0.2)),
      background: CircleComponent(radius: game.screenSize.height * 0.2, paint: backgroundPaint),
      // margin: const EdgeInsets.only(left: 40, bottom: 40),
      position: Vector2(game.screenSize.height * 0.2 + 20, game.screenSize.height - game.screenSize.height * 0.2 - 40),
      size: 200,
      priority: 3,
    );
    // size = Vector2.all(100);
    // add(RectangleComponent.square(size: 100, position: Vector2(100, 100))..add(joystick));
    if (game.isMobile) {
      add(joystick);
      attackButton = AttackButton(
        position: Vector2(game.fixedResolution.x - 160, game.screenSize.height - 180),
        size: Vector2.all(64),
      );
      add(attackButton!);
      add(JumpButton(
        position: Vector2(game.fixedResolution.x - 230, game.screenSize.height - 130),
        size: Vector2.all(64),
      ));
    }

    game.playerData.credits.addListener(onCreditChange);
    game.playerData.health.addListener(onHealthChange);
    game.playerData.sword.addListener(onSwordChangeHandler);
    game.playerData.equipments.addListener(_onEquipmentsChangeHandler);
    game.playerData.effects.addListener(_onEffectsChangeHandler);
    game.playerData.currentMousePosition.addListener(_mouseMoveHandler);
    game.playerData.inventory.addListener(_onInventoryChangeHandler);

    _onEquipmentsChangeHandler();
    _onInventoryChangeHandler();
  }

  void _mouseMoveHandler() {
    cursor.position = game.playerData.currentMousePosition.value / game.zoom;
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.escape)) {
        game.pauseEngine();
        game.overlays.add(PauseMenu.id);
      } else if (keysPressed.contains(LogicalKeyboardKey.keyQ)) {
        final skill = game.playerData.sword.value.skills.firstWhere((s) => s.keyboard == 'Q');
        castSkill(skill);
      } else if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
        final skill = game.playerData.sword.value.skills.firstWhere((s) => s.keyboard == 'E');
        castSkill(skill);
        // } else if (keysPressed.contains(LogicalKeyboardKey.keyR)) {
        //   _castSkill('R');
      }
    }
    return true;
  }

  void _cancelSkill(Skill skill, int index) {
    game.playerData.effects.remove(skill.effects.first, shouldNotify: true);
  }

  Future<void> castSkill(Skill skill) async {
    // final sword = game.getEquipments().firstWhere((e) {
    //   return (e is Sword) && e.type == skill.swordType;
    // }) as Sword;

    // game.playerData.changeSwordAnimation.value = sword.triggerIndex;

    // // await Future.delayed(Duration(milliseconds: 5000));
    // return;
    if (game.playerData.casting.value != null) return;
    if (skill.cooldown == 0 && !skill.autoCast) return;
    final index = game.playerData.skills.value.where((s) => s.cooldown != 0).toList().indexWhere((s) => s == skill);
    // print(index);
    // print(game.playerData.skillCountdown);

    // if (game.playerData.skillCountdown.value[index]) {
    //   if (skill.autoCast) _cancelSkill(skill);
    //   return;
    // }
    // else{

    //   if (skill.autoCast) game.playerData.skillCountdown.updateAt(index, true);
    //   return;
    // }
    // if (skill.autoCast) {

    if (game.playerData.skillCountdown.value[index]) {
      if (skill.autoCast) _cancelSkill(skill, index);

      return;
    }
    // } else {
    //   if (game.playerData.skillCountdown.value[index]) {
    //     return;
    //   }
    // }
    if (game.isMobile && attackButton != null) attackButton!.stop();
    add(TimerComponent(
      period: skill.castTime, // The period in seconds
      onTick: () {
        if (skill.effects.isNotEmpty) {
          // print(skill.effects);
          for (var effect in skill.effects) {
            if (effect.duration != 0) {
              game.playerData.effects.addAll([effect]);
              add(TimerComponent(
                period: effect.duration, // The period in seconds
                onTick: () {
                  game.playerData.effects.remove(effect, shouldNotify: true);
                },
                removeOnFinish: true,
              ));
            }
          }
          // print(effect);
          // print(game.playerData.effects.value);
        }
        game.playerData.casting.value = null;
        // print('set null');
      },
      removeOnFinish: true,
    ));
    add(TimerComponent(
      period: skill.cooldown, // The period in seconds
      onTick: () {
        game.playerData.skillCountdown.updateAt(index, false);
      },
      removeOnFinish: true,
    ));

    game.playerData.casting.value = skill;
    game.playerData.skillCountdown.updateAt(index, true);

    final skillComponent = skills.firstWhere((c) => c.skill == skill);
    skillComponent.startCountdown(skill.cooldown);
  }

  @override
  void onRemove() {
    game.playerData.credits.removeListener(onCreditChange);
    game.playerData.health.removeListener(onHealthChange);
    game.playerData.sword.removeListener(onSwordChangeHandler);
    game.playerData.equipments.removeListener(_onEquipmentsChangeHandler);
    game.playerData.effects.removeListener(_onEffectsChangeHandler);
    game.playerData.inventory.removeListener(_onInventoryChangeHandler);
    super.onRemove();
  }

  // Updates score text on hud.
  void onCreditChange() {
    creditTextComponent.text = 'x${game.getCredits()}';
  }

  // Updates health text on hud.
  void onHealthChange() {
    healthTextComponent.text = '${max(game.playerData.health.value, 0)}/100';
    healthBarComponent.width = 150 * max(game.playerData.health.value, 0) / 100;

    if (game.playerData.health.value <= 0) {
      // AudioManager.stopBgm();
      // game.pauseEngine();
      final timeWalkSkillIndex = skills.indexWhere((s) => s.skill == Skills.timeWalk);
      if (timeWalkSkillIndex == -1 || game.playerData.skillCountdown.value[timeWalkSkillIndex]) {
        game.playerData.isDead.value = true;
      } else {
        game.playerData.revertDead.trigger();
        if (game.isMobile) castSkill(Skills.timeWalk);
      }
    }
  }

  Future<void> _onEquipmentsChangeHandler() async {
    removeAll([...equipments, ...skills, ...inventory]);
    equipments.clear();
    skills.clear();
    int index = 0;
    if (game.getEquipments().isEmpty) return;
    for (var equipment in game.getEquipments()) {
      if (equipment is Sword) {
        final swordImage = game.images.fromCache(equipment.iconAsset);
        final swordComp = SwordComponent(
          item: equipment,
          position: Vector2(game.fixedResolution.x - 105 + 26 * index.toDouble(), game.fixedResolution.y - 32),
          size: Vector2.all(36),
          sprite: Sprite(swordImage),
          canPickedUp: false,
        );
        await add(swordComp);
        equipments.add(swordComp);

        skills.addAll(
            equipment.skills.map((skill) => SkillComponent(skill, size: Vector2.all(skillSize), position: position)));
        game.playerData.skills.value.addAll(equipment.skills);
        game.playerData.skillCountdown.value.addAll(equipment.skills.where((s) => s.cooldown != 0).map((_) => false));
        index++;
      }
    }
    renderSkills();
  }

  Future<void> onSwordChangeHandler() async {
    // print('update sword');
    final newSword = game.playerData.sword.value;
    final newIndex = equipments.indexWhere(((c) => (c.item as Sword).type == newSword.type));

    for (var i = 0; i < equipments.length; i++) {
      for (final e in equipments[i].children.whereType<Effect>()) {
        // if (e is ColorEffect) {
        e.removeFromParent();
        // }
      }
      if (i != newIndex) {
        await equipments[i].add(InactiveEffect());
        equipments[i].add(ScaleEffect.to(
          Vector2.all(0.5),
          EffectController(duration: 0.1),
        ));
      }
    }
    if (newIndex == -1) return;
    await equipments[newIndex].add(SelectAndActiveEffect());
    equipments[newIndex].add(ScaleEffect.to(
      Vector2.all(1),
      EffectController(duration: 0.1),
    ));

    updateSkill();

    if (game.playerData.lastSword.value != null && game.playerData.lastSword.value!.skills.isNotEmpty) {
      final removeEffects = game.playerData.lastSword.value!.skills
          .map((s) => s.effects)
          .reduce((combine, effects) => [...combine, ...effects]);
      if (removeEffects.isNotEmpty) {
        for (var element in removeEffects) {
          game.playerData.effects
              .remove(element, shouldNotify: removeEffects.indexOf(element) == removeEffects.length - 1);
        }
      }
    }

    if (newSword.skills.isNotEmpty) {
      final passiveSkills = newSword.skills.where((s) => s.passive);
      if (passiveSkills.isNotEmpty) {
        final passiveEffects =
            passiveSkills.map((e) => e.effects).reduce((combine, effects) => [...combine, ...effects]);
        // print(passiveEffects);
        game.playerData.effects.addAll(passiveEffects);
      }
      if (!game.isMobile) {
        final autoCasts = game.playerData.sword.value.skills.where((s) => s.autoCast).toList();
        // print(autoCasts);
        if (autoCasts.isNotEmpty) {
          for (final skill in autoCasts) {
            // final skill = game.playerData.sword.value.skills..firstWhere((s)=>s.autoCast);
            // print(index);
            if (skill.keyboard != null) castSkill(skill);
          }
        }
      }
    }
  }

  Future<void> renderSkills() async {
    // print('remove skills');
    children.whereType<SkillFrame>().forEach((e) => remove(e));
    final renderSkills = skills.where((s) => !(s.skill.cooldown == 0.0 && s.skill.passive)).toList();
    for (var i = 0; i < renderSkills.length; i++) {
      final com = renderSkills[i];

      // Position
      final x = (game.fixedResolution.x - (renderSkills.length - 1) * skillGap - skillSize * renderSkills.length) / 2;
      com.position = Vector2(x + i * (skillSize + skillGap), game.fixedResolution.y - skillSize / 2 - 7);
      // add(skillFrame..position = com.position);
      add(SkillFrame(game.images.fromCache('assets/images/skills-and-effects/skill-frame.png'),
              skillKey: com.skill.keyboard)
            ..position = com.position
          // ..priority = 1,
          );
      // final skillKey = 'A';
      // if (skillKey != null) {
      //   parent!.add(TextComponent(
      //     text: skillKey,
      //     position: com.position - Vector2(0, 30),
      //     textRenderer: TextPaint(style: const TextStyle(fontSize: 100, color: Color(0xFFFFFFFF))),
      //     priority: 2,
      //   ));
      // }
    }
    await addAll(skills);
  }

  Future<void> updateSkill() async {
    // print('update skills');
    for (var i = 0; i < skills.length; i++) {
      final com = skills[i].iconComponent;

      // Reset the color effect
      for (final e in com.children.whereType<Effect>()) {
        com.remove(e);
      }
      if (game.isMobile) return;
      if (game.playerData.sword.value.skills.contains(skills[i].skill)) {
        com.add(ActiveColorEffect());
      } else {
        await com.add(InactiveEffect());
      }
    }
  }

  void _onEffectsChangeHandler() {
    removeAll(effects);
    effects.clear();
    final skillEffects = game.playerData.effects.value;
    if (skillEffects.isNotEmpty) {
      for (var i = 0; i < skillEffects.length; i++) {
        // if (effects.length < i + 1) {
        // final position = Vector2(x + i * (skillSize + skillGap), game.fixedResolution.y - skillSize / 2 - 7);
        final effectPosition = Vector2(76 + i * (effectSize + effectGap), 44);
        final effectComp = EffectComponent(skillEffects[i], position: effectPosition, size: Vector2.all(effectSize));
        if (skillEffects[i].name == 'Requiem of Souls') {
          effectComp.count = game.playerData.souls.value;
        }
        effects.add(effectComp);
        add(effectComp);
        if (skillEffects[i].duration > 0) {
          effectComp.startCountdown(skillEffects[i].duration);
        }
        // }
      }
    }
    _renderEquipments();
  }

  _renderEquipments() {
    final skillEffects = game.playerData.effects.value;
    final effectWidth = (effectSize + effectGap) * skillEffects.length;
    for (final item in inventory) {
      item.position = Vector2(76 + effectWidth + (effectSize + effectGap) * inventory.indexOf(item).toDouble(), 44);
      add(item);
    }
  }

  void _onInventoryChangeHandler() {
    removeAll(inventory);
    inventory.clear();

    for (final armor in game.playerData.inventory.value) {
      if (armor is Armor) {
        final armorImage = game.images.fromCache(armor.iconAsset);
        final armorComp = ArmorComponent(
          item: armor,
          position: Vector2.zero(),
          size: Vector2.all(20),
          sprite: Sprite(armorImage, srcSize: Vector2.all(256)),
          canPickedUp: false,
        );
        inventory.add(armorComp);
      }
    }

    _renderEquipments();
    game.playerData.armor.value = 5 * game.playerData.inventory.value.length;
  }
}

class ActiveColorEffect extends ColorEffect {
  ActiveColorEffect()
      : super(
          const Color(0x00000000),
          EffectController(
            duration: 0,
          ),
          opacityTo: 0,
        );
}

// class ActiveScaleEffect extends ScaleEffect {
//   ActiveScaleEffect()
//       : super.by(Vector2.all(1),
//   EffectController(duration: 0.3))(

//       )
//           ;
// }

class InactiveEffect extends ColorEffect {
  InactiveEffect()
      : super(
          const Color(0xFF000000),
          EffectController(
            duration: 0,
          ),
          // Means, applies from 0% to 80% of the color
          opacityTo: 0.3,
        );
}

class SelectAndActiveEffect extends ColorEffect {
  SelectAndActiveEffect()
      : super(
          const Color(0xFFFFFFFF),
          EffectController(
            duration: .5,
            reverseDuration: .5,
            infinite: true,
          ),
          // Means, applies from 0% to 80% of the color
          opacityTo: 0.5,
        );
}

class SkillFrame extends SpriteComponent with HasGameRef<DestroyerGame> {
  final String? skillKey;
  SkillFrame(super.image, {this.skillKey})
      : super.fromImage(
          srcSize: Vector2.all(88),
          anchor: Anchor.center,
          size: Vector2.all(skillSize + 6),
          position: Vector2.all(300),
          priority: 1,
        );

  @override
  FutureOr<void> onLoad() {
    if (skillKey != null && !game.isMobile) {
      add(TextComponent(
        text: skillKey,
        position: Vector2(width - 10, height - 13),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 9,
            color: Color.fromRGBO(0, 0, 0, 0.5),
            fontWeight: FontWeight.bold,
            fontFamily: 'Press Start 2P',
          ),
        ),
        priority: 4,
      ));
      add(TextComponent(
        text: skillKey,
        position: Vector2(width - 10, height - 12),
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 8,
            color: Color(0xFFFFFFFF),
            fontFamily: 'Press Start 2P',
          ),
        ),
        priority: 5,
      ));
    }
  }
}

class HudCursor extends CircleComponent with CollisionCallbacks {
  HudCursor()
      : super(
          radius: 5,
          anchor: Anchor.center,
          paint: Paint()
            ..color = const Color(0x00000000)
            ..style = PaintingStyle.fill,
        );

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    add(CircleHitbox());
  }
}

class PlayerJoystick extends JoystickComponent with ParentIsA<Hud> {
  // @override
  // DestroyerGame game;
  late final Timer _timer;
  PlayerJoystick(
      {required super.knob,
      required super.background,
      required super.position,
      required super.size,
      required super.priority});

  @override
  Future<void> onLoad() {
    _timer = Timer(
      0.045, // The period in seconds
      onTick: () {
        parent.game.playerData.joystickDelta.value = relativeDelta;
      },
      repeat: true,
    );
    return super.onLoad();
  }

  // @override
  // bool onDragUpdate(DragUpdateEvent event) {
  //   parent.game.playerData.joystickDelta.value = relativeDelta;
  //   return super.onDragUpdate(event);
  // }

  // @override
  // bool onDragEnd(DragEndEvent _) {
  //   print('end');
  //   return super.onDragEnd(_);
  // }

  // @override
  // bool onDragStart(DragStartEvent event) {
  //   print('start');
  //   return super.onDragStart(event);
  // }
  @override
  void update(double dt) {
    _timer.update(dt);
    super.update(dt);
  }

  @override
  void onRemove() {
    _timer.stop();
    super.onRemove();
  }
}
