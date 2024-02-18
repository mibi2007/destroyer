import 'package:flame/collisions.dart';

import '../equipment.dart';

class SwordComponent extends EquipmentComponent with CollisionCallbacks {
  SwordComponent({
    required super.item,
    required super.sprite,
    required super.size,
    required super.position,
  });

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    // Load your sword sprite and set up animations here
  }

  @override
  void update(double dt) {
    // Update the position or animation of the sword attack
  }
}
