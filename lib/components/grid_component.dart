import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../game.dart';
import '../settings/table_settings.dart';

class GridComponent extends PositionComponent with Tappable, HasGameRef<MyGame> {

  final Vector2? _gridSpaceSize;
  Vector2 get gridSpaceSize => _gridSpaceSize ?? TableSettings.gridPieceSize;
  final Vector2 hoverPieceSize;
  final int maximumUnreachableAreaLines;

  final void Function(int xIndex, int yIndex) onTap;

  Vector2 mousePosition = Vector2.zero();

  final Paint _unreachbleAreaPaint;
  final Paint _minimumHeightLinePaint;
  final Paint _gridLinePaint;
  final Paint _hoveringPaint;

  GridComponent({
    required this.onTap,
    required this.hoverPieceSize,
    this.maximumUnreachableAreaLines = TableSettings.maximumHeight,
    Vector2? gridSpaceSize,
    double strokeWidth = 2,
    Color gridColor = TableSettings.gridLinesColor,
    Color unreachbleAreaColor = TableSettings.unreachbleAreaColor,
    Color hoverPieceColor = TableSettings.hoverColor,
  })  : _gridSpaceSize = gridSpaceSize,
        _gridLinePaint = Paint()
          ..color = gridColor
          ..strokeWidth = strokeWidth,
        _minimumHeightLinePaint = Paint()
          ..color = gridColor
          ..strokeWidth = strokeWidth * 2,
        _unreachbleAreaPaint = Paint()..color = unreachbleAreaColor,
        _hoveringPaint = Paint()..color = hoverPieceColor,
        super(anchor: Anchor.topLeft);

  @override
  void update(double dt) {
    position = game.camera.position;
    size = game.camera.gameSize;
  }

  @override
  void render(Canvas canvas) {
    _renderUnreachbleArea(canvas);
    _renderGrid(canvas);
    _renderMinimumHeightLine(canvas);
    _renderHoverSquare(canvas);
  }

  void _renderMinimumHeightLine(Canvas canvas) {
    if (game.camera.position.y <= (maximumUnreachableAreaLines * gridSpaceSize.y)) {
      final lineYPosition = (maximumUnreachableAreaLines * gridSpaceSize.y) - position.y;

      canvas.drawLine(
        Offset(
          0,
          lineYPosition,
        ),
        Offset(
          game.camera.gameSize.x,
          lineYPosition,
        ),
        _minimumHeightLinePaint,
      );
    }
  }

  void _renderUnreachbleArea(Canvas canvas) {
    if (game.camera.position.y <= (maximumUnreachableAreaLines * gridSpaceSize.y)) {
      final lineYPosition = (maximumUnreachableAreaLines * gridSpaceSize.y) - position.y;

      canvas.drawRect(
        Rect.fromLTRB(
          0,
          0,
          game.size.x,
          lineYPosition,
        ),
        _unreachbleAreaPaint,
      );
    }
  }

  void _renderGrid(Canvas canvas) {
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

    if (hoveringPosition.y >= (maximumUnreachableAreaLines * gridSpaceSize.y)) {
      final padding = Vector2(
        (gridSpaceSize.x - hoverPieceSize.x) / 2,
        (gridSpaceSize.y - hoverPieceSize.y) / 2,
      );

      final xAdjust = -position.x;
      final yAdjust = -position.y;

      canvas.drawRect(
        Rect.fromLTWH(
          (hoveringPosition.x + padding.x) + xAdjust,
          (hoveringPosition.y + padding.y) + yAdjust,
          hoverPieceSize.x,
          hoverPieceSize.y,
        ),
        _hoveringPaint,
      );
    }
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
