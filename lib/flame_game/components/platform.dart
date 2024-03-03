import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';

import '../../utils/utils.dart';
import '../entities/player.entity.dart';

// Represents a platform in the game world.
class Platform extends PositionComponent with CollisionCallbacks {
  final bool isBrick;
  Platform({
    required Vector2 super.position,
    required Vector2 super.size,
    super.scale,
    super.angle,
    super.anchor,
    int? priority,
    this.isBrick = false,
  });

  @override
  Future<void> onLoad() async {
    // Passive, because we don't want platforms to
    // collide with each other.
    await add(RectangleHitbox(isSolid: true)..collisionType = CollisionType.passive);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (isBrick && other is Slash) {
      add(ParticleSystemComponent(
          particle: Particle.generate(
        generator: (i) => AcceleratedParticle(
          speed: Vector2(rnd.nextDouble() * 600 - 300, -rnd.nextDouble() * 600) * .2,
          acceleration: Vector2(0, 200),
          child: RotatingParticle(
              from: rnd.nextDouble() * pi,
              child: ComponentParticle(
                size: Vector2.all(2),
                component: RectangleComponent(
                  size: Vector2.all(2),
                  anchor: Anchor.center,
                  paint: Paint()..color = const Color(0xFF082534),
                ),
              )),
        ),
      )));
      add(TimerComponent(
        period: 0.3, // The period in seconds
        onTick: () {
          parent!.removeFromParent();
        },
        removeOnFinish: true,
      ));
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
