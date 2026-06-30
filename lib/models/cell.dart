import 'package:flutter/foundation.dart';

@immutable
class Cell {
  const Cell({
    required this.row,
    required this.column,
    required this.isOn,
  });

  final int row;
  final int column;
  final bool isOn;

  Cell copyWith({bool? isOn}) {
    return Cell(
      row: row,
      column: column,
      isOn: isOn ?? this.isOn,
    );
  }

  Cell toggled() => copyWith(isOn: !isOn);

  @override
  bool operator ==(Object other) {
    return other is Cell &&
        other.row == row &&
        other.column == column &&
        other.isOn == isOn;
  }

  @override
  int get hashCode => Object.hash(row, column, isOn);

  @override
  String toString() => 'Cell($row, $column, ${isOn ? 'ON' : 'OFF'})';
}
