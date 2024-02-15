// import 'package:flame_tiled/flame_tiled.dart';

// extension CustomPropertiesX on CustomProperties {
//   String? getValue({required String name}) {
//     return _getValueFromTileProperty(this, name);
//   }
// }

import 'package:flame_tiled/flame_tiled.dart';

TiledObject? getObjectFromTargetById(List<TiledObject> objects, int? targetObjectId) {
  final targets = objects.where((object) => object.id == (targetObjectId ?? -1));
  TiledObject? target;
  if (targets.isNotEmpty) {
    target = targets.first;
  }
  return target;
}
