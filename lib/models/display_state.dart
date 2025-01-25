class PlayerDisplay {
  final int playerId;
  final int stack;
  final int currentBet;
  final bool isFolded;
  final int seatPosition;
  // Constructor, etc.
}

class DisplayState {
  final List<PlayerDisplay> players;
  final List<int> boardCards; // Using int since cards are 8-bit integers in C++
  final int potSize;
  final int currentBet;
  final int button;
  final int activePlayerPosition;
  final bool isGameActive;
  // Constructor, etc.
}
