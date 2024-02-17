import 'dart:core';

import 'package:destroyer/models/equipments.dart';

import 'player_progress_persistence.dart';

/// An in-memory implementation of [PlayerProgressPersistence].
/// Useful for testing.
class MemoryOnlyPlayerProgressPersistence implements PlayerProgressPersistence {
  final levels = <int>[];
  int credits = 0;
  final equipments = <Equipment>[];

  @override
  Future<List<int>> getFinishedLevels() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return levels;
  }

  @override
  Future<void> saveLevelFinished(int level, int time) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (level < levels.length - 1 && levels[level - 1] > time) {
      levels[level - 1] = time;
    }
  }

  @override
  Future<void> reset() async {
    levels.clear();
    credits = 0;
    equipments.clear();
  }

  @override
  Future<int> getCredits() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return credits;
  }

  @override
  Future<void> saveCredits(int newCredits) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (newCredits != credits) {
      credits = newCredits;
    }
  }

  @override
  Future<List<Equipment>> getEquipments() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return equipments;
  }

  // @override
  // Future<void> addEquipment(Equipment equipment) async {
  //   await Future<void>.delayed(const Duration(milliseconds: 500));

  //   if (!equipments.contains(equipment)) {
  //     equipments.add(equipment);
  //   }
  // }

  @override
  Future<void> saveEquipments(List<Equipment> newEquipments) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    equipments.clear();
    equipments.addAll(newEquipments);
  }
}
