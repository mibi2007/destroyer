import 'dart:ui' as ui;

import 'package:flame/components.dart';

class ChronosphereSkillComponent extends PositionComponent {
  double radious = 0;
  final double duration;

  late ui.Paint paint;
  late ui.Image image;
  ChronosphereSkillComponent(this.duration, {required super.position}) : super(priority: 3);

  @override
  Future<void> onLoad() async {
    // add()
    print('onLoad');
    paint = ui.Paint()
      ..color = const ui.Color(0xFFFF0000)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2;
  }
}
