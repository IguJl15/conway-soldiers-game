import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../game.dart';
import '../game/table/table.dart';
import '../settings/table_settings.dart';
import 'grid_component.dart';

class TableComponent extends PositionComponent with HasGameRef<MyGame> {
  late BuildPhase buildTable;
  RunningPhase? playTable;

  late TablePhase currentPhaseController;

  late GridComponent gridComponent;

  void runPlayPhase() {
    currentPhaseController = RunningPhase(
      buildTable.table.copy(),
      onPieceAdded: (e) => add(TablePieceComponent.fromPiece(e)),
      onPieceRemoved: (e) => remove(children.firstWhere((element) => element == TablePieceComponent.fromPiece(e))),
    );
  }

  void runBuildingPhase() {
    final componentsToRemove = <Component>[];
    for (var component in children) {
      if (component is TablePieceComponent) componentsToRemove.add(component);
    }
    removeAll(componentsToRemove);

    currentPhaseController = buildTable;
    addAll(currentPhaseController.table.pieces.map((e) => TablePieceComponent.fromPiece(e)));
  }

  @override
  FutureOr<void> onLoad() {
    size = game.size;
    buildTable = BuildPhase(
      TableData({}),
      onPieceAdded: (e) => add(TablePieceComponent.fromPiece(e)),
      onPieceRemoved: (e) => remove(children.firstWhere((element) => element == TablePieceComponent.fromPiece(e))),
    );
    currentPhaseController = buildTable;

    gridComponent = GridComponent(
      hoverPieceSize: TableSettings.pieceSize,
      onTap: onTap,
    );

    add(gridComponent);
  }

  void cameraMoved(Vector2 position) => gridComponent.position = position;
  void onTap(int xIndex, int yIndex) => currentPhaseController.tapPieceAt(x: xIndex, y: yIndex);
  void onMouseMove(PointerHoverInfo info) => gridComponent.onMouseMove(info);

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    _renderHeldPiece(canvas);
  }

  void _renderHeldPiece(Canvas canvas) {
    if (currentPhaseController
        case RunningPhase(holdingPiece: final holdingPiece, possibleMovements: final movementLocations)) {
      if (holdingPiece) {
        for (var local in movementLocations) {
          canvas.drawRect(
              Rect.fromLTWH(
                local.x * TableSettings.gridPieceSize.x + TableSettings.gridContentPadding.x,
                local.y * TableSettings.gridPieceSize.y + TableSettings.gridContentPadding.y,
                TableSettings.pieceSize.x,
                TableSettings.pieceSize.y,
              ),
              Paint()..color = TableSettings.possibleMovementColor);
        }
        canvas.drawRect(
            Rect.fromCenter(
                center: gridComponent.mousePosition.toOffset(),
                width: TableSettings.pieceSize.x,
                height: TableSettings.pieceSize.y),
            Paint()..color = TableSettings.pieceColor);
      }
    }
  }
}

class TablePieceComponent extends RectangleComponent {
  final int rowIndex;
  final int columnIndex;

  TablePieceComponent({
    required this.columnIndex,
    required this.rowIndex,
    required Vector2 size,
  }) : super(
          position: Vector2(
            columnIndex * TableSettings.gridPieceSize.x + TableSettings.gridContentPadding.x,
            rowIndex * TableSettings.gridPieceSize.y + TableSettings.gridContentPadding.y,
          ),
          size: size,
          anchor: Anchor.topLeft,
        );

  factory TablePieceComponent.fromPiece(TablePiece piece) =>
      TablePieceComponent(columnIndex: piece.x, rowIndex: piece.y, size: TableSettings.pieceSize);

  @override
  void update(double dt) {
    final newPosition = Vector2(
      columnIndex * TableSettings.gridPieceSize.x + TableSettings.gridContentPadding.x,
      rowIndex * TableSettings.gridPieceSize.y + TableSettings.gridContentPadding.y,
    );
    position = position == newPosition ? position : newPosition;
    size = size.x != TableSettings.pieceSize.x ? TableSettings.pieceSize : size;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (paint.color != TableSettings.pieceColor) {
      paint.color = TableSettings.pieceColor;
    }
    super.render(canvas);
  }

  @override
  bool operator ==(covariant TablePieceComponent other) {
    if (identical(this, other)) return true;

    return other.rowIndex == rowIndex && other.columnIndex == columnIndex;
  }

  @override
  int get hashCode => rowIndex.hashCode ^ columnIndex.hashCode;
}
