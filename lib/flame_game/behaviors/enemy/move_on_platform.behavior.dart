import 'package:destroyer/flame_game/components/platform.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

import '../../entities/garbage_monster.entity.dart';

final Vector2 _up = Vector2(0, -1);

class MoveOnPlatform extends CollisionBehavior<Platform, EntityMixin> {
  @override
  void onCollision(Set<Vector2> intersectionPoints, Platform other) {
    if (parent is GarbageMonsterEntity) {
      final p = parent as GarbageMonsterEntity;
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;

        final newCollisionNormal = p.absoluteCenter - mid;
        final separationDistance = (p.size.x / 2) - newCollisionNormal.length;
        newCollisionNormal.normalize();
        // If collision normal is almost upwards,
        // player must be on ground.
        if (_up.dot(newCollisionNormal) > 0.7) {
          p.isOnGround = true;
        } else {
          p.isOnGround = false;
        }

        // Resolve collision by moving player along
        // collision normal by separation distance.
        p.position += newCollisionNormal.scaled(separationDistance);
        p.collisionNormal = newCollisionNormal;
      }
    }
  }

  @override
  void onCollisionEnd(Platform other) {
    if (!isMounted) return;
    if (parent is GarbageMonsterEntity) {
      (parent as GarbageMonsterEntity).isOnGround = false;
    }
  }
}
