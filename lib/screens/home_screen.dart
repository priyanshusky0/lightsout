import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game/game_controller.dart';
import '../widgets/control_panel.dart';
import '../widgets/game_board.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameController? _controller;
  bool _wasSolved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<GameController>();
    if (controller != _controller) {
      _controller?.removeListener(_onGameChanged);
      _controller = controller..addListener(_onGameChanged);
    }
  }

  void _onGameChanged() {
    final controller = _controller;
    if (controller == null) return;

    if (controller.isSolved && !_wasSolved) {
      _wasSolved = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showVictoryDialog(controller.moves);
      });
    } else if (!controller.isSolved) {
      _wasSolved = false;
    }
  }

  Future<void> _showVictoryDialog(int moves) async {
    final controller = _controller;
    if (controller == null) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
          title: const Text('You Win!'),
          content: Text('Solved in $moves move${moves == 1 ? '' : 's'}.'),
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          actions: <Widget>[
            FilledButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                controller.newGame();
              },
              icon: const Icon(Icons.casino_outlined),
              label: const Text('New Game'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_onGameChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth > 640 ? 640.0 : constraints.maxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      _Header(),
                      SizedBox(height: 24),
                      Expanded(child: GameBoard()),
                      SizedBox(height: 24),
                      ControlPanel(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(Icons.grid_view_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 10),
            Text(
              'Lights Out',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        _GridSizeDropdown(
          value: controller.size,
          onChanged: controller.changeSize,
        ),
      ],
    );
  }
}

class _GridSizeDropdown extends StatelessWidget {
  const _GridSizeDropdown({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          borderRadius: BorderRadius.circular(14),
          items: kSupportedGridSizes
              .map(
                (size) => DropdownMenuItem<int>(
                  value: size,
                  child: Text('$size x $size'),
                ),
              )
              .toList(growable: false),
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
      ),
    );
  }
}
