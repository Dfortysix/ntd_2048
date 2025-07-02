class GameState {
  final List<List<int>> board;
  final int score;
  final bool gameOver;
  final bool gameWon;

  GameState({
    required this.board,
    required this.score,
    required this.gameOver,
    required this.gameWon,
  });

  // Tạo bản sao sâu của board
  List<List<int>> get boardCopy {
    return board.map((row) => List<int>.from(row)).toList();
  }

  // Tạo GameState từ trạng thái hiện tại
  factory GameState.fromCurrent({
    required List<List<int>> board,
    required int score,
    required bool gameOver,
    required bool gameWon,
  }) {
    return GameState(
      board: board.map((row) => List<int>.from(row)).toList(),
      score: score,
      gameOver: gameOver,
      gameWon: gameWon,
    );
  }
} 