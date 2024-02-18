import 'package:destroyer/models/equipments.dart';

final gameLevels = <GameLevel>[
  GameLevel.intro,
  GameLevel.lv1,
  GameLevel.lv2,
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

  static GameLevel intro = GameLevel(
    number: 1,
    title: 'Intro',
    mapTiled: 'intro.tmx',
    equipments: [Sword.desolator()],
    scenes: [
      Scene(0, mapTiled: 'intro.tmx'),
    ],
  );
  static GameLevel lv1 = GameLevel(number: 2, title: 'Purge the Phantom Garbage', mapTiled: 'Level1.tmx', equipments: [
    Sword.purifier(3),
    Sword.flame(3)
  ], scenes: [
    Scene(0, mapTiled: 'Level1.tmx'),
    Scene(1, mapTiled: 'Level2.tmx'),
  ]);
  static GameLevel lv2 = GameLevel(number: 3, title: 'Cleanup the IO Transporter', mapTiled: 'Level1.tmx', equipments: [
    Sword.purifier(4),
    Sword.time(4),
    Sword.flame(4),
    Sword.lightning(4),
    Sword.desolator(),
  ], scenes: [
    Scene(0, mapTiled: 'Level2.tmx'),
  ]);

  factory GameLevel.fromTiled(String mapTiled) {
    return gameLevels.firstWhere((element) => element.mapTiled == mapTiled);
  }
  GameLevel next() {
    if (number == gameLevels.length) {
      return GameLevel.intro;
    }
    return gameLevels.firstWhere((element) => element.number == number + 1);
  }

  @override
  String toString() {
    return 'GameLevel(number: $number, title: $title, mapTiled: $mapTiled, equipments: $equipments)';
  }
}

class Scene {
  final int index;
  final String mapTiled;

  Scene(this.index, {required this.mapTiled});
}
