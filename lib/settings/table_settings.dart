import 'dart:ui';

import 'package:flame/game.dart';

abstract class TableSettings {
// Colors
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color gridLinesColor = Color(0xFF1B3130);
  static const Color unreachbleAreaColor = Color.fromARGB(255, 163, 192, 190);
  static const Color hoverColor = Color(0x40E27125);
  static const Color pieceColor = Color(0xFFE27125);
  static const Color possibleMovementColor = Color(0xFF556D6C);

// Sizes
  /// The size of the table piece put by the player
  static Vector2 pieceSize = Vector2.all(40);

  /// The size of the grid square, the game board
  static Vector2 gridPieceSize = Vector2.all(50);

  /// Padding from the grid line to the piece based on grid and piece size.
  /// The resulting offset may be negative if the grid piece size is greater
  /// than the piece size.
  ///
  /// This offset must be used to render the piece on center of the grid piece
  /// by adding the offset to the position
  ///
  /// eg.: if the grid piece size is 20 and the piece size is 10, the padding
  /// will be `Offset(5.0, 5.0)`, meaning that would be a space of `5.0` from
  /// grid and piece.
  static Vector2 get gridContentPadding => Vector2(
        (gridPieceSize.x - pieceSize.x) / 2,
        (gridPieceSize.y - pieceSize.y) / 2,
      );

// Settings
  /// Should set how far the camera can go up.
  ///
  /// eg.: if it is `6` (default value) the camera can show up to 6 lines of
  /// the board after the playable area.
  static const int maximumHeight = 6;
}
