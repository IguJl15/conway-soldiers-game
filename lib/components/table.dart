import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../game.dart';
import '../settings/table_settings.dart';

class Table extends PositionComponent with Tappable, HasGameRef<MyGame> {
  /// Map of Columns -> Rows -> TablePiece
  Map<int, Map<int, TablePiece>> createdPieces = {};
  Vector2 mousePosition = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    size = game.size;
    return super.onLoad();
  }

  static const hoveringPadding = 5;

  static const double spaceSize = 40;
  static const double gridSpaceSize = 50;
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  final gridLinePaint = Paint()
    ..color = const Color(0xFF505050)
    ..strokeWidth = 2;

  @override
  bool onTapDown(TapDownInfo info) {
    final position = _hoveredSquarePosition(mousePosition);
    final Vector2 mapPosition = position.clone()..scale(1 / gridSpaceSize);

    final existingPiece = createdPieces[mapPosition.x]?[mapPosition.y];

    if (existingPiece != null) {
      _removePiece(mapPosition.x.toInt(), mapPosition.y.toInt());
      return true;
    }

    _addPiece(mapPosition.x.toInt(), mapPosition.y.toInt());

    return true;
  }


  Vector2 _hoveredSquarePosition(Vector2 mouseLocation) {
    double mouseX = mouseLocation.x;
    double mouseY = mouseLocation.y;
    if (mousePosition.x < 0) mouseX -= gridSpaceSize;
    if (mousePosition.y < 0) mouseY -= gridSpaceSize;
    return Vector2(
      (mouseX ~/ gridSpaceSize) * gridSpaceSize,
      (mouseY ~/ gridSpaceSize) * gridSpaceSize,
      );
  }

  void onMouseMove(PointerHoverInfo info) => mousePosition = info.eventPosition.game;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _renderGrid(canvas);
    _renderHoverSquare(canvas);
  }

  void _addPiece(int x, int y) {
    final newPiece = TablePiece(
      columnIndex: x,
      rowIndex: y,
      size: Vector2.all(spaceSize),
    );

    add(newPiece);

    if (createdPieces.containsKey(x)) {
      if (createdPieces[x]!.containsKey(y)) {
        return;
      } else {
        debugPrint("Existent column");
        createdPieces[x]!.addAll({y: newPiece});
      }
    } else {
      debugPrint("Never inserted in that column");
      createdPieces.addAll({
        x: {y: newPiece}
      });
    }
  }

  void _removePiece(int x, int y) {
    remove(createdPieces[x]![y]!);
    createdPieces[x]!.remove(y);
  }

  void _renderHoverSquare(Canvas canvas) {
    final hoveringPosition = _hoveredSquarePosition(mousePosition);

    canvas.drawRect(
        Rect.fromLTWH(
          hoveringPosition.x + hoveringPadding,
          hoveringPosition.y + hoveringPadding,
          gridSpaceSize - (hoveringPadding * 2),
          gridSpaceSize - (hoveringPadding * 2),
        ),
        _hoveringPaint);
  }

  void _renderGrid(Canvas canvas) {
    final cameraPosition = game.camera.position;
    final gameSize = game.camera.gameSize;

    final cameraYPositionToNextRow = cameraPosition.y % gridSpaceSize;
    final cameraXPositionToNextRow = cameraPosition.x % gridSpaceSize;

    final verticalLines = gameSize.x ~/ gridSpaceSize;
    final horizontalLines = gameSize.y ~/ gridSpaceSize;

    for (var i = 1; i <= verticalLines + 1; i++) {
      final lineXPosition = cameraPosition.x - cameraXPositionToNextRow + (i * gridSpaceSize);
      canvas.drawLine(
        Offset(lineXPosition, cameraPosition.y),
        Offset(lineXPosition, cameraPosition.y + gameSize.y),
        _gridLinePaint,
      );
    }

    for (var i = 1; i <= horizontalLines + 1; i++) {
      final lineYPosition = cameraPosition.y - cameraYPositionToNextRow + (i * gridSpaceSize);

      canvas.drawLine(
        Offset(cameraPosition.x, lineYPosition),
        Offset(cameraPosition.x + gameSize.x, lineYPosition),
        _gridLinePaint,
      );
    }
  }
}

class TablePiece extends RectangleComponent {
  final int rowIndex;
  final int columnIndex;

  TablePiece({
    required this.columnIndex,
    required this.rowIndex,
    required super.size,
  }) : super(
          position: Vector2(
            columnIndex * Table.gridSpaceSize + Table.paddingFromGridToPieceSpace,
            rowIndex * Table.gridSpaceSize + Table.paddingFromGridToPieceSpace,
          ),
          anchor: Anchor.topLeft,
        );

  @override
  void update(double dt) {
    if (size.x != Table.spaceSize) size = Vector2.all(Table.spaceSize);
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (paint.color != TableSettings.pieceColor) {
      paint.color = TableSettings.pieceColor;
    }
    super.render(canvas);
  }
}

class TableSpace extends RectangleComponent with Hoverable, Tappable {
  static const double gap = 4;
  static const double borderSize = 2;
  static const double spaceSize = 100;
  static final initialPostionOffset = Vector2(100, 100);
  final strokePaint = Paint()
    ..color = TableSettings.borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = borderSize * 2;

  final int index;

  TableSpace(this.index)
      : super.square(
          size: spaceSize,
          paint: Paint(),
          anchor: Anchor.topLeft,
          position: positionByindex(index),
        ) {
    paint.color = TableSettings.backgroundColor;
  }

  static positionByindex(int index) => Vector2(
        (index % TableSettings.dimension) * spaceSize + (index % TableSettings.dimension) * gap,
        index ~/ TableSettings.dimension * spaceSize + index ~/ TableSettings.dimension * gap,
      );

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    paint.color = TableSettings.hoverColor;
    return true;
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    paint.color = TableSettings.backgroundColor;
    return true;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), strokePaint);
    super.render(canvas);
  }
}
