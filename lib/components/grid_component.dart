import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../game.dart';

import '../settings/table_settings.dart';

class GridComponent extends PositionComponent with Tappable, HasGameRef<MyGame> {
  final Vector2 gridSpaceSize;
  final Vector2 hoverPieceSize;

  final void Function(int xIndex, int yIndex) onTap;

  Vector2 mousePosition = Vector2.zero();

  final Paint _gridLinePaint;
  final Paint _hoveringPaint;

  GridComponent({
    required this.onTap,
    required this.gridSpaceSize,
    required this.hoverPieceSize,
    double strokeWidth = 2,
    Color color = TableSettings.gridLinesColor,
    Color hoverPieceColor = TableSettings.hoverColor,
  })  : _gridLinePaint = Paint()
          ..color = color
          ..strokeWidth = strokeWidth,
        _hoveringPaint = Paint()..color = hoverPieceColor,
        super(anchor: Anchor.topLeft);

  @override
  void update(double dt) {
    position = game.camera.position;
    size = game.camera.gameSize;
  }

  @override
  void render(Canvas canvas) {
    _renderGrid(canvas);
    _renderHoverSquare(canvas);
  }

  void _renderGrid(Canvas canvas) {
    // final cameraPosition = game.camera.position;
    final cameraXPositionToNextRow = position.x % gridSpaceSize.x;
    final cameraYPositionToNextRow = position.y % gridSpaceSize.y;

    final gameSize = game.camera.gameSize;
    final verticalLines = gameSize.x ~/ gridSpaceSize.x;
    final horizontalLines = gameSize.y ~/ gridSpaceSize.y;

    for (var i = 0; i <= verticalLines; i++) {
      final lineXPosition = -cameraXPositionToNextRow + (i * gridSpaceSize.x);
      canvas.drawLine(
        Offset(lineXPosition, 0),
        Offset(lineXPosition, gameSize.y),
        _gridLinePaint,
      );
    }

    for (var i = 1; i <= horizontalLines + 1; i++) {
      final lineYPosition = -cameraYPositionToNextRow + (i * gridSpaceSize.y);

      canvas.drawLine(
        Offset(
          0,
          lineYPosition,
        ),
        Offset(
          gameSize.x,
          lineYPosition,
        ),
        _gridLinePaint,
      );
    }
  }

  void onMouseMove(PointerHoverInfo info) => mousePosition = info.eventPosition.game;

  @override
  bool onTapUp(TapUpInfo info) {
    final hoveringPosition = _hoveredSquarePosition(mousePosition);

    final int xIndex = hoveringPosition.x ~/ gridSpaceSize.x;
    final int yIndex = hoveringPosition.y ~/ gridSpaceSize.y;

    onTap(xIndex, yIndex);

    return super.onTapUp(info);
  }

  void _renderHoverSquare(Canvas canvas) {
    final hoveringPosition = _hoveredSquarePosition(mousePosition);
    final padding = (gridSpaceSize.x - hoverPieceSize.x) / 2;

    final xAdjust = -position.x;
    final yAdjust = -position.y;

    canvas.drawRect(
        Rect.fromLTWH(
          (hoveringPosition.x + padding) + xAdjust,
          (hoveringPosition.y + padding) + yAdjust,
          hoverPieceSize.x,
          hoverPieceSize.y,
        ),
        _hoveringPaint);
  }

  Vector2 _hoveredSquarePosition(Vector2 mouseLocation) {
    mouseLocation = mouseLocation.clone();

    mouseLocation.x -= mouseLocation.x < 0 ? gridSpaceSize.x : 0;
    mouseLocation.y -= mouseLocation.y < 0 ? gridSpaceSize.y : 0;

    return Vector2(
      (mouseLocation.x ~/ gridSpaceSize.x) * gridSpaceSize.x,
      (mouseLocation.y ~/ gridSpaceSize.y) * gridSpaceSize.y,
    );
  }
}
