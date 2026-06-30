import 'package:flutter/foundation.dart';

import '../models/cell.dart';
import 'game_logic.dart';

const List<int> kSupportedGridSizes = <int>[3, 4, 5, 6];

class GameController extends ChangeNotifier {
  GameController({int initialSize = 5}) : _size = initialSize {
    _startPuzzle();
  }

  static const Duration autoSolveStep = Duration(milliseconds: 420);

  int _size;
  late List<List<Cell>> _board;
  late List<List<Cell>> _initialBoard;
  int _moves = 0;
  bool _isSolved = false;
  bool _isAutoSolving = false;
  int _activeIndex = -1;

  int get size => _size;
  List<List<Cell>> get board => _board;
  int get moves => _moves;
  bool get isSolved => _isSolved;
  bool get isAutoSolving => _isAutoSolving;

  bool isActive(int row, int column) => _activeIndex == row * _size + column;

  void _startPuzzle() {
    _board = GameLogic.generatePuzzle(_size);
    _initialBoard =
        _board.map((row) => List<Cell>.from(row)).toList(growable: false);
    _moves = 0;
    _isSolved = false;
    _activeIndex = -1;
  }

  void onCellTapped(int row, int column) {
    if (_isSolved || _isAutoSolving) return;

    _board = GameLogic.press(_board, row, column);
    _moves++;
    _isSolved = GameLogic.isSolved(_board);
    notifyListeners();
  }

  // Plays the computed solution one press at a time, highlighting each cell.
  Future<void> autoSolve() async {
    if (_isAutoSolving || _isSolved) return;

    _isAutoSolving = true;
    notifyListeners();

    final solution = GameLogic.solve(_board);
    for (final cell in solution) {
      _activeIndex = cell.row * _size + cell.column;
      notifyListeners();
      await Future<void>.delayed(autoSolveStep);

      if (!_isAutoSolving) return;

      _board = GameLogic.press(_board, cell.row, cell.column);
      _moves++;
      _isSolved = GameLogic.isSolved(_board);
      notifyListeners();
    }

    _activeIndex = -1;
    _isAutoSolving = false;
    notifyListeners();
  }

  void _cancelAutoSolve() {
    _isAutoSolving = false;
    _activeIndex = -1;
  }

  void reset() {
    _cancelAutoSolve();
    _board = _initialBoard
        .map((row) => List<Cell>.from(row))
        .toList(growable: false);
    _moves = 0;
    _isSolved = false;
    notifyListeners();
  }

  void newGame() {
    _cancelAutoSolve();
    _startPuzzle();
    notifyListeners();
  }

  void changeSize(int newSize) {
    if (newSize == _size || !kSupportedGridSizes.contains(newSize)) return;
    _cancelAutoSolve();
    _size = newSize;
    _startPuzzle();
    notifyListeners();
  }
}
