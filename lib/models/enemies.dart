abstract class Enemy {
  final String asset;
  final double damage;
  final double maxHealth;
  final double armor;

  Enemy({
    required this.asset,
    required this.damage,
    required this.maxHealth,
    required this.armor,
  });
}

class Garbage extends Enemy {
  Garbage({super.asset = '', super.damage = 20, required super.maxHealth, super.armor = 5});
}
