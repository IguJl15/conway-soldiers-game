import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'game.dart';
import 'settings/table_settings.dart';
import 'view/game/build_phase/build_phase_hud.dart';
import 'view/game/running_phase/running_phase_hud.dart';

void main() {
  MyGame game = MyGame();
  runApp(SoldiersGameWidget(game));
}

class SoldiersGameWidget extends StatelessWidget {
  final MyGame _game;

  const SoldiersGameWidget(this._game, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conway\'s Soldiers',
      theme: ThemeData.from(
        colorScheme: const ColorScheme.light(primary: TableSettings.pieceColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.from(
        colorScheme: const ColorScheme.dark(primary: TableSettings.pieceColor),
        useMaterial3: true,
      ),
      home: GameScreen(_game),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen(this.game, {super.key});

  final MyGame game;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text(
          "Conway's Soldiers Game",
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            game.isInBuildPhase ? game.play() : game.build();
          });
        },
        icon: Icon(game.isInBuildPhase ? Icons.play_arrow_rounded : Icons.replay_outlined),
        label: Text(game.isInBuildPhase ? "Play" : "Reset"),
      ),
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          MyGame.buildingPhaseOverlay: (context, game) => const BuildingPhaseHud(),
          MyGame.runningPhaseOverlay: (context, game) => const RunningPhaseHud()
        },
        initialActiveOverlays: const [
          MyGame.buildingPhaseOverlay,
        ],
      ),
    );
  }
}
