import 'dart:convert';

import 'package:destroyer/models/equipments.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'player_progress_persistence.dart';

/// An implementation of [PlayerProgressPersistence] that uses
/// `package:shared_preferences`.
class LocalStoragePlayerProgressPersistence extends PlayerProgressPersistence {
  final Future<SharedPreferences> instanceFuture = SharedPreferences.getInstance();

  @override
  Future<List<int>> getFinishedLevels() async {
    final prefs = await instanceFuture;
    final serialized = prefs.getStringList('levelsFinished') ?? [];

    return serialized.map(int.parse).toList();
  }

  @override
  Future<void> saveLevelFinished(int level, int time) async {
    final prefs = await instanceFuture;
    final serialized = prefs.getStringList('levelsFinished') ?? [];
    if (level <= serialized.length) {
      final currentTime = int.parse(serialized[level - 1]);
      if (time < currentTime) {
        serialized[level - 1] = time.toString();
      }
    } else {
      serialized.add(time.toString());
    }
    await prefs.setStringList('levelsFinished', serialized);
  }

  @override
  Future<void> reset() async {
    final prefs = await instanceFuture;
    await prefs.remove('levelsFinished');
    await prefs.remove('credits');
    await prefs.remove('equipments');
  }

  @override
  Future<int> getCredits() async {
    final prefs = await instanceFuture;
    final credits = prefs.getInt('credits') ?? 0;

    return credits;
  }

  @override
  Future<void> saveCredits(int newCredits) async {
    final prefs = await instanceFuture;
    await prefs.setInt('credits', newCredits);
  }

  @override
  Future<List<Equipment>> getEquipments() async {
    final prefs = await instanceFuture;
    final serialized = prefs.getStringList('equipments') ?? [];

    return serialized.map(jsonDecode).map((data) {
      final json = data as Map<String, dynamic>;
      if (json.containsKey('sword_type')) {
        return Equipment.fromJson<Sword>(json);
      } else {
        return Equipment.fromJson(json);
      }
    }).toList();
  }

  // @override
  // Future<void> addEquipment(Equipment equipment) async {
  //   final equipments = await getEquipments();
  //   if (!equipments.contains(equipment)) {
  //     equipments.add(equipment);
  //     await saveEquipments(equipments);
  //   }
  // }

  @override
  Future<void> saveEquipments(List<Equipment> equipments) async {
    final prefs = await instanceFuture;
    final serialized = equipments.map((equipment) {
      return jsonEncode(equipment.toJson());
    }).toList();
    await prefs.setStringList('equipments', serialized);
  }
}
