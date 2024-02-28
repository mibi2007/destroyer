import 'package:destroyer/models/equipments.dart';

final gameLevels = <GameLevel>[
  GameLevel.lv1,
  GameLevel.lv2,
  GameLevel.lv3,
  // (number: 2, title: 'Purge the Phantom Garbage', mapTiled: 'map.tmx', equipments: [Sword.purifier(1)]),
  // (number: 3, title: 'Cleanup the IO Transporter', mapTiled: 'Level2.tmx', equipments: [Sword.purifier(1)]),
];

class GameLevel {
  int number;
  String title;
  String mapTiled;
  List<Equipment> equipments;
  List<Scene> scenes;
  int sceneIndex = 0;
  Scene get currentScene => scenes[sceneIndex];
  set currentScene(Scene scene) {
    sceneIndex = scenes.indexOf(scene);
  }

  GameLevel({
    required this.number,
    required this.title,
    required this.mapTiled,
    required this.equipments,
    required this.scenes,
  });

  static GameLevel lv1 = GameLevel(
    number: 1,
    title: 'Intro',
    mapTiled: 'intro.tmx',
    equipments: [Sword.desolator()],
    scenes: [
      Scene(0, mapTiled: 'map1.tmx'),
    ],
  );
  static GameLevel lv2 = GameLevel(number: 2, title: 'Purge the Phantom Garbage', mapTiled: 'Level1.tmx', equipments: [
    Sword.purifier(4),
    Sword.time(4),
    Sword.flame(4),
    Sword.lightning(4),
  ], scenes: [
    Scene(0, mapTiled: 'map2_1.tmx'),
    Scene(1, mapTiled: 'map2_2.tmx'),
  ]);
  static GameLevel lv3 = GameLevel(number: 3, title: 'Cleanup the IO Transporter', mapTiled: 'Level1.tmx', equipments: [
    Sword.purifier(4),
    Sword.time(4),
    Sword.flame(4),
    Sword.lightning(4),
  ], scenes: [
    Scene(0, mapTiled: 'map3.tmx'),
  ]);

  factory GameLevel.fromTiled(String mapTiled) {
    return gameLevels.firstWhere((element) => element.mapTiled == mapTiled);
  }
  GameLevel next() {
    if (number == gameLevels.length) {
      return GameLevel.lv1;
    }
    return gameLevels.firstWhere((element) => element.number == number + 1);
  }

  @override
  String toString() {
    return 'GameLevel(number: $number, title: $title, mapTiled: $mapTiled, equipments: $equipments)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GameLevel && other.number == number;
  }

  @override
  int get hashCode {
    return number.hashCode;
  }
}

class Scene {
  final int index;
  final String mapTiled;

  Scene(this.index, {required this.mapTiled});
}
