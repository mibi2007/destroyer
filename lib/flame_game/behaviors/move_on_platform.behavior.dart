import 'package:destroyer/flame_game/components/platform.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

import '../entities/player.entity.dart';

final Vector2 _up = Vector2(0, -1);
const double g = 300;
const double threshold = 1;

class MoveOnPlatform extends CollisionBehavior<Platform, OnGround> {
  double _timer = 0;
  @override
  void onCollision(Set<Vector2> intersectionPoints, Platform other) {
    if (!isMounted) return;
    if (parent is PlayerAnimationEntity && (parent as PlayerAnimationEntity).isLightning) return;
    if (intersectionPoints.length == 2) {
      // Calculate the collision normal and separation distance.
      final mid = (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;

      final newCollisionNormal = parent.absoluteCenter - mid;
      final separationDistance = (parent.size.x / 2) - newCollisionNormal.length;
      newCollisionNormal.normalize();
      // If collision normal is almost upwards,
      // player must be on ground.
      // print(_up.dot(newCollisionNormal));
      if (_up.dot(newCollisionNormal) > 0.9) {
        parent.isOnGround = true;
      }

      // Resolve collision by moving player along
      // collision normal by separation distance.
      parent.position += newCollisionNormal.scaled(separationDistance);
      parent.collisionNormal = newCollisionNormal;
    }
  }

  @override
  void onCollisionEnd(Platform other) {
    if (!isMounted) return;
    // print(parent.position.distanceTo(parent.lastPosition));
    // if (parent.position.distanceTo(parent.lastPosition) == 0) {
    //   // If the player hasn't moved beyond the threshold, ignore the collision end
    // } else {
    //   parent.isOnGround = false;
    // }
    parent.isOnGround = false;
  }

  @override
  update(double dt) {
    parent.lastPosition = parent.position.clone();
    if (!parent.isOnGround) {
      parent.velocity.y += parent.gravity * dt;
      // Clamp velocity along y to avoid player tunneling
      parent.velocity.y = parent.velocity.y.clamp(-jumpSpeed, parent.terminalVelocity);
      // _timer = 0;
    } else {
      parent.velocity.y = 0;
    }
    // game.playerData.position.value = parent.position;
    // if (parent is PlayerAnimationEntity) {
    //   if (!(parent as PlayerAnimationEntity).isLightning) {
    //     (parent as PlayerAnimationEntity).moveBackground(parent.velocity);
    //   }
    // } else {
    //   parent.position += parent.velocity * dt;
    // }
    // _timer += dt;
  }
}

mixin OnGround on EntityMixin, PositionComponent {
  double gravity = g;
  bool isOnGround = false;
  Vector2 collisionNormal = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  final double terminalVelocity = 150;
  Vector2 lastPosition = Vector2.zero();
}
