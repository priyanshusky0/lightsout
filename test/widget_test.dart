import 'package:flutter_test/flutter_test.dart';

import 'package:lights_out_game/game/game_logic.dart';

void main() {
  group('GameLogic', () {
    test('emptyBoard is all OFF and solved', () {
      final board = GameLogic.emptyBoard(5);
      expect(board.length, 5);
      expect(board.every((row) => row.every((cell) => !cell.isOn)), isTrue);
      expect(GameLogic.isSolved(board), isTrue);
    });

    test('press toggles self and orthogonal neighbours only', () {
      final board = GameLogic.press(GameLogic.emptyBoard(3), 1, 1);
      final onCount =
          board.expand((row) => row).where((cell) => cell.isOn).length;
      expect(onCount, 5);
      expect(board[1][1].isOn, isTrue);
      expect(board[0][1].isOn, isTrue);
      expect(board[2][1].isOn, isTrue);
      expect(board[1][0].isOn, isTrue);
      expect(board[1][2].isOn, isTrue);
      expect(board[0][0].isOn, isFalse);
    });

    test('press ignores out-of-bounds neighbours at a corner', () {
      final board = GameLogic.press(GameLogic.emptyBoard(3), 0, 0);
      final onCount =
          board.expand((row) => row).where((cell) => cell.isOn).length;
      expect(onCount, 3);
    });

    test('press is its own inverse', () {
      var board = GameLogic.emptyBoard(4);
      board = GameLogic.press(board, 2, 1);
      board = GameLogic.press(board, 2, 1);
      expect(GameLogic.isSolved(board), isTrue);
    });

    test('generatePuzzle yields a non-trivial, solvable board', () {
      for (final size in const [3, 4, 5, 6]) {
        final board = GameLogic.generatePuzzle(size);
        expect(board.length, size);
        expect(GameLogic.isSolved(board), isFalse);
      }
    });

    test('solve returns no presses for an already-solved board', () {
      expect(GameLogic.solve(GameLogic.emptyBoard(4)), isEmpty);
    });

    test('applying solve() presses turns every light off', () {
      for (final size in const [3, 4, 5, 6]) {
        for (var attempt = 0; attempt < 20; attempt++) {
          var board = GameLogic.generatePuzzle(size);
          for (final cell in GameLogic.solve(board)) {
            board = GameLogic.press(board, cell.row, cell.column);
          }
          expect(GameLogic.isSolved(board), isTrue,
              reason: 'size $size failed on attempt $attempt');
        }
      }
    });
  });
}
