import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/widgets.dart';

import '../../level_selection/levels.dart';

const backgroundDefault = [
  'assets/images/scenery/background1.png',
  'assets/images/scenery/background2.png',
  'assets/images/scenery/background3.png',
  'assets/images/scenery/background4a.png',
];

const background1 = backgroundDefault;
const background2 = [
  'assets/images/scenery/1.png',
  'assets/images/scenery/2.png',
  'assets/images/scenery/3.png',
  'assets/images/scenery/4.png',
  'assets/images/scenery/5.png',
  'assets/images/scenery/6.png',
];

/// The [Background] is a component that is composed of multiple scrolling
/// images which form a parallax, a way to simulate movement and depth in the
/// background.
class Background extends ParallaxComponent {
  final GameLevel level;
  final int sceneIndex;
  Background(this.level, this.sceneIndex);

  double speed = 0;
  @override
  Future<void> onLoad() async {
    final List<ParallaxImageData> layers = [];
    if (level == GameLevel.lv1) {
      layers.addAll(background1.map((image) => ParallaxImageData(image)));
    } else if (level == GameLevel.lv2 || level == GameLevel.lv3) {
      layers.addAll(background2.map((image) => ParallaxImageData(image)));
    } else {
      layers.addAll(backgroundDefault.map((image) => ParallaxImageData(image)));
    }

    // The base velocity sets the speed of the layer the farthest to the back.
    // Since the speed in our game is defined as the speed of the layer in the
    // front, where the player is, we have to calculate what speed the layer in
    // the back should have and then the parallax will take care of setting the
    // speeds for the rest of the layers.
    // final baseVelocity = Vector2(speed / pow(2, layers.length), 0);

    // The multiplier delta is used by the parallax to multiply the speed of
    // each layer compared to the last, starting from the back. Since we only
    // want our layers to move in the X-axis, we multiply by something larger
    // than 1.0 here so that the speed of each layer is higher the closer to the
    // screen it is.
    // final velocityMultiplierDelta = baseVelocity;

    parallax = await game.loadParallax(
      layers,
      baseVelocity: Vector2(0, 0),
      velocityMultiplierDelta: Vector2(1.8, 1.8),
      filterQuality: FilterQuality.none,
    );
  }
}

getVelocity(GameLevel level, int sceneIndex) {
  if (level == GameLevel.lv2) {
    return 0;
  } else {
    return 1.8;
  }
}
