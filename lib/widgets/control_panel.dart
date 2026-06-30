import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_controller.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final isAutoSolving = controller.isAutoSolving;
    final isSolved = controller.isSolved;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _StatusBar(
          moves: controller.moves,
          isAutoSolving: isAutoSolving,
          isSolved: isSolved,
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: controller.reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Restart'),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: controller.newGame,
              icon: const Icon(Icons.casino_outlined),
              label: const Text('New Game'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FilledButton.tonalIcon(
              onPressed:
                  (isSolved || isAutoSolving) ? null : controller.autoSolve,
              icon: isAutoSolving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(isAutoSolving ? 'AI Solving...' : 'Let AI Solve'),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'How the AI solves it',
              onPressed: () => _showLogicDialog(context),
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogicDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final textTheme = Theme.of(dialogContext).textTheme;
        return AlertDialog(
          icon: const Icon(Icons.functions, color: Colors.amber, size: 36),
          title: const Text('How the AI solves it'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Lights Out is a linear puzzle over GF(2), which is just '
              'arithmetic where 1 + 1 = 0.\n\n'
              'Three facts make it solvable with algebra:\n'
              '1. Pressing a cell always toggles the same fixed pattern '
              '(itself plus its neighbours).\n'
              '2. The order of presses does not matter.\n'
              '3. Pressing the same cell twice cancels out, so each cell is '
              'either pressed once or not at all.\n\n'
              'That turns the board into a system of equations A x = b, where '
              'b marks which lights are ON and x marks which cells to press. '
              'Solving it with XOR-based Gaussian elimination gives the exact '
              'set of presses that switches every light off. Auto-solve simply '
              'plays those presses one by one.',
              style: textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.moves,
    required this.isAutoSolving,
    required this.isSolved,
  });

  final int moves;
  final bool isAutoSolving;
  final bool isSolved;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final (IconData icon, String label) = isSolved
        ? (Icons.check_circle, 'Solved')
        : isAutoSolving
            ? (Icons.auto_awesome, 'AI playing')
            : (Icons.touch_app_outlined, 'Your move');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 20, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 1,
            height: 18,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          const SizedBox(width: 14),
          Text(
            'Moves: $moves',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
