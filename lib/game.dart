import 'dart:async';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';

import 'components/table.dart';

class MyGame extends FlameGame with HasTappables, MouseMovementDetector, ScaleDetector, ScrollDetector {
  late Table _table;

  bool isInBuildPhase = true;

  static const pauseOverlay = "PauseOverlay";
  static const buildingPhaseOverlay = "BuildingPhaseOverlay";
  static const runningPhaseOverlay = "RunningPhaseOverlay";

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  void play() {
    isInBuildPhase = false;
    overlays.add(runningPhaseOverlay);
    overlays.remove(buildingPhaseOverlay);
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    _table.onMouseMove(info);
  }

  @override
  FutureOr<void> onLoad() {
    _table = Table();
    camera.speed = 600;

    add(_table);
  }

  static late double startZoom;
  static Vector2? previousScale;

  @override
  void onScaleStart(info) {
    startZoom = camera.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final oldCameraGameSize = camera.gameSize;

    final currentScale = info.scale.global;
    previousScale ??= currentScale;

    if (!currentScale.isIdentity()) {
      final scaleDifference = currentScale - previousScale!;
      final newZoom = (scaleDifference.length * 0.08);

      if (currentScale.length < previousScale!.length) {
        camera.zoom -= newZoom;
      } else {
        camera.zoom += newZoom;
      }

      clampZoom();
      camera.snapTo(camera.position - (camera.gameSize - oldCameraGameSize).scaled(0.5));
    } else {
      camera.translateBy(-info.delta.game);
      camera.snap();
    }
    clampPosition();

    previousScale = currentScale;
  }

  static const zoomPerScrollUnit = 0.02;

  void clampZoom() {
    camera.zoom = camera.zoom.clamp(0.1, 2.0);
  }

  void clampPosition() {
    if (camera.position.y < 0) {
      camera.translateBy(Vector2(0, -camera.position.y));
    }
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final oldCameraGameSize = camera.gameSize;

    camera.zoom -= info.scrollDelta.game.y.sign * zoomPerScrollUnit;
    clampZoom();
    // make the zoom centralized
    camera.snapTo(camera.position - (camera.gameSize - oldCameraGameSize).scaled(0.5));
  }

  @override
  void onMount() {
    oldGameSize = size;
    super.onMount();
  }

  static Vector2? oldGameSize;

  @override
  void onGameResize(Vector2 size) {
    if (oldGameSize != null) {
      camera.translateBy(
        size.clone()
          ..sub(oldGameSize!)
          ..scale(0.5)
          ..invert(),
      );
    }

    oldGameSize = size;
    super.onGameResize(size);
  }
}
