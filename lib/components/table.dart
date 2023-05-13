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

  @override
  void onParentResize(Vector2 maxSize) {
    size = maxSize;
    super.onParentResize(maxSize);
  }

  static const double spaceSize = 100;
  final strokePaint = Paint()
    ..color = TableSettings.borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  final gridLinePaint = Paint()
    ..color = const Color(0xFF505050)
    ..strokeWidth = 2;

  @override
  bool onTapDown(TapDownInfo info) {
    final position = _hoveredSquarePosition(mousePosition);
    final Vector2 mapPosition = position.clone()..scale(1 / spaceSize);

    final existingPiece = createdPieces[mapPosition.x]?[mapPosition.y];

    if (existingPiece != null) {
      _removePiece(mapPosition.x.toInt(), mapPosition.y.toInt());
      return true;
    }

    _addPiece(mapPosition.x.toInt(), mapPosition.y.toInt());

    return true;
  }

  Vector2 _hoveredSquarePosition(Vector2 mouseLocation) => Vector2(
        (mouseLocation.x ~/ spaceSize).toDouble() * spaceSize,
        (mouseLocation.y ~/ spaceSize).toDouble() * spaceSize,
      );

  void onMouseMove(PointerHoverInfo info) => mousePosition = info.eventPosition.game;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    _renderGrid(canvas);
    _renderHoverSquare(canvas);
  }

  void _addPiece(int x, int y) {
    final position = _hoveredSquarePosition(mousePosition);

    final newPiece = TablePiece(
      position: position,
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
    canvas.drawRect(Rect.fromLTWH(hoveringPosition.x, hoveringPosition.y, spaceSize, spaceSize), strokePaint);
  }

  void _renderGrid(Canvas canvas) {
    final verticalLines = game.camera.canvasSize.x ~/ spaceSize;
    final horizontalLines = game.camera.canvasSize.y ~/ spaceSize;

    // debugPrint("rendering lines");
    // debugPrint("Verticals: $verticalLines");
    // debugPrint("Horizontals: $horizontalLines");

    for (var i = 1; i <= verticalLines; i++) {
      canvas.drawLine(
        Offset(i * spaceSize, 0),
        Offset(i * spaceSize, game.camera.canvasSize.y),
        gridLinePaint,
      );
    }
    for (var i = 1; i <= horizontalLines; i++) {
      canvas.drawLine(
        Offset(0, i * spaceSize),
        Offset(game.camera.canvasSize.x, i * spaceSize),
        gridLinePaint,
      );
    }
  }
}

class TablePiece extends RectangleComponent {
  TablePiece({required super.position, required super.size})
      : super(
          anchor: Anchor.topLeft,
        );

  @override
  void render(Canvas canvas) {
    if (paint.color != TableSettings.pieceColor) {
      paint.color = TableSettings.pieceColor;
    }
    super.render(canvas);
  }

  // @override
  // void render(Canvas canvas) {
  //   canvas.drawCircle(Offset(size.x, size.y), size.x / 2, paint);
  // }
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
