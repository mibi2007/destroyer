import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text.dart';

import '../../models/enemies.dart';
import '../../models/equipments.dart';
import '../game.dart';
import 'health_bar.dart';
import 'player.dart';
import 'skills.dart';

// Represents an enemy in the game world.
class EnemySpriteComponent extends SpriteComponent with CollisionCallbacks, HasGameReference<DestroyerGame>, HealthBar {
  static final Vector2 _left = Vector2(-1, 0);
  static final Vector2 _right = Vector2(1, 0);
  Vector2 direction = _left;

  bool isHit = false;
  bool isDamaging = false;
  double _timerDamaging = 0;

  final Enemy enemy;
  SequenceEffect? effect;
  final double damage;

  EnemySpriteComponent(
    this.enemy,
    Image image, {
    Vector2? position,
    Vector2? targetPosition,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
    int? arrmor,
    this.damage = 25,
  }) : super.fromImage(
          image,
          srcPosition: Vector2(1 * 32, 0),
          srcSize: Vector2.all(32),
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority,
        ) {
    if (targetPosition != null && position != null) {
      // Need to sequence two move to effects so that we can
      // tap into the onFinishCallback and flip the component.
      effect = SequenceEffect(
        [
          MoveToEffect(
            targetPosition,
            EffectController(speed: 100),
            onComplete: () {
              flipHorizontallyAroundCenter();
              direction = _right;
            },
          ),
          MoveToEffect(
            position + Vector2(32, 0), // Need to offset by 32 due to flip
            EffectController(speed: 100),
            onComplete: () {
              flipHorizontallyAroundCenter();
              direction = _left;
            },
          ),
        ],
        infinite: true,
      );
      add(effect!);
    }
    initHealthBar(enemy.maxHealth, width);
  }

  @override
  bool get debugMode => false;

  @override
  void update(double dt) {
    super.update(dt);

    if (isHit) {
      effect?.pause();
    } else {
      effect?.resume();
    }

    if (isDamaging && _timerDamaging > 1) {
      isDamaging = false;
      _timerDamaging = 0;
    } else {
      _timerDamaging += dt;
    }
  }

  @override
  Future<void> onLoad() async {
    await add(CircleHitbox()..collisionType = CollisionType.passive);
    maxHealth = enemy.maxHealth;
    currentHealth = maxHealth;
  }

  /// Sample "explosion" animation for [SpriteAnimationParticle] example
  SpriteAnimation getBoomAnimation() {
    const columns = 8;
    const rows = 8;
    const frames = columns * rows;
    final spriteImage = game.images.fromCache('skills-and-effects/boom.png');
    final spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: spriteImage,
      columns: columns,
      rows: rows,
    );
    final sprites = List<Sprite>.generate(frames, spriteSheet.getSpriteById);
    return SpriteAnimation.spriteList(sprites, stepTime: 0.1);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is PlayerAnimationComponent) {
      if (game.playerData.health.value > 0 &&
          !isDamaging &&
          !game.playerData.effects.value.any((effect) => effect.name == 'invincible')) {
        // print('hit');
        other.hit();
        isDamaging = true;
        game.playerData.health.value -= (damage - game.playerData.armor.value * 3).round();
      }
      // Vector2 collisionDirection = other.position - position;
      // collisionDirection.normalize(); // Normalize to get a unit vector

      // // Apply the pushback force or change the position
      // // You can adjust the pushbackStrength to your liking
      // double pushbackStrength = 10.0;
      // other.position += collisionDirection * pushbackStrength;
    }

    double dmg = 0;
    if (other is Slash || other is Fireball) {
      isHit = true;
      if (other is Slash) {
        dmg = other.sword.damage - enemy.armor * 3;
      }
      if (other is Fireball) {
        dmg = (game.playerData.sword.value.damage / 2 - enemy.armor * 3);
      }
      currentHealth -= dmg.toInt();
      updateHealthBar(currentHealth);
      if (currentHealth <= 0) {
        add(
          OpacityEffect.fadeOut(
            LinearEffectController(0.2),
            onComplete: () => removeFromParent(),
          ),
        );
        // TODO: Play death sound
      } else {
        add(
          OpacityEffect.fadeOut(
            LinearEffectController(0.2),
            onComplete: () => add(OpacityEffect.fadeIn(LinearEffectController(0.2), onComplete: () => isHit = false)),
          ),
        );
        // if (swordDir.dot(_left) > 0.5) {
        //   position -= Vector2(direction.x * 10, 0);
        // }
        // if (swordDir.dot(_right) > 0.5) {
        //   position += Vector2(direction.x * 10, 0);
        // }
        // TODO: Play hit sound
      }
      if (game.playerData.sword.value.type == SwordType.flame) {
        add(
          ParticleSystemComponent(
            anchor: Anchor.center,
            particle: TranslatedParticle(
              lifespan: 1,
              offset: Vector2(width / 2, 0),
              child: SpriteAnimationParticle(
                animation: getBoomAnimation(),
                size: Vector2(50, 50),
              ),
            ),
          ),
        );
      } else {
        final slash = SpriteComponent(
          sprite: Sprite(game.images.fromCache('equipments/swords/slash-on-enemy.png')),
          size: Vector2(50, 50),
          position: Vector2(width / 2, height / 2),
          anchor: Anchor.center,
          priority: 1,
        );
        add(slash
          ..add(
            OpacityEffect.fadeIn(
              LinearEffectController(0.3),
              onComplete: () => slash.removeFromParent(),
            ),
          ));
      }

      final textComp = TextComponent(
        position: Vector2(position.x - (width - 5) / 2 * direction.x, position.y - 10),
        textRenderer: TextPaint(
            style: const TextStyle(
          fontSize: 6,
          color: Color(0xFFFF0000),
        )),
        size: Vector2(100, 10),
        text: dmg.toString(),
        anchor: Anchor.topCenter,
      );

      final moveEffect = MoveEffect.to(
        Vector2(position.x - (width - 5) / 2 * direction.x, position.y - 15), // New position
        EffectController(duration: 0.3),
        onComplete: () => textComp.removeFromParent(),
      );
      parent!.add(
        textComp..add(moveEffect),
      );
    }

    super.onCollisionStart(intersectionPoints, other);
  }
}