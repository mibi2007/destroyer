import 'package:destroyer/models/equipments.dart';

final gameLevels = <GameLevel>[
  GameLevel.lv1,
  GameLevel.lv2,
  GameLevel.lv3,
  GameLevel.lv4,
  GameLevel.lv5,
  GameLevel.lv6,
];

class GameLevel {
  int number;
  String title;
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
    required this.equipments,
    required this.scenes,
  });

  static GameLevel lv1 = GameLevel(
    number: 1,
    title: 'Intro',
    equipments: [Sword.desolator()],
    scenes: [
      Scene(0, mapTiled: 'map1.tmx'),
    ],
  );
  static GameLevel lv2 = GameLevel(number: 2, title: 'Purge the Phantom Garbage', equipments: [
    Sword.purifier(2),
  ], scenes: [
    Scene(0, mapTiled: 'map2_1.tmx'),
    Scene(1, mapTiled: 'map2_2.tmx'),
  ]);
  static GameLevel lv3 = GameLevel(number: 3, title: 'Lv2 but Full Swords ^_^', equipments: [
    Sword.time(4),
    Sword.purifier(4),
    Sword.flame(4),
    Sword.lightning(4),
  ], scenes: [
    Scene(0, mapTiled: 'map2_1.tmx'),
    Scene(1, mapTiled: 'map2_2.tmx'),
  ]);
  static GameLevel lv4 = GameLevel(number: 4, title: 'Demo treasure hunt', equipments: [
    Sword.purifier(4),
    Sword.flame(3),
  ], scenes: [
    Scene(0, mapTiled: 'map3.tmx'),
    Scene(1, mapTiled: 'map4.tmx'),
  ]);
  static GameLevel lv5 = GameLevel(number: 5, title: 'Treasure hunt Full Swords', equipments: [
    Sword.purifier(4),
    Sword.time(4),
    Sword.flame(4),
    Sword.lightning(4),
  ], scenes: [
    Scene(0, mapTiled: 'map3.tmx'),
    Scene(1, mapTiled: 'map4.tmx'),
  ]);
  static GameLevel lv6 = GameLevel(number: 6, title: 'Solo Boss Full Equipments', equipments: [
    Sword.purifier(4),
    Sword.time(4),
    Sword.flame(4),
    Sword.lightning(4),
    Armor.helmet(),
    Armor.chestpiece(),
    Armor.gauntlets(),
    Armor.leggings(),
    Armor.boots(),
  ], scenes: [
    Scene(0, mapTiled: 'map5.tmx'),
  ]);

  static GameLevel end = GameLevel(number: -1, title: 'End', equipments: [], scenes: []);

  GameLevel next() {
    if (number == gameLevels.length) {
      return GameLevel.end;
    }
    return gameLevels.firstWhere((element) => element.number == number + 1);
  }

  @override
  String toString() {
    return 'GameLevel(number: $number, title: $title, equipments: $equipments)';
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
