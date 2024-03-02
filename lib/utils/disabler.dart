import 'package:flutter/foundation.dart';

export 'disabler_other.dart' if (dart.library.html) 'disabler_web.dart' if (dart.library.window) 'disabler_window.dart';

final rightClick = RightClick();
final leftClick = LeftClick();
final tabClick = TabClick();
final escClick = EscClick();

class RightClick extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}

class LeftClick extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}

class TabClick extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}

class EscClick extends ChangeNotifier {
  void update() {
    notifyListeners();
  }
}
