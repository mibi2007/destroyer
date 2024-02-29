import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

import '../../../models/skills.dart';
import '../../../skills/lightning_particle.dart';
import '../../../skills/requiem_of_souls.dart';
import '../../components/skills.dart';
import '../../entities/enemy.entity.dart';
import '../../entities/player.entity.dart';
import '../../game.dart';
import 'enemy_collision.dart';

class HitBySlash extends CollisionBehavior<Slash, EntityMixin> with HasGameRef<DestroyerGame> {
  static const String _asset = 'assets/animations/slash.png';
  static const _dimension = 192.0;
  static const _slashTime = 0.3;
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Slash other) {
    final Vector2 srcSize = Vector2.all(_dimension);
    if (parent is EnemyEntity) {
      final castType = parent as EnemyEntity;
      if (castType.isCursed) return;
      final dmg = other.sword.damage - castType.enemy.armor;
      _damage<EnemyEntity>(dmg, srcSize);
    } else if (parent is EnemyAnimationEntity) {
      final castType = parent as EnemyAnimationEntity;
      if (castType.isCursed) return;
      final dmg = other.sword.damage - castType.enemy.armor;
      _damage<EnemyAnimationEntity>(dmg, srcSize);
    }
  }

  void _damage<T extends EnemyCollision>(double dmg, Vector2 srcSize) {
    (parent as T).isHit = true;
    // final dmg = other.sword.damage - parent.enemy.armor;
    (parent as T).currentHealth -= dmg.toInt();
    (parent as T).updateHealthBar((parent as T).currentHealth);
    (parent as T).showDamage(dmg);

    final slash = SpriteAnimationComponent(
      animation: SpriteAnimation.spriteList(
        [
          Sprite(game.images.fromCache(_asset), srcSize: srcSize, srcPosition: Vector2(_dimension * 0, 0)),
          Sprite(game.images.fromCache(_asset), srcSize: srcSize, srcPosition: Vector2(_dimension * 1, 0)),
          Sprite(game.images.fromCache(_asset), srcSize: srcSize, srcPosition: Vector2(_dimension * 2, 0)),
        ],
        stepTime: 0.2, // Time each frame is displayed
      ),
      size: (parent as T).size * 2,
      position: Vector2((parent as T).width / 2, (parent as T).height / 2),
      anchor: Anchor.center,
      priority: 1,
    );
    (parent as T).add(slash
      ..add(
        OpacityEffect.fadeIn(
          LinearEffectController(_slashTime),
          onComplete: () {
            slash.removeFromParent();
            (parent as T).isHit = false;
            (parent as T).checkIfDead();
          },
        ),
      ));
  }
}

// The class merge the Fireball and Requiem of Souls effect
class BurnSkill extends Component with HasGameRef<DestroyerGame> {
  final CollisionBehavior behavior;

  BurnSkill({required this.behavior});

  factory BurnSkill.fromFireball(CollisionBehavior<Fireball, EntityMixin> behavior) {
    return BurnSkill(behavior: behavior);
  }

  factory BurnSkill.fromRequiemOfSoulsSkillComponent(
      CollisionBehavior<RequiemOfSoulsSkillComponent, EntityMixin> behavior) {
    return BurnSkill(behavior: behavior);
  }

  void onCollisionStart<T extends EnemyCollision>(double dmg, double burnTime) {
    final parent = behavior.parent as T;
    if (parent.isCursed) return;
    parent.isBurned = true;
    // double dmg = 0;
    // if (other is Fireball) dmg = other.damage - parent.enemy.armor;
    // if (other is RequiemOfSoulsSkillComponent) {
    //   dmg = other.skill.damage * (game.playerData.souls.value + 1) - parent.enemy.armor;
    // }
    parent.currentHealth -= dmg;
    parent.updateHealthBar(parent.currentHealth);
    parent.showDamage(dmg);
    behavior.add(
      ParticleSystemComponent(
        anchor: Anchor.center,
        particle: TranslatedParticle(
          lifespan: burnTime,
          offset: Vector2(parent.width / 2, 0),
          child: SpriteAnimationParticle(
            animation: getBoomAnimation(game.images),
            size: Vector2(50, 50),
          ),
        ),
      ),
    );
    behavior.add(TimerComponent(
      period: burnTime, // The period in seconds
      onTick: () {
        parent.isBurned = false;
        parent.checkIfDead();
        // print('will remove');
        removeFromParent();
        // Future.delayed(Duration(seconds: 1)).then((_) {
        //   print(isMounted); // Must be false
        // });
      },
    ));
  }
}

class HitByFireball extends CollisionBehavior<Fireball, EntityMixin> with HasGameRef<DestroyerGame> {
  static const _burnTime = 1.0;
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, Fireball other) {
    if (parent is EnemyEntity) {
      final typeCast = parent as EnemyEntity;
      if (typeCast.isCursed) return;
      final dmg = other.damage - typeCast.enemy.armor;
      final burnSkill = BurnSkill.fromFireball(this);
      game.add(burnSkill);
      burnSkill.onCollisionStart(dmg, _burnTime);
    }
    if (parent is EnemyAnimationEntity) {
      final typeCast = parent as EnemyAnimationEntity;
      if (typeCast.isCursed) return;
      final dmg = other.damage - typeCast.enemy.armor;
      final burnSkill = BurnSkill.fromFireball(this);
      game.add(burnSkill);
      burnSkill.onCollisionStart(dmg, _burnTime);
    }
  }
}

class HitByRequiemOfSouls extends CollisionBehavior<RequiemOfSoulsSkillComponent, EntityMixin>
    with HasGameRef<DestroyerGame> {
  static const _burnTime = 1.0;
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, RequiemOfSoulsSkillComponent other) {
    if (parent is EnemyEntity) {
      final typeCast = parent as EnemyEntity;
      if (typeCast.isCursed) return;
      final dmg = other.skill.damage - typeCast.enemy.armor;
      final burnSkill = BurnSkill.fromRequiemOfSoulsSkillComponent(this);
      game.add(burnSkill);
      burnSkill.onCollisionStart(dmg, _burnTime);
    }
    if (parent is EnemyAnimationEntity) {
      final typeCast = parent as EnemyAnimationEntity;
      if (typeCast.isCursed) return;
      final dmg = other.skill.damage - typeCast.enemy.armor;
      final burnSkill = BurnSkill.fromRequiemOfSoulsSkillComponent(this);
      game.add(burnSkill);
      burnSkill.onCollisionStart(dmg, _burnTime);
    }
  }
}

class ElectricShockEffect extends Component with HasGameRef<DestroyerGame> {
  static const _dimension = 64.0;

  final String _asset = 'assets/animations/electric.png';

  final CollisionBehavior behavior;
  final double electricShockTime;

  ElectricShockEffect({
    required this.behavior,
    required this.electricShockTime,
  });

  factory ElectricShockEffect.fromBallLightning(
      CollisionBehavior<PlayerAnimationEntity, EntityMixin> behavior, double electricShockTime) {
    return ElectricShockEffect(behavior: behavior, electricShockTime: electricShockTime);
  }

  factory ElectricShockEffect.fromThunderStrike(
      CollisionBehavior<ThunderStrikeEffects, EntityMixin> behavior, double electricShockTime) {
    return ElectricShockEffect(behavior: behavior, electricShockTime: electricShockTime);
  }

  void onCollisionStart<T extends EnemyCollision>(double dmg) {
    final parent = behavior.parent as T;
    if (parent.isCursed) return;
    final srcSize = Vector2.all(_dimension);
    parent.isElectricShocked = true;
    parent.currentHealth -= dmg.toInt();
    parent.updateHealthBar(parent.currentHealth);
    parent.showDamage(dmg);
    final electrict = SpriteAnimationComponent(
      animation: SpriteAnimation.spriteList(
        [
          Sprite(game.images.fromCache(_asset), srcSize: srcSize, srcPosition: Vector2(_dimension * 0, 0)),
          Sprite(game.images.fromCache(_asset), srcSize: srcSize, srcPosition: Vector2(_dimension * 1, 0)),
          Sprite(game.images.fromCache(_asset), srcSize: srcSize, srcPosition: Vector2(_dimension * 2, 0)),
          Sprite(game.images.fromCache(_asset), srcSize: srcSize, srcPosition: Vector2(_dimension * 3, 0)),
        ],
        stepTime: 0.2, // Time each frame is displayed
      ),
      size: parent.size * 2,
      position: Vector2(parent.width / 2, parent.height / 2),
      anchor: Anchor.center,
      priority: 1,
    );
    parent.add(electrict);
    add(TimerComponent(
      period: electricShockTime, // The period in seconds
      onTick: () {
        electrict
            .add(OpacityEffect.fadeOut(LinearEffectController(0.5), onComplete: () => electrict.removeFromParent()));
        parent.isElectricShocked = false;
        parent.checkIfDead();
        removeFromParent();
      },
    ));
  }
}

class HitByLightningBall extends CollisionBehavior<PlayerAnimationEntity, EntityMixin> with HasGameRef<DestroyerGame> {
  static const _electricShockTime = 1.0;
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PlayerAnimationEntity other) {
    if (!other.isLightning) return;
    if (parent is EnemyEntity) {
      final typeCast = parent as EnemyEntity;
      if (typeCast.isCursed) return;
      final electricShockEffect = ElectricShockEffect.fromBallLightning(this, _electricShockTime);
      add(electricShockEffect);
      final dmg = Skills.ballLightning.damage - typeCast.enemy.armor;
      electricShockEffect.onCollisionStart(dmg);
    }
    if (parent is EnemyAnimationEntity) {
      final typeCast = parent as EnemyAnimationEntity;
      if (typeCast.isCursed) return;
      final electricShockEffect = ElectricShockEffect.fromBallLightning(this, _electricShockTime);
      add(electricShockEffect);
      final dmg = Skills.ballLightning.damage - typeCast.enemy.armor;
      electricShockEffect.onCollisionStart(dmg);
    }
  }
}

class HitByThunderStrike extends CollisionBehavior<ThunderStrikeEffects, EntityMixin> with HasGameRef<DestroyerGame> {
  static const _electricShockTime = 2.0;
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, ThunderStrikeEffects other) {
    if (parent is EnemyEntity) {
      final typeCast = parent as EnemyEntity;
      if (typeCast.isCursed) return;
      final electricShockEffect = ElectricShockEffect.fromThunderStrike(this, _electricShockTime);
      add(electricShockEffect);
      final dmg = Skills.thunderStrike.damage - typeCast.enemy.armor;
      electricShockEffect.onCollisionStart(dmg);
    }
    if (parent is EnemyAnimationEntity) {
      final typeCast = parent as EnemyAnimationEntity;
      if (typeCast.isCursed) return;
      final electricShockEffect = ElectricShockEffect.fromThunderStrike(this, _electricShockTime);
      add(electricShockEffect);
      final dmg = Skills.thunderStrike.damage - typeCast.enemy.armor;
      electricShockEffect.onCollisionStart(dmg);
    }
  }
}

List<Behavior> attackedBehaviors() => [
      HitBySlash(),
      HitByFireball(),
      HitByRequiemOfSouls(),
      HitByLightningBall(),
      HitByThunderStrike(),
    ];

/// Sample "explosion" animation for [SpriteAnimationParticle] example
SpriteAnimation getBoomAnimation(Images images) {
  const columns = 8;
  const rows = 8;
  const frames = columns * rows;
  final spriteImage = images.fromCache('assets/images/skills-and-effects/boom.png');
  final spriteSheet = SpriteSheet.fromColumnsAndRows(
    image: spriteImage,
    columns: columns,
    rows: rows,
  );
  final sprites = List<Sprite>.generate(frames, spriteSheet.getSpriteById);
  return SpriteAnimation.spriteList(sprites, stepTime: 0.1, loop: false);
}
