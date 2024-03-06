import 'package:destroyer/models/equipments.dart';

class Skill {
  final String name;
  final String description;
  final String requirement;
  final double cooldown;
  final double damage;
  final double castTime;
  final bool autoCast;
  final String sprite;
  final String? keyboard;
  final SwordType? swordType;
  double duration;
  List<SkillEffect> effects = [];
  int? triggerIndex;
  bool passive;

  Skill({
    required this.name,
    required this.description,
    required this.requirement,
    required this.cooldown,
    required this.castTime,
    required this.damage,
    required this.sprite,
    required this.effects,
    this.autoCast = false,
    this.duration = 0,
    this.swordType,
    this.triggerIndex,
    this.passive = false,
    this.keyboard,
  });

  // Define equality operator for 2 skills
  @override
  bool operator ==(Object other) {
    if (other is Skill) {
      return name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  // ToString method for debugging
  @override
  String toString() {
    return 'Skill: $name';
  }
}

class Skills {
  // Purifier Sword's skills
  static final repel = Skill(
    swordType: SwordType.purifier,
    name: 'Repel',
    sprite: 'assets/images/skills-and-effects/Repel_icon.webp',
    description: 'Heal you and detoxify poison',
    requirement: 'Purifier Sword Lv.3',
    cooldown: 5,
    castTime: 1,
    damage: 0,
    effects: [SkillEffects.purified],
    triggerIndex: 0,
    keyboard: 'Q',
  );

  static final guardianEngel = Skill(
    swordType: SwordType.purifier,
    sprite: 'assets/images/skills-and-effects/Guardian_Angel_icon.webp',
    name: 'Guardian Engel',
    description: 'Purify all objects on screen',
    requirement: 'Purifier Sword Lv.4',
    cooldown: 10,
    castTime: 2,
    damage: 0,
    effects: [SkillEffects.guardianEngel],
    triggerIndex: 1,
    keyboard: 'E',
  );

  // Time Sword's skills
  static final timeWalk = Skill(
    swordType: SwordType.time,
    sprite: 'assets/images/skills-and-effects/Time_Walk_icon.webp',
    name: 'Time Walk',
    description: 'Backtracking the last 2 seconds for you or revert lifetime of a destroyed object',
    requirement: 'Time Sword Lv.3',
    cooldown: 5,
    castTime: 0,
    damage: 0,
    duration: 0.5,
    triggerIndex: 2,
    effects: [SkillEffects.timeWalk0s5],
    keyboard: 'Q',
    autoCast: true,
  );

  static final chronosphere = Skill(
    swordType: SwordType.time,
    sprite: 'assets/images/skills-and-effects/Chronosphere_icon.webp',
    name: 'Chronosphere',
    description:
        'Creates a blister in spacetime, trapping all units caught in its sphere of influence and causes you to move very quickly inside it',
    requirement: 'Time Sword Lv.4',
    cooldown: 10,
    castTime: 0.5,
    duration: 5,
    damage: 0,
    triggerIndex: 3,
    effects: [SkillEffects.chronosphere],
    keyboard: 'E',
  );

  static final fireball = Skill(
    swordType: SwordType.flame,
    sprite: 'assets/images/skills-and-effects/Fireblast_icon.webp',
    name: 'Fireball',
    description: 'Your sword will release a fireball to attack the target',
    requirement: 'Flame Sword Lv.2',
    cooldown: 0,
    castTime: 0,
    damage: 0,
    passive: true,
    effects: [SkillEffects.fireball],
  );

  static final flameCloak = Skill(
    swordType: SwordType.flame,
    sprite: 'assets/images/skills-and-effects/Flame_Cloak_icon.webp',
    name: 'Flame Cloak',
    description: 'Turn you into a flying unit upon use. You can fly over impassable terrain but not under the sea',
    requirement: 'Flame Sword Lv.3',
    cooldown: 15,
    castTime: 0,
    damage: 0,
    autoCast: true,
    effects: [SkillEffects.fly],
    keyboard: 'Q',
  );

  static final requiemOfSouls = Skill(
    swordType: SwordType.flame,
    sprite: 'assets/images/skills-and-effects/Requiem_of_Souls_icon.webp',
    name: 'Requiem of Souls',
    description: 'Release souls hit all enemy in the screen with damage from all souls you have collected',
    requirement: 'Flame Sword Lv.4',
    duration: 3,
    cooldown: 10,
    castTime: 2,
    damage: 200,
    triggerIndex: 4,
    keyboard: 'E',
    passive: true,
    effects: [SkillEffects.souls],
  );

  static final ballLightning = Skill(
    swordType: SwordType.lightning,
    sprite: 'assets/images/skills-and-effects/Ball_Lightning_icon.webp',
    name: 'Ball Lightning',
    description: 'Becomes volatile electricity, charging across the battlefield until reaches your target',
    requirement: 'Lightning Sword Lv.3',
    cooldown: 1,
    castTime: 0,
    damage: 100,
    triggerIndex: 5,
    keyboard: 'Q',
    effects: [SkillEffects.ballLightning],
  );

  static final thunderStrike = Skill(
    swordType: SwordType.lightning,
    sprite: 'assets/images/skills-and-effects/Thunder_Strike_icon.webp',
    name: 'Thunder Strike',
    description: 'You control the lightning, make a massive damage to all enemies',
    requirement: 'Lightning Sword Lv.4',
    cooldown: 10,
    castTime: 4,
    damage: 100,
    triggerIndex: 6,
    keyboard: 'E',
    effects: [],
  );

  static final coolFeet = Skill(
    sprite: 'assets/images/skills-and-effects/Cold_Feet_icon.webp',
    name: 'Cool Feet',
    description: 'It is used to clear the path you want to go by frezzing target, can use in deep sea',
    requirement: 'Ocean Stone',
    cooldown: 5,
    castTime: 1,
    damage: 0,
    duration: 10,
    keyboard: 'Q',
    effects: [],
  );
}

class SkillEffect {
  final String name;
  final String description;
  final int? triggerIndex;
  final double? slow;
  final String sprite;
  final bool canDebuff;
  final bool isGlobal;
  final double duration;
  final int? healPoint;

  SkillEffect({
    required this.name,
    required this.description,
    this.triggerIndex,
    required this.duration,
    this.slow,
    required this.sprite,
    this.canDebuff = false,
    this.isGlobal = false,
    this.healPoint = 0,
  });

  @override
  bool operator ==(Object other) {
    if (other is SkillEffect) {
      return name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'SkillEffect: $name';
  }
}

class SkillEffects {
  static final purified = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Repel_icon.webp',
    name: 'purified',
    description: 'Effect of Repel and Guardian Engel, receive 30 health points and detoxify poison',
    triggerIndex: 1,
    canDebuff: true,
    duration: 0.5,
    healPoint: 30,
  );
  static final guardianEngel = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Guardian_Angel_icon.webp',
    name: 'guardianEngel',
    description: 'Effect of Repel and Guardian Engel, receive 30 health points and detoxify poison',
    triggerIndex: 1,
    canDebuff: true,
    duration: 0.5,
    healPoint: 100,
  );
  static final poisoned = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Poison_Sting_icon.webp',
    name: 'poisoned',
    description: 'Effect of Poison, lose 5 health points per second',
    triggerIndex: 2,
    canDebuff: true,
    duration: 10,
    slow: 0.8,
  );
  static final invincible0s5 = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Spell_Immunity_icon.webp',
    name: 'invincible',
    description:
        'Effect of Time Walk, backtracking the last 2 seconds for you or revert lifetime of a destroyed object',
    duration: 0.5,
    triggerIndex: 3,
  );
  static final invincible5s = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Spell_Immunity_icon.webp',
    name: 'invincible',
    description:
        'Effect of Time Walk, backtracking the last 2 seconds for you or revert lifetime of a destroyed object',
    duration: 5,
    triggerIndex: 3,
  );
  static final timeWalk0s5 = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Time_Walk_icon.webp',
    name: 'timeWalk',
    description: 'Effect of Time Walk, causes you to move very quickly',
    duration: 0.5,
  );
  static final timeWalk5s = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Time_Walk_icon.webp',
    name: 'timeWalk',
    description: 'Effect of inside a blister of Chronosphere, causes you to move very quickly',
    duration: 5,
  );
  static final chronosphere = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Chronosphere_icon.webp',
    name: 'chronosphere',
    description: 'Effect of casting Chronosphere',
    duration: 5,
  );
  static final fly = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Flame_Cloak_icon.webp',
    name: 'fly',
    description: 'Effect of Flame Cloak, turn you into a flying unit for 10 seconds',
    triggerIndex: 5,
    duration: 10,
  );
  static final fireball = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Fireblast_icon.webp',
    name: 'fireball',
    description: 'Effect of Fireball, your sword will release a fireball to attack the target',
    duration: 0,
  );
  static final souls = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Requiem_of_Souls_icon.webp',
    name: 'souls',
    description:
        'Effect of Requiem of Souls, release souls hit all enemy in the screen with damage from all souls you have collected',
    duration: 0,
  );
  static final ballLightning = SkillEffect(
    sprite: 'assets/images/skills-and-effects/Ball_Lightning_icon.webp',
    name: 'ballLightning',
    description:
        'Effect of Ball Lightning, becomes volatile electricity, charging across the battlefield until reaches your target',
    duration: 1.5,
  );
}
