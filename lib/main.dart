import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:soldiers_game/game.dart';
import 'package:soldiers_game/settings/table_settings.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: TableSettings.pieceColor),
      ),
      home: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: const Text(
            "Conway's Soldiers Game",
            // style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _game.play,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text("Play"),
        ),
        body: GameWidget(
          game: _game,
          overlayBuilderMap: {
            MyGame.buildingPhaseOverlay: (context, game) {
              return const BuildingPhaseHud();
            },
            MyGame.runningPhaseOverlay: (context, game) {
              return const RunningPhaseHud();
            }
          },
          initialActiveOverlays: const [
            MyGame.buildingPhaseOverlay,
          ],
        ),
      ),
    );
  }
}

class BuildingPhaseHud extends StatelessWidget {
  const BuildingPhaseHud({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text("BUILDING"),
      ],
    );
  }
}

class RunningPhaseHud extends StatelessWidget {
  const RunningPhaseHud({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text("RUNNING"),
      ],
    );
  }
}
