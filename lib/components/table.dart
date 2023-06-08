import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:soldiers_game/components/grid_component.dart';

import '../game.dart';
import '../settings/table_settings.dart';

class Table extends PositionComponent with HasGameRef<MyGame> {
  /// Map of Columns -> Rows -> TablePiece
  Map<int, Map<int, TablePiece>> createdPieces = {};
  Vector2 mousePosition = Vector2.zero();

  late GridComponent gridComponent;

  static const double spaceSize = 40;
  static final Vector2 gridSpaceSize = Vector2.all(50);


  static const int minimumHeight = 6;

  @override
  FutureOr<void> onLoad() {
    size = game.size;

    gridComponent = GridComponent(
      gridSpaceSize: gridSpaceSize,
      hoverPieceSize: Vector2.all(spaceSize),
      onTap: onTap,
    );

    add(gridComponent);
    return super.onLoad();
  }

  void cameraMoved(Vector2 position) {
    gridComponent.position = position;
  }

  void onTap(int xIndex, int yIndex) {
    final existingPiece = createdPieces[xIndex]?[yIndex];

    if (existingPiece != null) {
      _removePiece(xIndex.toInt(), yIndex.toInt());
      return;
    }
      if (yIndex < minimumHeight) return;
    _addPiece(xIndex.toInt(), yIndex.toInt());
  }

  void onMouseMove(PointerHoverInfo info) => gridComponent.onMouseMove(info);

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
