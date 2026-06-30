import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../game/game_controller.dart';
import 'game_tile.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final size = controller.size;
    final board = controller.board;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;

        return Center(
          child: SizedBox.square(
            dimension: side,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: size * size,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: size,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final row = index ~/ size;
                final column = index % size;
                return GameTile(
                  cell: board[row][column],
                  isActive: controller.isActive(row, column),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    controller.onCellTapped(row, column);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
