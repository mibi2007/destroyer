import 'package:flame/components.dart';

import '../../models/equipments.dart';
import '../game.dart';

class EquipmentComponent extends SpriteComponent with HasGameRef<DestroyerGame> {
  final Equipment item;
  EquipmentComponent({required this.item, required super.position, required super.size, required super.sprite})
      : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Load your sword sprite and set up animations here
  }

  @override
  void update(double dt) {
    // Update the position or animation of the sword attack
  }
}
