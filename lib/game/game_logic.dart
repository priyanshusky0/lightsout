import 'dart:math';

import '../models/cell.dart';

class GameLogic {
  static final Random _random = Random();

  static List<List<Cell>> emptyBoard(int size) {
    return List.generate(
      size,
      (row) => List.generate(
        size,
        (column) => Cell(row: row, column: column, isOn: false),
        growable: false,
      ),
      growable: false,
    );
  }

  static List<List<Cell>> _copy(List<List<Cell>> board) {
    return List.generate(
      board.length,
      (row) => List<Cell>.from(board[row]),
      growable: false,
    );
  }

  static bool _inBounds(int row, int column, int size) {
    return row >= 0 && row < size && column >= 0 && column < size;
  }

  static List<List<Cell>> toggleCell(
    List<List<Cell>> board,
    int row,
    int column,
  ) {
    final next = _copy(board);
    next[row][column] = next[row][column].toggled();
    return next;
  }

  static List<List<Cell>> toggleNeighbors(
    List<List<Cell>> board,
    int row,
    int column,
  ) {
    final size = board.length;
    final next = _copy(board);

    const offsets = <List<int>>[
      [-1, 0],
      [1, 0],
      [0, -1],
      [0, 1],
    ];

    for (final offset in offsets) {
      final neighbourRow = row + offset[0];
      final neighbourColumn = column + offset[1];
      if (_inBounds(neighbourRow, neighbourColumn, size)) {
        next[neighbourRow][neighbourColumn] =
            next[neighbourRow][neighbourColumn].toggled();
      }
    }
    return next;
  }

  // A press toggles the cell itself plus its orthogonal neighbours.
  static List<List<Cell>> press(
    List<List<Cell>> board,
    int row,
    int column,
  ) {
    final afterSelf = toggleCell(board, row, column);
    return toggleNeighbors(afterSelf, row, column);
  }

  static bool isSolved(List<List<Cell>> board) {
    for (final row in board) {
      for (final cell in row) {
        if (cell.isOn) return false;
      }
    }
    return true;
  }

  // Solves the board using Gaussian elimination over GF(2).
  // Returns the cells that must be pressed to turn every light off.
  static List<Cell> solve(List<List<Cell>> board) {
    final n = board.length;
    final unknowns = n * n;

    final matrix = List.generate(
      unknowns,
      (_) => List<bool>.filled(unknowns + 1, false),
      growable: false,
    );

    // Column j represents pressing cell (pr, pc); the rows it sets are the
    // cells that press toggles.
    for (var pr = 0; pr < n; pr++) {
      for (var pc = 0; pc < n; pc++) {
        final column = pr * n + pc;
        const offsets = <List<int>>[
          [0, 0],
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
        ];
        for (final offset in offsets) {
          final r = pr + offset[0];
          final c = pc + offset[1];
          if (_inBounds(r, c, n)) {
            matrix[r * n + c][column] = true;
          }
        }
      }
    }

    // Right-hand side: the current ON state of each cell.
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        matrix[r * n + c][unknowns] = board[r][c].isOn;
      }
    }

    final pivotColumnForRow = List<int>.filled(unknowns, -1);
    var pivotRow = 0;
    for (var col = 0; col < unknowns && pivotRow < unknowns; col++) {
      var selected = -1;
      for (var i = pivotRow; i < unknowns; i++) {
        if (matrix[i][col]) {
          selected = i;
          break;
        }
      }
      if (selected == -1) continue;

      final swap = matrix[selected];
      matrix[selected] = matrix[pivotRow];
      matrix[pivotRow] = swap;

      for (var i = 0; i < unknowns; i++) {
        if (i != pivotRow && matrix[i][col]) {
          for (var k = col; k <= unknowns; k++) {
            matrix[i][k] ^= matrix[pivotRow][k];
          }
        }
      }
      pivotColumnForRow[pivotRow] = col;
      pivotRow++;
    }

    final pressed = List<bool>.filled(unknowns, false);
    for (var i = 0; i < unknowns; i++) {
      final col = pivotColumnForRow[i];
      if (col != -1) pressed[col] = matrix[i][unknowns];
    }

    final solution = <Cell>[];
    for (var j = 0; j < unknowns; j++) {
      if (pressed[j]) solution.add(board[j ~/ n][j % n]);
    }
    return solution;
  }

  // Builds a solvable puzzle by pressing a random set of cells on a solved
  // board. Since each press is its own inverse, the result is always solvable.
  static List<List<Cell>> generatePuzzle(int size) {
    final totalCells = size * size;

    while (true) {
      var board = emptyBoard(size);

      for (var index = 0; index < totalCells; index++) {
        if (_random.nextBool()) {
          final row = index ~/ size;
          final column = index % size;
          board = press(board, row, column);
        }
      }

      if (!isSolved(board)) return board;
    }
  }
}
