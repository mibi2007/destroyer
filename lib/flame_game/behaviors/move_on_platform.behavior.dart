import 'package:destroyer/flame_game/components/platform.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

import '../entities/player.entity.dart';

final Vector2 _up = Vector2(0, -1);
const double g = 500;
const double collisionThreshold = 0.1;
const double jumpThreshold = 0.1;

class MoveOnPlatform extends CollisionBehavior<Platform, OnGround> {
  double _timer = 0;
  // double _lastPositionX = 0;
  // double _lastPositionTimer = 0;
  double _canEndCollisionLeft = 0;
  double _canEndCollisionRight = 0;
  @override
  void onCollision(Set<Vector2> intersectionPoints, Platform other) {
    if (!parent.isMounted) return;
    if (parent is PlayerAnimationEntity && (parent as PlayerAnimationEntity).isLightning) return;
    if (intersectionPoints.length == 2) {
      // final collisionFromTop = intersectionPoints.any((point) => point.y >= other.position.y - collisionThreshold);

      // if (collisionFromTop && parent.velocity.y > 0) {
      //   parent.isOnGround = true;
      //   parent.velocity.y = 0; // Stop downward movement
      //   // Adjust the player's position to be on top of the platform
      //   parent.position.y = other.position.y - parent.size.y / 2;
      // } else {
      //   // parent.isOnGround = false;
      // }
      // parent.isOnGround = false;
      // Calculate the collision normal and separation distance.
      final mid = (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;

      final newCollisionNormal = parent.absoluteCenter - mid;
      final separationDistance = (parent.size.x / 2) - newCollisionNormal.length;
      newCollisionNormal.normalize();
      // If collision normal is almost upwards,
      // player must be on ground.
      // print(_up.dot(newCollisionNormal));
      if (_up.dot(newCollisionNormal) > 0.9 && !parent.isPendingAfterJump) {
        parent.isOnGround = true;
        _canEndCollisionLeft = other.position.x;
        _canEndCollisionRight = other.position.x + other.size.x;
      }

      // Resolve collision by moving player along
      // collision normal by separation distance.
      parent.position += newCollisionNormal.scaled(separationDistance);
      parent.collisionNormal = newCollisionNormal;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(Platform other) {
    if (!isMounted) return;
    // if (parent.position.x - _lastPositionX < 1) {
    //   // If the player hasn't moved beyond the threshold, ignore the collision end
    // } else {
    // print('${parent.position.x} - $_lastPositionX');
    // print('isOnGround = false');
    // parent.isOnGround = false;
    // }
    // print(_canEndCollisionLeft);
    // print(_canEndCollisionRight);
    // print(' player x = ${parent.position.x}');
    if (parent.position.x < _canEndCollisionLeft + 2 || parent.position.x > _canEndCollisionRight - 2) {
      parent.isOnGround = false;
    }
  }

  @override
  update(double dt) {
    // print(parent.position.x);
    // if (_lastPositionTimer > 0.5) {
    //   _lastPositionTimer = 0;
    //   if (parent is PlayerAnimationEntity) {
    //     print('save');
    //     print(parent.position.x);
    //   }
    //   _lastPositionX = parent.position.x;
    // }
    // _lastPositionTimer += dt;
    if (parent.isPendingAfterJump) {
      if (_timer == 0) {
        // print('start timer');
      }
      if (_timer > jumpThreshold) {
        // print('reset timer');
        parent.isPendingAfterJump = false;
        _timer = 0;
      } else {
        _timer += dt;
      }
    }
    if (!parent.isOnGround) {
      parent.velocity.y += parent.gravity * dt;
      // Clamp velocity along y to avoid player tunneling
      parent.velocity.y = parent.velocity.y.clamp(-jumpSpeed, parent.terminalVelocity);
      // _timer = 0;
    } else {
      // parent.velocity.y = 0;
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
  double terminalVelocity = 500;
  // Vector2 lastPosition = Vector2.zero();
  bool isPendingAfterJump = false;
}
