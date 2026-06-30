import 'package:flutter/material.dart';

import '../models/cell.dart';

class GameTile extends StatefulWidget {
  const GameTile({
    super.key,
    required this.cell,
    required this.onTap,
    this.isActive = false,
  });

  final Cell cell;
  final VoidCallback onTap;
  final bool isActive;

  static const Duration animationDuration = Duration(milliseconds: 200);

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _handleTapCancel() => setState(() => _pressed = false);
  void _handleTapUp(TapUpDetails _) => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOn = widget.cell.isOn;
    final isActive = widget.isActive;

    final tileColor = isOn ? Colors.amber : const Color(0xFF1C1C1E);
    final glowColor = Colors.amber.withValues(alpha: 0.55);

    final scale = _pressed
        ? 0.9
        : isActive
            ? 1.08
            : 1.0;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: GameTile.animationDuration,
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: GameTile.animationDuration,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? Colors.amberAccent
                  : isOn
                      ? Colors.amber.shade200
                      : Colors.white.withValues(alpha: 0.06),
              width: isActive ? 2.5 : 1.5,
            ),
            boxShadow: isOn || isActive
                ? <BoxShadow>[
                    BoxShadow(
                      color: glowColor,
                      blurRadius: isActive ? 22 : 16,
                      spreadRadius: isActive ? 2 : 1,
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                isOn ? Icons.lightbulb : Icons.lightbulb_outline,
                color: isOn
                    ? Colors.black.withValues(alpha: 0.65)
                    : colorScheme.onSurface.withValues(alpha: 0.25),
                size: 22,
              ),
              AnimatedOpacity(
                opacity: isActive ? 1.0 : 0.0,
                duration: GameTile.animationDuration,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isOn ? Colors.black87 : Colors.amberAccent,
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
