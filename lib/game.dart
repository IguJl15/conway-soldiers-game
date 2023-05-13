import 'dart:async';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'components/table.dart';

class MyGame extends FlameGame with HasTappables, MouseMovementDetector {
  late Table _table;

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  MyGame() : super();

  @override
  void onMouseMove(PointerHoverInfo info) {
    _table.onMouseMove(info);
  }

  @override
  FutureOr<void> onLoad() {
    _table = Table();

    add(_table);
  }
}
