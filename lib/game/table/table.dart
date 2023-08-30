import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:soldiers_game/settings/table_settings.dart';

sealed class TablePhase {
  TableData get table;

  final Function(TablePiece) onPieceAdded;
  final Function(TablePiece) onPieceRemoved;

  TablePhase(this.onPieceAdded, this.onPieceRemoved);

  void tapPieceAt({required int x, required int y});
}

class RunningPhase implements TablePhase {
  final TableData _table;
  @override
  TableData get table => _table;

  @override
  final Function(TablePiece) onPieceAdded;
  @override
  final Function(TablePiece) onPieceRemoved;

  RunningPhase(
    this._table, {
    required this.onPieceAdded,
    required this.onPieceRemoved,
  });

  List<Direction> _possibleMovementsDirections = [];
  List<Point<int>> get possibleMovements => //
      _possibleMovementsDirections
          .map((e) => Point(_pieceBeingHeld!.x + e.xOffset * 2, _pieceBeingHeld!.y + e.yOffset * 2)) //
          .toList();

  TablePiece? _pieceBeingHeld;
  @protected
  set pieceBeingHeld(TablePiece? piece) {
    _pieceBeingHeld = piece;

    _possibleMovementsDirections = _pieceBeingHeld == null
        ? []
        : Direction.values.where((direction) {
            final x = _pieceBeingHeld!.x;
            final y = _pieceBeingHeld!.y;

            return table.getSorroundingFrom(x, y, direction, distance: 1) != null &&
                table.getSorroundingFrom(x, y, direction, distance: 2) == null;
          }).toList();
  }

  bool get holdingPiece => _pieceBeingHeld != null;

  @override
  void tapPieceAt({required int x, required int y}) {
    if (holdingPiece) {
      _tapPieceWhileHolding(x, y);
    } else {
      _tapPiece(x, y);
    }
  }

  _tapPiece(int x, int y) {
    final piece = table._getPieceAt(x, y);

    if (piece != null) {
      pieceBeingHeld = piece;

      _removePiece(x, y);
    }
  }

  _tapPieceWhileHolding(int x, int y) {
    if (x == _pieceBeingHeld!.x && y == _pieceBeingHeld!.y) {
      _addPiece(x, y);
      pieceBeingHeld = null;
      return;
    }

    if (possibleMovements.contains(Point(x, y))) {
      final movementIndex = possibleMovements.indexWhere((e) => e == Point(x, y));
      final movementDirection = _possibleMovementsDirections[movementIndex];

      final pieceToRemove = table.getSorroundingFrom(
        _pieceBeingHeld!.x,
        _pieceBeingHeld!.y,
        movementDirection,
        distance: 1,
      );

      _removePiece(pieceToRemove!.x, pieceToRemove.y);
      _addPiece(x, y);
      pieceBeingHeld = null;
    }
  }

  _addPiece(int x, int y) => onPieceAdded(table.addPieceAt(x, y));
  _removePiece(int x, int y) {
    final removed = table.removePieceAt(x, y);
    if (removed != null) onPieceRemoved(removed);
  }
}

class BuildPhase implements TablePhase {
  final TableData _table;
  @override
  TableData get table => _table;

  @override
  final Function(TablePiece) onPieceAdded;
  @override
  final Function(TablePiece) onPieceRemoved;

  const BuildPhase(
    this._table, {
    required this.onPieceAdded,
    required this.onPieceRemoved,
  });

  @override
  tapPieceAt({required int x, required int y}) {
    if (!table.hasPieceAt(x, y) && y >= TableSettings.maximumHeight) {
      _addPiece(x, y);
    } else {
      _removePiece(x, y);
    }
  }

  _addPiece(int x, int y) => onPieceAdded(table.addPieceAt(x, y));
  _removePiece(int x, int y) {
    final removed = table.removePieceAt(x, y);
    if (removed != null) onPieceRemoved(removed);
  }
}

class TableData {
  TableData(this._pieces);

  /// Map of Columns -> Rows -> TablePiece
  final Map<int, Map<int, TablePiece>> _pieces;
  Iterable<TablePiece> get pieces sync* {
    for (var columnItem in _pieces.values) {
      yield* columnItem.values;
    }
  }

  TablePiece? _getPieceAt(int x, int y) => _pieces[x]?[y];

  bool hasPieceAt(int x, int y) => _pieces.containsKey(x) && _pieces[x]!.containsKey(y);
  TablePiece addPieceAt(int x, int y) {
    _pieces.putIfAbsent(x, () => {});

    late TablePiece piece;
    _pieces[x]?[y] = piece = TablePiece(x, y);

    return piece;
  }

  TablePiece? removePieceAt(int x, int y) {
    if (_pieces.containsKey(x) && _pieces[x]!.containsKey(y)) {
      return _pieces[x]!.remove(y);
    }

    return null;
  }

  TablePiece? getSorroundingFrom(int x, int y, Direction direction, {int distance = 1}) {
    return switch (direction) {
      Direction.right => _getPieceAt(x + distance, y),
      Direction.left => _getPieceAt(x - distance, y),
      Direction.up => _getPieceAt(x, y - distance),
      Direction.down => _getPieceAt(x, y + distance),
    };
  }

  TableData copy() {
    return TableData(
      LinkedHashMap.fromEntries(
        _pieces.entries.map(
          (e) => MapEntry(
            e.key,
            LinkedHashMap.fromEntries(
              e.value.entries.map((e) => MapEntry(e.key, e.value)),
            ),
          ),
        ),
      ),
    );
  }
}

enum Direction {
  right(1, 0),
  left(-1, 0),
  up(0, -1),
  down(0, 1);

  const Direction(this.xOffset, this.yOffset);

  final int xOffset, yOffset;

  Direction opposite() {
    switch (this) {
      case up:
        return down;
      case down:
        return up;
      case left:
        return right;
      case right:
        return left;
    }
  }
}

class TablePiece {
  final int x;
  final int y;

  const TablePiece(this.x, this.y);
}
