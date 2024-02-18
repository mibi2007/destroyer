import 'package:flutter/services.dart';

const Map<String, LogicalKeyboardKey> _keyMapping = {
  'Q': LogicalKeyboardKey.keyQ, // Rebel
  'E': LogicalKeyboardKey.keyE, // Engel Guardian
  'R': LogicalKeyboardKey.keyR, // Time Walk
  'F': LogicalKeyboardKey.keyF, // Chronosphere
  'Z': LogicalKeyboardKey.keyZ, // Equiem of Souls
  'X': LogicalKeyboardKey.keyX, // Ball Lightning
  'C': LogicalKeyboardKey.keyC, // Thunder Strike
};

extension LogicalKeyboardKeyX on LogicalKeyboardKey {
  fromLabelKey(String label) {
    return _keyMapping[label.toUpperCase()] ?? LogicalKeyboardKey.space;
  }
}

LogicalKeyboardKey fromLabelKey(String label) {
  return _keyMapping[label.toUpperCase()] ?? LogicalKeyboardKey.space;
}
