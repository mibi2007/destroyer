import 'package:flame/components.dart';

import '../../models/equipments.dart';
import '../game.dart';

class EquipmentComponent extends SpriteComponent
    with HasGameReference<DestroyerGame> {
  final Equipment item;
  final bool canPickedUp;
  EquipmentComponent({
    required this.item,
    required super.position,
    required super.size,
    required super.sprite,
    this.canPickedUp = true,
  }) : super(anchor: Anchor.center);
}
