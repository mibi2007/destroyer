import 'package:flame/components.dart';

mixin EnemyCollision on PositionComponent {
  double currentHealth = 0;
  bool isHit = false;
  bool isCursed = false;
  bool isElectricShocked = false;
  bool isBurned = false;
  bool isInsideChronosphere = false;

  bool checkIfDead();
  void showDamage(double damage);
  void updateHealthBar(double health);
}
