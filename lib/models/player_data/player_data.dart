import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../equipments.dart';
import '../skills.dart';

class Direction {
  final Vector2 direction;
  late bool isLeft;
  late bool isRight;
  late double x;
  Direction(this.direction) {
    isLeft = direction.x == -1;
    isRight = direction.x == 1;
    x = direction.x;
  }

  @override
  String toString() {
    return 'Direction: left: $isLeft, right: $isRight';
  }
}

class PlayerData {
  // Store credits and equipments to storage, here is just a notifier
  final credits = CreditNotifier();
  final equipments = EquipmentsNotifier();

  final health = ValueNotifier<int>(100);
  final armor = ValueNotifier<int>(5);
  final inventory = ValueNotifierList<Equipment>([]);
  final sword = ValueNotifier<Sword>(Sword.desolator());
  final lastSword = ValueNotifier<Sword?>(null);
  final skills = ValueNotifierList<Skill>([]);
  final position = ValueNotifier<Vector2>(Vector2.zero());
  final aim = ValueNotifier<double>(0);
  final direction = ValueNotifier<Direction>(Direction(Vector2(1, 0)));
  final angleToSigned = ValueNotifier<double>(0);
  final currentMousePosition = ValueNotifier<Vector2>(Vector2.zero());
  final effects = ValueNotifierList<SkillEffect>([]);
  final selectedTarget = ValueNotifier<PositionComponent?>(null);
  final selectedLocation = ValueNotifier<Vector2?>(null);
  final skillCountdown = ValueNotifierList<bool>([]);
  final casting = ValueNotifier<Skill?>(null);
  final autoAttack = DoubleTapNotifier();
  final souls = ValueNotifier<int>(0);
  final garbages = ValueNotifier<int>(0);
  final isDead = ValueNotifier<bool>(false);
}

class ValueNotifierList<T> extends ValueNotifier<List<T>> {
  ValueNotifierList(super.value);

  addAll(Iterable<T> newValues) {
    for (final newValue in newValues) {
      if (!value.contains(newValue)) value.add(newValue);
    }
    notifyListeners();
  }

  void updateAt(int index, T indexValue) {
    value[index] = indexValue;
    notifyListeners();
  }

  void remove(T indexValue, {bool shouldNotify = false}) {
    final success = value.remove(indexValue);
    if (success && shouldNotify) notifyListeners();
  }

  void removeAll(List<T> indexValues) {
    if (indexValues.isEmpty) return;
    for (final indexValue in indexValues) {
      value.remove(indexValue);
    }
    notifyListeners();
  }

  void add(T newValue) {
    if (!value.contains(newValue)) {
      value.add(newValue);
      notifyListeners();
    }
  }
}

class CreditNotifier extends ChangeNotifier {
  void change() {
    notifyListeners();
  }
}

class EquipmentsNotifier extends ChangeNotifier {
  void change() {
    notifyListeners();
  }
}

class DoubleTapNotifier extends ChangeNotifier {
  void trigger() {
    notifyListeners();
  }
}
