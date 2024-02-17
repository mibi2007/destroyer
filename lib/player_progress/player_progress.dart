import 'dart:async';

import 'package:destroyer/models/equipments.dart';
import 'package:flutter/foundation.dart';

import 'persistence/local_storage_player_progress_persistence.dart';
import 'persistence/player_progress_persistence.dart';

/// Encapsulates the player's progress.
class PlayerProgress extends ChangeNotifier {
  PlayerProgress({PlayerProgressPersistence? store}) : _store = store ?? LocalStoragePlayerProgressPersistence() {
    getLatestFromStore();
  }

  /// TODO: If needed, replace this with some other mechanism for saving
  ///       the player's progress. Currently, this uses the local storage
  ///       (i.e. NSUserDefaults on iOS, SharedPreferences on Android
  ///       or local storage on the web).
  final PlayerProgressPersistence _store;

  List<int> _levelsFinished = [];

  /// The times for the levels that the player has finished so far.
  List<int> get levels => _levelsFinished;

  int _credits = 0;

  int get credits => _credits;

  List<Equipment> _equipments = [];

  /// Fetches the latest data from the backing persistence store.
  Future<void> getLatestFromStore() async {
    final levelsFinished = await _store.getFinishedLevels();
    if (!listEquals(_levelsFinished, levelsFinished)) {
      _levelsFinished = levelsFinished;
      notifyListeners();
    }
    final credits = await _store.getCredits();
    if (_credits != credits) {
      _credits = await _store.getCredits();
      notifyListeners();
    }
    final equipments = await _store.getEquipments();
    if (!listEquals(_equipments, equipments)) {
      _equipments = equipments;
      notifyListeners();
    }
  }

  /// Resets the player's progress so it's like if they just started
  /// playing the game for the first time.
  void reset() {
    _store.reset();
    _levelsFinished.clear();
    _equipments.clear();
    notifyListeners();
  }

  /// Registers [level] as reached.
  ///
  /// If this is higher than [highestLevelReached], it will update that
  /// value and save it to the injected persistence store.
  void setLevelFinished(int level, int time) {
    if (level < _levelsFinished.length - 1) {
      final currentTime = _levelsFinished[level - 1];
      if (time < currentTime) {
        _levelsFinished[level - 1] = time;
        notifyListeners();
        unawaited(_store.saveLevelFinished(level, time));
      }
    } else {
      _levelsFinished.add(time);
      notifyListeners();
      unawaited(_store.saveLevelFinished(level, time));
    }
  }

  void setCredits(int newCredits) {
    if (newCredits != _credits) {
      _credits = newCredits;
      notifyListeners();
      unawaited(_store.saveCredits(newCredits));
    }
  }

  int getCredits() {
    return _credits;
  }

  bool setEquipments(List<Equipment> newEquipments) {
    if (newEquipments.length != _equipments.length ||
        newEquipments.any((equipment) => !_equipments.contains(equipment))) {
      _equipments = newEquipments;
      notifyListeners();
      unawaited(_store.saveEquipments(_equipments));
      return true;
    }
    return false;
  }

  bool addEquipment(Equipment equipment) {
    if (!_equipments.contains(equipment)) {
      _equipments.add(equipment);
      notifyListeners();
      unawaited(_store.saveEquipments(_equipments));
      return true;
    }
    return false;
  }

  List<Equipment> getEquipments() {
    return _equipments;
  }
}
