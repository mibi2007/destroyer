import 'package:flutter/foundation.dart';

import '../models/skills.dart';

class SwordConfig {
  static final purifier = ValueNotifier<Skill?>(null);
  static final time = ValueNotifier<Skill?>(null);
  static final flame = ValueNotifier<Skill?>(null);
  static final lightning = ValueNotifier<Skill?>(null);
}
