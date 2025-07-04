class GameState {
  final List<List<int>> board;
  final int score;
  final bool gameOver;
  final bool gameWon;
  final Set<int> justMergedSet;
  final Map<int, int> tileIds;
  final int nextTileId;

  GameState({
    required this.board,
    required this.score,
    required this.gameOver,
    required this.gameWon,
    required this.justMergedSet,
    required this.tileIds,
    required this.nextTileId,
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
    required Set<int> justMergedSet,
    required Map<int, int> tileIds,
    required int nextTileId,
  }) {
    return GameState(
      board: board.map((row) => List<int>.from(row)).toList(),
      score: score,
      gameOver: gameOver,
      gameWon: gameWon,
      justMergedSet: Set<int>.from(justMergedSet),
      tileIds: Map<int, int>.from(tileIds),
      nextTileId: nextTileId,
    );
  }
} 