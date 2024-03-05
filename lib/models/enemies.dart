import 'package:flame/components.dart';

abstract class Enemy {
  final int level;
  final String asset;
  final double damage;
  final double maxHealth;
  final double armor;

  Enemy({
    required this.level,
    required this.asset,
    required this.damage,
    required this.maxHealth,
    required this.armor,
  });
}

class Garbage extends Enemy {
  Garbage({super.asset = '', super.damage = 10, required super.maxHealth, super.armor = 3, required super.level});

  @override
  String toString() {
    return 'Garbage $level';
  }

  factory Garbage.purgedFromMonster(Enemy monster) {
    return Garbage(
      level: monster.level,
      maxHealth: 100,
    );
  }

  Garbage clone(String newAsset) {
    return Garbage(
      level: level,
      maxHealth: maxHealth,
      armor: armor,
      damage: damage,
      asset: newAsset,
    );
  }
}

class Boss extends Enemy {
  late final SpriteAnimation moveAnimation;
  late final SpriteAnimation attackAnimation;
  Boss({super.asset = '', super.damage = 50, required super.maxHealth, super.armor = 20, required super.level});
}

class GarbageMonster extends Enemy {
  GarbageMonster(
      {super.asset = 'assets/images/enemies/garbage_monster.png',
      super.damage = 20,
      super.maxHealth = 200,
      super.armor = 15,
      required super.level});
}
