# Lights Out

A polished implementation of the classic **Lights Out** puzzle, built with Flutter and Material 3. Tap a cell to toggle it and its orthogonal neighbours; turn every light off to win. Includes an AI auto-solver that plays the optimal solution as an animation.

> Dark, amber-on-black theme. Runs on Android, iOS, and the web.

---

## Screenshots

### Splash screen
<img src="assets/Screenshot%202026-06-30%20at%2011.59.02%E2%80%AFPM.png" alt="Splash screen" width="300" />

### Gameplay
<img src="assets/Screenshot%202026-07-01%20at%2012.00.16%E2%80%AFAM.png" alt="Gameplay board" width="320" />

### Grid size selector (3x3, 4x4, 5x5, 6x6)
<img src="assets/Screenshot%202026-07-01%20at%2012.00.26%E2%80%AFAM.png" alt="Grid size dropdown" width="320" />

### AI auto-solve in action
<img src="assets/Screenshot%202026-07-01%20at%2012.00.34%E2%80%AFAM.png" alt="AI solving the board" width="320" />

### Victory
<img src="assets/Screenshot%202026-07-01%20at%2012.00.37%E2%80%AFAM.png" alt="Win dialog" width="320" />

---

## Features

- Square grids in four sizes: **3x3, 4x4, 5x5, 6x6**
- Random, **always-solvable** puzzle generation
- **Let AI Solve**: computes the solution and plays it one tap at a time, with the active cell highlighted
- Move counter and live status (Your move / AI playing / Solved)
- Restart the current puzzle or deal a new one
- Animated splash screen and victory dialog
- Smooth tap animations, animated colour transitions, and haptic feedback
- Responsive layout for phones and tablets
- Material 3 dark theme (amber lights on a near-black background)

## Getting started

```bash
flutter pub get
flutter run
```

To run in a browser:

```bash
flutter run -d chrome
```

## Project structure

```
lib/
  main.dart                 App entry point
  app.dart                  MaterialApp, theme, and provider wiring

  models/
    cell.dart               Immutable cell (row, column, isOn)

  game/
    game_logic.dart         Pure rules: toggle, press, isSolved, generate, solve
    game_controller.dart    ChangeNotifier state, auto-solve animation

  screens/
    splash_screen.dart      Animated launch screen
    home_screen.dart        Title, size selector, board, controls, win dialog

  widgets/
    game_board.dart         Responsive square grid
    game_tile.dart          Animated light tile
    control_panel.dart      Status, Restart, New Game, Let AI Solve
```

Business logic is fully separated from the UI. State is managed with [`provider`](https://pub.dev/packages/provider); all puzzle rules live in pure, testable functions in `game_logic.dart`.

## How puzzle generation works

A new puzzle starts from a fully-OFF board, which is the solved state. We then apply a random subset of presses (each press toggles a cell plus its orthogonal neighbours). Because every press is its own inverse, the exact set of presses used to scramble the board is also a valid solution, so the puzzle is **guaranteed solvable by construction**. The rare all-off result is rejected so the player never starts pre-solved.

## How the AI solver works

Lights Out is linear over GF(2), the field where `1 + 1 = 0`. Three facts make it solvable with algebra:

1. Pressing a cell always toggles the same fixed pattern.
2. The order of presses does not matter.
3. Pressing the same cell twice cancels out, so each cell is pressed either once or not at all.

This turns the board into a linear system `A x = b`, where `b` marks which lights are ON and `x` marks which cells to press. The solver runs XOR-based Gaussian elimination over GF(2) to find `x`, then auto-solve plays those presses one by one. Booleans are used throughout (instead of integer bitmasks) so results are identical on native and web.

## Tests

```bash
flutter test
```

Unit tests cover the press rule, bounds handling, solvability of generated puzzles, and verify the solver clears the board across every grid size.
