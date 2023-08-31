import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soldiers_game/settings/table_settings.dart';
import 'package:soldiers_game/view/shared/debug_slider.dart';

class BuildingPhaseHud extends StatefulWidget {
  const BuildingPhaseHud({super.key});

  @override
  State<BuildingPhaseHud> createState() => _BuildingPhaseHudState();
}

class _BuildingPhaseHudState extends State<BuildingPhaseHud> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        children: [
          const Text("BUILDING"),
          if (kDebugMode) ...[
            DebugSlider(
              label: "Piece size",
              value: TableSettings.pieceSize.x,
              min: 10,
              max: 100,
              onChanged: (value) {
                setState(() {
                  TableSettings.pieceSize = Vector2.all(value);
                });
              },
            ),
            DebugSlider(
              label: "Grid size",
              value: TableSettings.gridPieceSize.x,
              min: 10,
              max: 100,
              onChanged: (value) {
                setState(() {
                  TableSettings.gridPieceSize = Vector2.all(value);
                });
              },
            ),
          ]
        ],
      ),
    );
  }
}
