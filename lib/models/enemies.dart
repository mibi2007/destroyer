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
  Garbage({super.asset = '', super.damage = 20, required super.maxHealth, super.armor = 5, required super.level});

  @override
  String toString() {
    return 'Garbage $level';
  }
}

class Boss extends Enemy {
  late final SpriteAnimation moveAnimation;
  late final SpriteAnimation attackAnimation;
  Boss({super.asset = '', super.damage = 50, required super.maxHealth, super.armor = 20, required super.level});

  factory Boss.map1() => Boss(
        asset: 'assets/images/enemies/boss1.png',
        damage: 50,
        maxHealth: 1000,
        armor: 20,
        level: 1,
      );
}

class GarbageMonster extends Enemy {
  GarbageMonster(
      {super.asset = 'assets/images/enemies/garbage_monster.png',
      super.damage = 20,
      super.maxHealth = 200,
      super.armor = 20,
      required super.level});
}
