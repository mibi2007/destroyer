import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/text.dart';
import 'package:flame_rive/flame_rive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../flame_game/components/skills.dart';
import '../flame_game/components/weapon.dart';
import '../flame_game/game.dart';
import '../models/equipments.dart';
import '../overlays/game_over.dart';
import '../overlays/pause_menu.dart';

const skillGap = 8.0;
const skillSize = 32.0;
const effectSize = 32.0;
const effectGap = -14.0;

class Hud extends PositionComponent with HasGameReference<DestroyerGame>, KeyboardHandler {
  late final TextComponent creditTextComponent;
  late final TextComponent healthTextComponent;
  late final RectangleComponent healthBarComponent;
  final List<EquipmentComponent> equipments = [];
  final List<SkillComponent> skills = [];
  final effect = GlowEffect(
    10.0,
    EffectController(duration: 3),
  );

  // Skill? selectedSkill;
  LogicalKeyboardKey? lastKeyPress;

  Hud({super.children, super.priority});

  @override
  bool get debugMode => false;

  @override
  Future<void> onLoad() async {
    // print('Loading hud');
    add(SpriteComponent.fromImage(
      game.images.fromCache('hud/hud.png'),
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
      position: Vector2(110, 21),
      textRenderer: TextPaint(style: const TextStyle(fontSize: 8, color: Color(0xFFFFFFFF))),
    );
    await add(healthTextComponent);
    add(RectangleComponent(size: Vector2(width / 2, 10), position: Vector2(0, 0), priority: 0));
    add(SpriteComponent.fromImage(
      game.images.fromCache('hud/avatar-frame.png'),
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
        text: 'x0',
        position: Vector2(18, 4),
        textRenderer: TextPaint(style: const TextStyle(fontSize: 8, color: Color(0xFFFFFFFF))));
    await add(SpriteComponent.fromImage(
      game.spriteSheet,
      srcPosition: Vector2(3 * 32, 0),
      srcSize: Vector2.all(32),
      position: Vector2(66, 2),
      size: Vector2.all(16),
    )..add(creditTextComponent));

    game.playerData.credit.addListener(onCreditChange);
    game.playerData.health.addListener(onHealthChange);
    game.playerData.sword.addListener(onSwordChange);
    game.playerData.equipments.addListener(onEquipmentsChange);
    game.playerData.effects.addListener(onEffectsChange);

    onEquipmentsChange();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is RawKeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.escape)) {
        game.pauseEngine();
        game.overlays.add(PauseMenu.id);
      } else if (keysPressed.contains(LogicalKeyboardKey.keyQ)) {
        _castSkill(0);
      } else if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
        _castSkill(1);
      } else if (keysPressed.contains(LogicalKeyboardKey.keyR)) {
        _castSkill(2);
      }
    }
    return true;
  }

  void _castSkill(int skillIndex) {
    if (skillIndex > game.playerData.sword.value.skills.length - 1) return;
    if (game.playerData.casting.value != null) return;
    final skill = game.playerData.sword.value.skills[skillIndex];
    final index = game.playerData.skills.value.indexWhere((s) => s == skill);
    // if (skill.triggerIndex != null) _skillsTriggers[skill.triggerIndex!]?.fire();
    Future.delayed(Duration(milliseconds: skill.casttime.toInt() * 1000)).then((_) {
      if (game.playerData.casting.value != null && game.playerData.casting.value!.effect != null) {
        final effect = game.playerData.casting.value!.effect!;
        game.playerData.effects.addAll([effect]);
        Future.delayed(Duration(milliseconds: (effect.duration * 1000).toInt()), () {
          // print('removed effect');
          game.playerData.effects.remove(effect);
        });
      }
      game.playerData.casting.value = null;
      // print('set null');
    });
    Future.delayed(Duration(seconds: skill.countdown.toInt()), () {
      game.playerData.skillCountdown.updateAt(index, false);
    });
    if (skill.passive) return;
    if (skill.countdown == 0) return;
    if (game.playerData.skillCountdown.value[index]) return;
    game.playerData.casting.value = skill;
    game.playerData.skillCountdown.updateAt(index, true);

    final skillComponent = skills.firstWhere((c) => c.skill == skill);
    skillComponent.startCountdown(skill.countdown);
  }

  // Detect if player cast same skill key twice to target self
  // void _selfCast(int skillIndex) {
  //   lastKeyPress = null;
  //   _castSkill(skillIndex);
  // }

  // _selectSkill(int indexOfSkillInSword) {
  //   game.playerData.selectedSkill.value = game.playerData.sword.value.skills[indexOfSkillInSword];
  // }

  @override
  void onRemove() {
    print('onRemove');
    game.playerData.credit.removeListener(onCreditChange);
    game.playerData.health.removeListener(onHealthChange);
    game.playerData.sword.removeListener(onSwordChange);
    game.playerData.equipments.removeListener(onEquipmentsChange);
    game.playerData.effects.removeListener(onEffectsChange);
    super.onRemove();
  }

  // Updates score text on hud.
  void onCreditChange() {
    creditTextComponent.text = 'x${game.playerData.credit.value}';
  }

  // Updates health text on hud.
  void onHealthChange() {
    healthTextComponent.text = '${game.playerData.health.value}/100';
    healthBarComponent.width = 150 * game.playerData.health.value / 100;

    // Load game over overlay if health is zero.
    if (game.playerData.health.value <= 0) {
      // AudioManager.stopBgm();
      game.pauseEngine();
      game.overlays.add(GameOver.id);
    }
  }

  Future<void> onEquipmentsChange() async {
    removeAll([...equipments, ...skills]);
    equipments.clear();
    skills.clear();
    int index = 0;
    if (game.playerData.equipments.value.isEmpty) return;
    for (var equipment in game.playerData.equipments.value) {
      if (equipment is Sword) {
        final swordImage = game.images.fromCache(equipment.iconAsset);
        final swordComp = SwordComponent(
          item: equipment,
          position: Vector2(game.fixedResolution.x - 105 + 26 * index.toDouble(), game.fixedResolution.y - 32),
          size: Vector2.all(36),
          sprite: Sprite(swordImage),
        );
        await add(swordComp);
        equipments.add(swordComp);

        skills.addAll(
            equipment.skills.map((skill) => SkillComponent(skill, size: Vector2.all(skillSize), position: position)));
        game.playerData.skills.value.addAll(equipment.skills);
        game.playerData.skillCountdown.value.addAll(equipment.skills.map((_) => false));
        index++;
      }
    }
    renderSkills();
  }

  Future<void> onSwordChange() async {
    print('update sword');
    final newIndex = equipments.indexWhere(((c) => (c.item as Sword).type == game.playerData.sword.value.type));

    // Make sure the selected sword has been changed completely before adding the effect
    // Future.delayed(const Duration(milliseconds: 500), () {
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
    // });
    updateSkill();

    final autoCasts = game.playerData.sword.value.skills.where((s) => s.autoCast).toList();
    print(autoCasts);
    if (autoCasts.isNotEmpty) {
      for (final skill in autoCasts) {
        final index = game.playerData.sword.value.skills.indexOf(skill);
        print(index);
        _castSkill(index);
      }
    }
  }

  Future<void> renderSkills() async {
    print('remove skills');
    children.whereType<SkillFrame>().forEach((e) => remove(e));
    for (var i = 0; i < skills.length; i++) {
      final com = skills[i];

      // Position
      final x = (game.fixedResolution.x - (skills.length - 1) * skillGap - skillSize * skills.length) / 2;
      com.position = Vector2(x + i * (skillSize + skillGap), game.fixedResolution.y - skillSize / 2 - 7);
      // add(skillFrame..position = com.position);
      add(SkillFrame(game.images.fromCache('skills-and-effects/skill-frame.png'))..position = com.position);
    }
    await addAll(skills);
  }

  Future<void> updateSkill() async {
    print('update skills');
    for (var i = 0; i < skills.length; i++) {
      final com = skills[i].iconComponent;

      // Reset the color effect
      for (final e in com.children.whereType<Effect>()) {
        com.remove(e);
      }

      if (game.playerData.sword.value.skills.contains(skills[i].skill)) {
        com.add(ActiveColorEffect());
      } else {
        await com.add(InactiveEffect());
      }
    }
  }

  void onEffectsChange() {
    print('update effects');
    children.whereType<EffectComponent>().forEach((e) => remove(e));
    final effects = game.playerData.effects.value;
    print(effects);
    for (var i = 0; i < effects.length; i++) {
      // if (effects.length < i + 1) {
      // final position = Vector2(x + i * (skillSize + skillGap), game.fixedResolution.y - skillSize / 2 - 7);
      final effectPosition = Vector2(76 + i * (effectSize + effectGap), 44);
      final effectComp = EffectComponent(effects[i], position: effectPosition, size: Vector2.all(effectSize));
      add(effectComp);
      if (effects[i].duration > 0) {
        print('start countdown');
        effectComp.startCountdown(effects[i].duration);
      }
      // }
    }
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
  SkillFrame(ui.Image image)
      : super.fromImage(
          image,
          srcSize: Vector2.all(88),
          anchor: Anchor.center,
          size: Vector2.all(skillSize + 6),
          position: Vector2.all(300),
          priority: 1,
        );
}
