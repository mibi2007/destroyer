import 'skills.dart';

abstract class Equipment {
  final String name;
  final String iconAsset;

  Equipment({required this.iconAsset, required this.name});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }

  static Equipment fromJson<T>(Map<String, dynamic> json) {
    if (T == Sword) {
      return Sword.fromJson(json);
    } else {
      throw Exception('Unknown type');
    }
  }
}

enum SwordType {
  desolator,
  purifier,
  time,
  flame,
  lightning;

  String toJson() {
    return toString().split('.').last;
  }

  static SwordType fromJson(String json) {
    switch (json) {
      case 'desolator':
        return SwordType.desolator;
      case 'purifier':
        return SwordType.purifier;
      case 'time':
        return SwordType.time;
      case 'flame':
        return SwordType.flame;
      case 'lightning':
        return SwordType.lightning;
    }
    return SwordType.desolator;
  }
}

class Sword extends Equipment {
  final SwordType type;
  final double damage;
  final int level;
  final List<Skill> skills;
  final double attackSpeed;
  // The index of the trigger in the animation
  final int triggerIndex;
  Sword({
    required super.name,
    required super.iconAsset,
    required this.triggerIndex,
    required this.damage,
    required this.level,
    required this.skills,
    required this.type,
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
        iconAsset: 'assets/images/equipments/swords/desolator-sprite.png',
      );
  factory Sword.purifier(int level) => Sword(
        name: 'Purifier Sword lvl $level',
        damage: _getPurifierDmg(level),
        attackSpeed: _getAttackSpeed(SwordType.purifier, level),
        level: level,
        skills: _getSkills(SwordType.purifier, level),
        type: SwordType.purifier,
        triggerIndex: 1,
        iconAsset: 'assets/images/equipments/swords/purifier-sprite.png',
      );
  factory Sword.time(int level) => Sword(
        name: 'Time Sword lvl $level',
        damage: _getOtherDmg(level),
        attackSpeed: _getAttackSpeed(SwordType.time, level),
        level: level,
        skills: _getSkills(SwordType.time, level),
        type: SwordType.time,
        triggerIndex: 2,
        iconAsset: 'assets/images/equipments/swords/time-sprite.png',
      );
  factory Sword.flame(int level) => Sword(
        name: 'Flame Sword lvl $level',
        damage: _getFlameDmg(level),
        attackSpeed: _getAttackSpeed(SwordType.flame, level),
        level: level,
        skills: _getSkills(SwordType.flame, level),
        type: SwordType.flame,
        triggerIndex: 3,
        iconAsset: 'assets/images/equipments/swords/flame-sprite.png',
      );
  factory Sword.lightning(int level) => Sword(
        name: 'Lightning Sword lvl $level',
        damage: _getOtherDmg(level),
        attackSpeed: _getAttackSpeed(SwordType.lightning, level),
        level: level,
        skills: _getSkills(SwordType.lightning, level),
        type: SwordType.lightning,
        triggerIndex: 4,
        iconAsset: 'assets/images/equipments/swords/lightning-sprite.png',
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

  @override
  Map<String, dynamic> toJson() {
    return {
      'sword_type': type.toJson(),
      'level': level,
    };
  }

  factory Sword.fromJson(Map<String, dynamic> json) {
    final type = SwordType.fromJson(json['sword_type'] as String);
    final level = json['level'] as int;
    switch (type) {
      case SwordType.desolator:
        return Sword.desolator();
      case SwordType.purifier:
        return Sword.purifier(level);
      case SwordType.time:
        return Sword.time(level);
      case SwordType.flame:
        return Sword.flame(level);
      case SwordType.lightning:
        return Sword.lightning(level);
    }
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

class Armor extends Equipment {
  Armor({required super.name}) : super(iconAsset: 'assets/images/equipments/armors/$name.webp');

  factory Armor.helmet() => Armor(name: 'Helmet');
  factory Armor.chestpiece() => Armor(name: 'Chestpiece');
  factory Armor.gauntlets() => Armor(name: 'Gauntlets');
  factory Armor.leggings() => Armor(name: 'Leggings');
  factory Armor.boots() => Armor(name: 'Boots');

  factory Armor.fromName(String name) {
    switch (name) {
      case 'Helmet':
        return Armor.helmet();
      case 'Chestpiece':
        return Armor.chestpiece();
      case 'Gauntlets':
        return Armor.gauntlets();
      case 'Leggings':
        return Armor.leggings();
      case 'Boots':
        return Armor.boots();
      default:
        return Armor.helmet();
    }
  }

  @override
  bool operator ==(Object other) {
    if (other is Armor) {
      return name == other.name;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'Armor: $name';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'armor_type': name.toLowerCase(),
    };
  }

  factory Armor.fromJson(Map<String, dynamic> json) {
    final type = json['armor_type'] as String;
    switch (type) {
      case 'helmet':
        return Armor.helmet();
      case 'chestpiece':
        return Armor.chestpiece();
      case 'gauntlets':
        return Armor.gauntlets();
      case 'leggings':
        return Armor.leggings();
      case 'boots':
        return Armor.boots();
      default:
        return Armor.helmet();
    }
  }
}
