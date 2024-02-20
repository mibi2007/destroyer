class Skill {
  final String name;
  final String description;
  final String requirement;
  final double countdown;
  final double damage;
  final double casttime;
  final bool autoCast;
  final String sprite;
  final String? keyboard;
  double duration;
  List<SkillEffect> effects = [];
  int? triggerIndex;
  bool passive;

  Skill({
    required this.name,
    required this.description,
    required this.requirement,
    required this.countdown,
    required this.casttime,
    required this.damage,
    required this.sprite,
    this.autoCast = false,
    this.duration = 0,
    required this.effects,
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
    name: 'Repel',
    sprite: 'assets/images/skills-and-effects/Repel_icon.webp',
    description: 'Heal you and detoxify poison',
    requirement: 'Purifier Sword Lv.3',
    countdown: 10,
    casttime: 1,
    damage: 0,
    effects: [SkillEffects.purified],
    triggerIndex: 0,
    keyboard: 'Q',
  );

  static final guardianEngel = Skill(
    sprite: 'assets/images/skills-and-effects/Guardian_Angel_icon.webp',
    name: 'Guardian Engel',
    description: 'Purify all objects on screen',
    requirement: 'Purifier Sword Lv.4',
    countdown: 60,
    casttime: 2,
    damage: 0,
    effects: [SkillEffects.purified],
    triggerIndex: 1,
    keyboard: 'E',
  );

  // Time Sword's skills
  static final timeWalk = Skill(
    sprite: 'assets/images/skills-and-effects/Time_Walk_icon.webp',
    name: 'Time Walk',
    description: 'Backtracking the last 2 seconds for you or revert lifetime of a destroyed object',
    requirement: 'Time Sword Lv.3',
    countdown: 20,
    casttime: 0,
    damage: 0,
    duration: 0.5,
    triggerIndex: 2,
    effects: [SkillEffects.timeWalk0s5],
    keyboard: 'Q',
  );

  static final chronosphere = Skill(
    sprite: 'assets/images/skills-and-effects/Chronosphere_icon.webp',
    name: 'Chronosphere',
    description:
        'Creates a blister in spacetime, trapping all units caught in its sphere of influence and causes you to move very quickly inside it',
    requirement: 'Time Sword Lv.4',
    countdown: 60,
    casttime: 0.5,
    duration: 5,
    damage: 0,
    triggerIndex: 3,
    effects: [SkillEffects.chronosphere],
    keyboard: 'E',
  );

  static final fireball = Skill(
    sprite: 'assets/images/skills-and-effects/Fireblast_icon.webp',
    name: 'Fireball',
    description: 'Your sword will release a fireball to attack the target',
    requirement: 'Flame Sword Lv.2',
    countdown: 1,
    casttime: 0,
    damage: 0,
    passive: true,
    effects: [SkillEffects.fireball],
  );

  static final flameCloak = Skill(
    sprite: 'assets/images/skills-and-effects/Flame_Cloak_icon.webp',
    name: 'Flame Cloak',
    description: 'Turn you into a flying unit upon use. You can fly over impassable terrain but not under the sea',
    requirement: 'Flame Sword Lv.3',
    countdown: 20,
    casttime: 0,
    damage: 0,
    autoCast: true,
    effects: [SkillEffects.fly],
    keyboard: 'E',
  );

  static final requiemOfSouls = Skill(
    sprite: 'assets/images/skills-and-effects/Requiem_of_Souls_icon.webp',
    name: 'Requiem of Souls',
    description: 'Release souls hit all enemy in the screen with damage from all souls you have collected',
    requirement: 'Flame Sword Lv.4',
    duration: 3,
    countdown: 60,
    casttime: 2,
    damage: 100,
    triggerIndex: 4,
    keyboard: 'R',
    passive: true,
    effects: [SkillEffects.souls],
  );

  static final ballLightning = Skill(
    sprite: 'assets/images/skills-and-effects/Ball_Lightning_icon.webp',
    name: 'Ball Lightning',
    description: 'Becomes volatile electricity, charging across the battlefield until reaches your target',
    requirement: 'Lightning Sword Lv.3',
    countdown: 2,
    casttime: 0,
    damage: 100,
    triggerIndex: 5,
    keyboard: 'Q',
    effects: [SkillEffects.ballLightning],
  );

  static final thunderStrike = Skill(
    sprite: 'assets/images/skills-and-effects/Thunder_Strike_icon.webp',
    name: 'Thunder Strike',
    description:
        'You will become the lightning, disapear and can select a place to land, it helps you find more things',
    requirement: 'Lightning Sword Lv.4',
    countdown: 60,
    casttime: 0,
    duration: 2,
    damage: 500,
    triggerIndex: 6,
    keyboard: 'E',
    effects: [],
  );

  static final coolFeet = Skill(
    sprite: 'assets/images/skills-and-effects/Cold_Feet_icon.webp',
    name: 'Cool Feet',
    description: 'It is used to clear the path you want to go by frezzing target, can use in deep sea',
    requirement: 'Ocean Stone',
    countdown: 5,
    casttime: 1,
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

  SkillEffect(
      {required this.name,
      required this.description,
      this.triggerIndex,
      required this.duration,
      this.slow,
      required this.sprite,
      this.canDebuff = false,
      this.isGlobal = false});

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
