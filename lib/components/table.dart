import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../game.dart';
import '../settings/table_settings.dart';
import 'grid_component.dart';

class Table extends PositionComponent with HasGameRef<MyGame> {
  /// Map of Columns -> Rows -> TablePiece
  Map<int, Map<int, TablePiece>> createdPieces = {};

  late GridComponent gridComponent;

  static final Vector2 spaceSize = Vector2.all(40);
  static final Vector2 gridSpaceSize = Vector2.all(50);

  static bool holdingPiece = false;

  static double get xPaddingFromGridToPieceSpace => (gridSpaceSize.x - spaceSize.x) / 2;
  static double get yPaddingFromGridToPieceSpace => (gridSpaceSize.y - spaceSize.y) / 2;

  static const int minimumHeight = 6;

  @override
  FutureOr<void> onLoad() {
    size = game.size;

    gridComponent = GridComponent(
      gridSpaceSize: gridSpaceSize,
      hoverPieceSize: spaceSize,
      onTap: onTap,
    );

    add(gridComponent);
  }

  void cameraMoved(Vector2 position) {
    gridComponent.position = position;
  }

  void onTap(int xIndex, int yIndex) {
    final existingPiece = createdPieces[xIndex]?[yIndex];

    if (existingPiece != null) {
      holdingPiece = true;
      _removePiece(xIndex.toInt(), yIndex.toInt());
    } else {
      if (holdingPiece) {
        _addPiece(xIndex.toInt(), yIndex.toInt());
        holdingPiece = false;
        return;
      }
      if (yIndex < minimumHeight) return;
      _addPiece(xIndex.toInt(), yIndex.toInt());
    }
  }

  void onMouseMove(PointerHoverInfo info) => gridComponent.onMouseMove(info);

  void _addPiece(int x, int y) {
    final newPiece = TablePiece(
      columnIndex: x,
      rowIndex: y,
      size: spaceSize,
    );

    add(newPiece);

    if (createdPieces.containsKey(x)) {
      if (createdPieces[x]!.containsKey(y)) {
        return;
      } else {
        createdPieces[x]!.addAll({y: newPiece});
      }
    } else {
      createdPieces.addAll({
        x: {y: newPiece}
      });
    }
  }

  void _removePiece(int x, int y) {
    if (createdPieces[x]?[y] == null) return;

    remove(createdPieces[x]![y]!);
    createdPieces[x]!.remove(y);
  }

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    _renderHeldPiece(canvas);
  }

  void _renderHeldPiece(Canvas canvas) {
    if (holdingPiece) {
      canvas.drawRect(
          Rect.fromCenter(center: gridComponent.mousePosition.toOffset(), width: spaceSize.x, height: spaceSize.y),
          Paint()..color = TableSettings.pieceColor);
    }
  }
}

class TablePiece extends RectangleComponent {
  final int rowIndex;
  final int columnIndex;

  TablePiece({
    required this.columnIndex,
    required this.rowIndex,
    required Vector2 size,
  }) : super(
          position: Vector2(
            columnIndex * Table.gridSpaceSize.x + Table.xPaddingFromGridToPieceSpace,
            rowIndex * Table.gridSpaceSize.y + Table.yPaddingFromGridToPieceSpace,
          ),
          size: size,
          anchor: Anchor.topLeft,
        );

  @override
  void update(double dt) {
    if (size.x != Table.spaceSize.x) size = Table.spaceSize;
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
