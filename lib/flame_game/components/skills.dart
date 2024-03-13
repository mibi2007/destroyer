import 'dart:async';
import 'dart:math';
import 'dart:ui' hide TextStyle;

import 'package:destroyer/flame_game/entities/enemy.entity.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/particles.dart';
import 'package:flame/text.dart';
import 'package:flutter/animation.dart';

import '../../hud/hud.dart';
import '../../level_selection/level.dart';
import '../../models/enemies.dart';
import '../../models/equipments.dart';
import '../../models/skills.dart';
import '../../utils/utils.dart';
import '../entities/garbage.entity.dart';
import '../entities/garbage_monster.entity.dart';
import '../game.dart';
import 'platform.dart';

const beginColor = Color.fromARGB(255, 255, 60, 0);
const endColor = Color.fromARGB(255, 255, 187, 0);

mixin Countdown on PositionComponent {
  Timer? _timer;
  CountdownComponent? countdownComponent;

  void startCountdown(double countdownTime) {
    countdownComponent = CountdownComponent(
        countdownTime: countdownTime, size: size * 2, position: Vector2(24, 16), anchor: Anchor.center);

    final clipComponent = ClipComponent.rectangle(position: Vector2(0, 0), size: size, children: [countdownComponent!]);
    add(clipComponent);
    _timer = Timer(
      countdownTime, // The period in seconds
      onTick: () {
        if (countdownComponent != null) countdownComponent!.removeFromParent();
        countdownComponent = null;
      },
    );
  }

  void stopCountdown() {
    if (_timer != null) _timer!.stop();
    if (countdownComponent != null) countdownComponent!.removeFromParent();
    countdownComponent = null;
  }

  @override
  void update(double dt) {
    if (_timer != null) _timer!.update(dt);
    super.update(dt);
  }
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

class SkillComponent extends PositionComponent
    with HasGameReference<DestroyerGame>, Countdown, CollisionCallbacks, TapCallbacks, ParentIsA<Hud> {
  final Skill skill;
  late SpriteComponent iconComponent;
  late final Component tooltip;

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
    add(RectangleHitbox(collisionType: CollisionType.passive, isSolid: true));
    iconComponent = SpriteComponent.fromImage(game.images.fromCache(skill.sprite), size: size);
    add(iconComponent);
    tooltip = RectangleComponent(
      size: Vector2(300, 150),
      position: Vector2(0, -15),
      anchor: Anchor.bottomCenter,
      paint: Paint()..color = const Color(0xEE000000),
      scale: Vector2.all(0.5),
      children: [
        TextBoxComponent(
            text: skill.description,
            position: Vector2(150, 75),
            anchor: Anchor.center,
            textRenderer: TextPaint(
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 12,
                fontFamily: 'Press Start 2P',
                height: 1.5,
              ),
            ),
            boxConfig: TextBoxConfig(
              maxWidth: 300,
              growingBox: true, // Set to true if you want the box to grow with the text
            ))
      ],
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is HudCursor) {
      showTooltip();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is HudCursor) hideTooltip();
    super.onCollisionEnd(other);
  }

  void showTooltip() {
    add(tooltip);
  }

  void hideTooltip() {
    remove(tooltip);
  }

  @override
  void onTapUp(TapUpEvent event) {
    parent.castSkill(skill);
    super.onTapUp(event);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!game.isMobile) return;
    final newSword = game.getEquipments().firstWhere((e) {
      return (e is Sword) && e.type == skill.swordType;
    }) as Sword;
    game.playerData.changeSwordAnimation.value = newSword.triggerIndex;
    game.playerData.sword.value = newSword;
    super.onTapDown(event);
  }
}

class Fireball extends SpriteComponent
    with HasGameReference<DestroyerGame>, ParentIsA<SceneComponent>, CollisionCallbacks {
  final Vector2 velocity;
  final double damage;
  Fireball(
      {required Vector2 position,
      required double angle,
      required double speed,
      required this.velocity,
      required this.damage})
      : super(
          sprite: Sprite(Flame.images.fromCache('assets/images/equipments/swords/fireball.png')),
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
    parent.add(particle);

    // Check if the bullet is off-screen and remove it if necessary
    if (position.x < 0 || position.x > parent.mapTiled.width || position.y < 0 || position.y > parent.mapTiled.height) {
      particle.removeFromParent();
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Platform || other is EnemyEntity || other is EnemyAnimationEntity) {
      // TODO: play explosion
      removeFromParent();
    }
  }
}

class EffectComponent extends PositionComponent with HasGameRef<DestroyerGame>, Countdown {
  final SkillEffect effect;
  int? count;
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
    if (count != null) {
      add(TextComponent(
          text: count.toString(),
          position: Vector2(0, 0),
          size: size,
          anchor: Anchor.center,
          textRenderer: TextPaint(
              style: const TextStyle(
            fontFamily: 'Press Start 2P',
          ))));
    }
  }
}

class Purifier extends PositionComponent with HasGameRef<DestroyerGame> {
  Purifier(Vector2 position, Vector2 size) : super(position: position, size: size);

  @override
  FutureOr<void> onLoad() {
    final clipping = ClipComponent.circle(position: Vector2.all(width / 2), size: size * 1.5, anchor: Anchor.center);
    add(clipping);
    if (parent is GarbageMonsterEntity) {
      final typeCast = parent as GarbageMonsterEntity;
      final image = game.images.fromCache(
          rnd.nextDouble() * 2 < 1 ? 'assets/images/enemies/garbage1.png' : 'assets/images/enemies/garbage2.png');
      clipping.add(SpriteComponent.fromImage(
          game.images.fromCache(
            'assets/images/skills-and-effects/purifier.png',
          ),
          srcSize: Vector2.all(300),
          size: clipping.size,
          position: Vector2(0, 50))
        ..add(MoveEffect.by(Vector2(0, -100), LinearEffectController(0.5), onComplete: () {
          if (parent is GarbageMonsterEntity) {
            typeCast.add(OpacityEffect.fadeOut(LinearEffectController(1), onComplete: () {
              typeCast.parent.add(GarbageEntity(Garbage.purgedFromMonster(typeCast.enemy), image,
                  position: typeCast.position, targetPosition: typeCast.position));
              typeCast.removeFromParent();
            }));
          }
        })));
    }
  }
}
