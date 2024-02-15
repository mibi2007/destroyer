import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/particles.dart';
import 'package:flutter/animation.dart';

import '../../models/skills.dart';
import '../game.dart';
import 'enemy.dart';
import 'platform.dart';

const beginColor = Color.fromARGB(255, 255, 60, 0);
const endColor = Color.fromARGB(255, 255, 187, 0);

mixin Countdown on PositionComponent {
  CountdownComponent? countdownComponent;

  void startCountdown(double countdownTime) {
    countdownComponent = CountdownComponent(
        countdownTime: countdownTime, size: size * 2, position: Vector2(24, 16), anchor: Anchor.center);

    final clipComponent = ClipComponent.rectangle(position: Vector2(0, 0), size: size, children: [countdownComponent!]);
    add(clipComponent);
    Future.delayed(Duration(seconds: countdownTime.toInt()), () {
      if (countdownComponent != null) countdownComponent!.removeFromParent();
      countdownComponent = null;
    });
  }

  // @override
  // void render(Canvas canvas) {
  //   super.render(canvas);

  //   if (countdownComponent != null) countdownComponent!.render(canvas);
  // }
}

class CountdownComponent extends PositionComponent {
  double countdownTime;
  double currentTime = 0;

  CountdownComponent({
    required this.countdownTime,
    super.position,
    super.size,
    super.anchor = Anchor.center,
    super.priority = 1,
  });

  @override
  bool get debugMode => false;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw the skill icon

    // Calculate the angle for the countdown effect
    double angle = (currentTime / countdownTime) * 2 * pi;

    // double angle = pi / 2;

    // Create a path for the circular mask
    Path path = Path()
      ..moveTo(position.x, position.y * 2)
      ..arcTo(
        Rect.fromCenter(center: position.toOffset(), width: size.x * 2, height: size.y * 2),
        -pi / 2,
        angle,
        false,
      )
      ..close();

    // Draw the mask
    canvas.drawPath(path, Paint()..color = const Color(0x99000000));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update the current time based on the countdown
    currentTime += dt;
    if (currentTime > countdownTime) {
      currentTime = countdownTime; // countdown is complete
    }
  }
}

class SkillComponent extends PositionComponent with HasGameReference<DestroyerGame>, Countdown {
  final Skill skill;
  late SpriteComponent iconComponent;

  SkillComponent(
    this.skill, {
    super.position,
    required super.size,
    super.anchor = Anchor.center,
  });

  @override
  bool get debugMode => false;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    iconComponent = SpriteComponent.fromImage(game.images.fromCache(skill.sprite), size: size);
    add(iconComponent);
  }
}

class Fireball extends SpriteComponent with HasGameReference<DestroyerGame>, CollisionCallbacks {
  final Vector2 velocity;
  Fireball({required Vector2 position, required double angle, required double speed, required this.velocity})
      : super(
          sprite: Sprite(Flame.images.fromCache('equipments/swords/fireball.png')),
          position: position,
          size: Vector2(10, 10), // Set the size of the bullet
          anchor: Anchor.center,
        );

  @override
  bool get debugMode => false;

  @override
  FutureOr<void> onLoad() {
    add(CircleHitbox());
  }

  final random = Random();
  final Tween<double> noise = Tween(begin: -1, end: 1);
  @override
  void update(double dt) {
    super.update(dt);
    angle += dt * 180 / pi;
    final ColorTween colorTween = ColorTween(begin: beginColor, end: endColor);
    position.add(velocity * dt); // Move the fireball independently
    final particle = ParticleSystemComponent(
      position: position,
      particle: Particle.generate(
        count: 20,
        generator: (i) {
          return AcceleratedParticle(
            lifespan: 0,
            speed: Vector2(
                  noise.transform(random.nextDouble()),
                  noise.transform(random.nextDouble()),
                ) *
                i.toDouble(),
            child: ComponentParticle(
              component: RectangleComponent(
                size: Vector2(1, 1),
                anchor: Anchor.center,
                paint: Paint()..color = colorTween.transform(random.nextDouble())!,
              ),
            ),
          );
        },
      ),
    );
    parent!.add(particle);

    // Check if the bullet is off-screen and remove it if necessary
    if (position.x < 0 ||
        position.x > (game.size.x + game.fixedResolution.x) ||
        position.y < 0 ||
        position.y > game.size.y) {
      // addToParent(ParticleSystemComponent(
      //   position: position,
      //   particle: TranslatedParticle(
      //     lifespan: 1,
      //     offset: Vector2.all(0),
      //     child: SpriteAnimationParticle(
      //       animation: getBoomAnimation(),
      //       size: Vector2(128, 128),
      //     ),
      //   ),
      // ));
      particle.removeFromParent();
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Platform || other is EnemySpriteComponent) {
      // TODO: play explosion
      removeFromParent();
      // add(OpacityEffect.fadeOut(
      //   LinearEffectController(5),
      //   onComplete: () => removeFromParent(),
      // ));
    }
  }

  // /// An [SpriteAnimationParticle] takes a Flame [SpriteAnimation]
  // /// and plays it during the particle lifespan.
  // Particle animationParticle() {
  //   return SpriteAnimationParticle(
  //     animation: getBoomAnimation(),
  //     size: Vector2(128, 128),
  //   );
  // }
}

class EffectComponent extends PositionComponent with HasGameRef<DestroyerGame>, Countdown {
  final SkillEffect effect;
  late SpriteComponent iconComponent;
  EffectComponent(
    this.effect, {
    super.position,
    required super.size,
    super.anchor = Anchor.center,
  }) : super(scale: Vector2(0.5, 0.5));

  @override
  bool get debugMode => false;

  @override
  FutureOr<void> onLoad() {
    iconComponent = SpriteComponent.fromImage(game.images.fromCache(effect.sprite), size: size, priority: 0);
    add(iconComponent);
  }
}
