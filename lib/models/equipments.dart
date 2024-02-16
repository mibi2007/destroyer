import 'skills.dart';

abstract class Equipment {
  final String name;

  Equipment({required this.name});
}

enum SwordType {
  desolator,
  purifier,
  time,
  flame,
  lightning,
}

class Sword extends Equipment {
  final SwordType type;
  final double damage;
  final int level;
  final List<Skill> skills;
  final double attackSpeed;
  // The index of the trigger in the animation
  final int triggerIndex;
  final String iconAsset;
  Sword({
    required super.name,
    required this.triggerIndex,
    required this.damage,
    required this.level,
    required this.skills,
    required this.type,
    required this.iconAsset,
    required this.attackSpeed,
  });

  factory Sword.desolator() => Sword(
        name: 'Desolator Sword lvl 5',
        damage: 8000,
        attackSpeed: _getAttackSpeed(SwordType.desolator, 5),
        level: 5,
        skills: [],
        type: SwordType.desolator,
        triggerIndex: 0,
        iconAsset: 'equipments/swords/desolator-sprite.png',
      );
  factory Sword.purifier(int level) => Sword(
        name: 'Purifier Sword lvl $level',
        damage: _getPurifierDmg(level),
        attackSpeed: _getAttackSpeed(SwordType.purifier, level),
        level: level,
        skills: _getSkills(SwordType.purifier, level),
        type: SwordType.purifier,
        triggerIndex: 1,
        iconAsset: 'equipments/swords/purifier-sprite.png',
      );
  factory Sword.time(int level) => Sword(
        name: 'Time Sword lvl $level',
        damage: _getOtherDmg(level),
        attackSpeed: _getAttackSpeed(SwordType.time, level),
        level: level,
        skills: _getSkills(SwordType.time, level),
        type: SwordType.time,
        triggerIndex: 2,
        iconAsset: 'equipments/swords/time-sprite.png',
      );
  factory Sword.flame(int level) => Sword(
        name: 'Flame Sword lvl $level',
        damage: _getFlameDmg(level),
        attackSpeed: _getAttackSpeed(SwordType.flame, level),
        level: level,
        skills: _getSkills(SwordType.flame, level),
        type: SwordType.flame,
        triggerIndex: 3,
        iconAsset: 'equipments/swords/flame-sprite.png',
      );
  factory Sword.lightning(int level) => Sword(
        name: 'Lightning Sword lvl $level',
        damage: _getOtherDmg(level),
        attackSpeed: _getAttackSpeed(SwordType.lightning, level),
        level: level,
        skills: _getSkills(SwordType.lightning, level),
        type: SwordType.lightning,
        triggerIndex: 4,
        iconAsset: 'equipments/swords/lightning-sprite.png',
      );

  double get delay {
    return 1 / attackSpeed;
  }

  @override
  bool operator ==(Object other) {
    if (other is Sword) {
      return type == other.type;
    }
    return false;
  }

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() {
    return 'Sword: $type lvl: $level';
  }
}

double _getPurifierDmg(int level) {
  switch (level) {
    case 1:
      return 80;
    case 2:
      return 90;
    case 3:
      return 100;
    case 4:
      return 110;
    default:
      return 8000;
  }
}

double _getOtherDmg(int level) {
  switch (level) {
    case 1:
      return 70;
    case 2:
      return 80;
    case 3:
      return 90;
    case 4:
      return 100;
    default:
      return 7000;
  }
}

double _getFlameDmg(int level) {
  switch (level) {
    case 1:
      return 40;
    case 2:
      return 45;
    case 3:
      return 50;
    case 4:
      return 55;
    default:
      return 1000;
  }
}

List<Skill> _getSkills(SwordType type, int level) {
  final List<Skill> skills = [];
  switch (type) {
    case SwordType.desolator:
      return [];
    case SwordType.purifier:
      if (level >= 3) {
        skills.add(Skills.repel);
      }
      if (level >= 4) {
        skills.add(Skills.guardianEngel);
      }
      return skills;
    case SwordType.time:
      if (level >= 3) {
        skills.add(Skills.timeWalk);
      }
      if (level >= 4) {
        skills.add(Skills.chronosphere);
      }
      return skills;
    case SwordType.flame:
      if (level >= 2) {
        skills.add(Skills.fireball);
      }
      if (level >= 3) {
        skills.add(Skills.flameCloak);
      }
      if (level >= 4) {
        skills.add(Skills.equiemOfSouls);
      }
      return skills;
    case SwordType.lightning:
      if (level >= 3) {
        skills.add(Skills.ballLightning);
      }
      if (level >= 4) {
        skills.add(Skills.thunderStrike);
      }
      return skills;
  }
}

double _getAttackSpeed(SwordType type, int level) {
  switch (type) {
    case SwordType.desolator:
      return 1;
    case SwordType.purifier:
      return level == 1 ? 1 : 3;
    case SwordType.time:
      return 3;
    case SwordType.flame:
      return level == 3 ? 1 : 2;
    case SwordType.lightning:
      return 3;
  }
}
