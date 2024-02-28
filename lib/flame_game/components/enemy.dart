// import 'dart:async';

// import 'package:destroyer/level_selection/level.dart';
// import 'package:flame/collisions.dart';
// import 'package:flame/components.dart';
// import 'package:flame/effects.dart';
// import 'package:flame/image_composition.dart';

// import '../../models/enemies.dart';
// import '../game.dart';
// import 'enemies/enemy_collision.dart';
// import 'health_bar.dart';

// // Represents an enemy in the game world.
// class EnemySpriteComponent extends SpriteComponent
//     with ParentIsA<SceneComponent>, CollisionCallbacks, HasGameReference<DestroyerGame>, HealthBar, EnemyCollision {
//   static final Vector2 _left = Vector2(-1, 0);
//   static final Vector2 _right = Vector2(1, 0);
//   Vector2 direction = _left;

//   // bool isHit = false;
//   // bool isShockElectric = false;
//   // bool isBurned = false;
//   // bool isDamaging = false;
//   double _timerDamaging = 0;

//   final Enemy enemy;
//   SequenceEffect? effect;
//   void Function()? onKilled;
//   final Vector2? targetPosition;
//   // bool isInsideChronosphere = false;

//   EnemySpriteComponent(
//     this.enemy,
//     Image image, {
//     Vector2? position,
//     this.targetPosition,
//     Vector2? size,
//     Vector2? scale,
//     double? angle,
//     Anchor? anchor,
//     int? priority,
//     int? arrmor,
//     Vector2? srcPosition,
//     Vector2? srcSize,
//   }) : super.fromImage(
//           image,
//           srcPosition: srcPosition,
//           srcSize: srcSize,
//           position: position,
//           size: size,
//           scale: scale,
//           angle: angle,
//           anchor: anchor,
//           priority: priority,
//         ) {
//     // if (targetPosition != null && position != null) {
//     //   // Need to sequence two move to effects so that we can
//     //   // tap into the onFinishCallback and flip the component.
//     //   effect = SequenceEffect(
//     //     [
//     //       MoveToEffect(
//     //         targetPosition,
//     //         EffectController(speed: 100),
//     //         onComplete: () {
//     //           flipHorizontallyAroundCenter();
//     //           direction = _right;
//     //         },
//     //       ),
//     //       MoveToEffect(
//     //         position + Vector2(32, 0), // Need to offset by 32 due to flip
//     //         EffectController(speed: 100),
//     //         onComplete: () {
//     //           flipHorizontallyAroundCenter();
//     //           direction = _left;
//     //         },
//     //       ),
//     //     ],
//     //     infinite: true,
//     //   );
//     //   add(effect!);
//     // }
//     initHealthBar(enemy.maxHealth, width);
//   }

//   @override
//   bool get debugMode => false;

//   @override
//   void update(double dt) {
//     super.update(dt);

//     if (isHit || isInsideChronosphere || isElectricShocked || isBurned) {
//       effect?.pause();
//     } else {
//       effect?.resume();
//     }

//     if (isDamaging && _timerDamaging > 1) {
//       isDamaging = false;
//       _timerDamaging = 0;
//     } else {
//       _timerDamaging += dt;
//     }
//   }

//   @override
//   Future<void> onLoad() async {
//     await add(CircleHitbox()..collisionType = CollisionType.passive);
//     maxHealth = enemy.maxHealth;
//     currentHealth = maxHealth;
//   }

//   @override
//   void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
//     onEnemyCollisionStart(intersectionPoints, other, game, enemy);

//     super.onCollisionStart(intersectionPoints, other);
//   }

//   @override
//   removeFromParent() {
//     onKilled?.call();
//     super.removeFromParent();
//   }
// }

// class EnemyAnimationComponent extends SpriteAnimationComponent
//     with HasGameRef<DestroyerGame>, HealthBar, CollisionCallbacks, EnemyCollision {
//   final Enemy enemy;

//   void Function()? onKilled;

//   EnemyAnimationComponent({required this.enemy, required super.size, required super.position, required super.priority});
//   late final Timer _timer;
//   final Vector2 _velocity = Vector2.zero();

//   int _secondCount = 0;

//   @override
//   FutureOr<void> onLoad() {
//     initHealthBar(enemy.maxHealth, width);
//     print('enemy loaded');
//     _timer = Timer(1, repeat: true, onTick: () {
//       if (currentHealth == 0) {
//         add(TimerComponent(
//           period: 1, // The period in seconds
//           onTick: () {
//             removeFromParent();
//           },
//         ));
//       }
//       if (_secondCount % 5 == 0) {
//         attack();
//         add(TimerComponent(
//           period: 0.6, // The period in seconds
//           onTick: () {
//             move();
//           },
//         ));
//       }
//       // if (_secondCount % 2 == 0) {
//       //   if (game.playerData.position.value.x > position.x) {
//       //     attack();
//       //   }
//       // }
//       _secondCount++;
//     });
//     move();
//     add(CircleHitbox());
//   }

//   @override
//   void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
//     onEnemyCollisionStart(intersectionPoints, other, game, enemy);
//     super.onCollisionStart(intersectionPoints, other);
//   }

//   @override
//   removeFromParent() {
//     onKilled?.call();
//     super.removeFromParent();
//   }

//   move() {
//     if (enemy is Boss) animation = (enemy as Boss).moveAnimation;
//     print(enemy is Boss);
//   }

//   attack() {
//     if (enemy is Boss) animation = (enemy as Boss).attackAnimation;
//   }

//   @override
//   void update(double dt) {
//     _timer.update(dt);
//     super.update(dt);
//   }

//   @override
//   void onRemove() {
//     _timer.stop();
//     super.onRemove();
//   }
// }
