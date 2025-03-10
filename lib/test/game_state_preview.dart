import 'package:flutter/material.dart';
import '../../models/display_state.dart';
import '../../models/player_display.dart';
import '../UI/widgets/poker_table.dart';

class GameStatePreview extends StatelessWidget {
  final int localPlayerId;
  final GameStage stage;

  const GameStatePreview({
    super.key,
    this.localPlayerId = 1,
    this.stage = GameStage.turn,
  });

  @override
  Widget build(BuildContext context) {
    String stageText;
    DisplayState state;

    switch (stage) {
      case GameStage.preflop:
        stageText = 'Preflop';
        state = _createDummyPreflopState();
        break;
      case GameStage.flop:
        stageText = 'Flop';
        state = _createDummyFlopState();
        break;
      case GameStage.turn:
        stageText = 'Turn';
        state = _createDummyTurnState();
        break;
      case GameStage.river:
        stageText = 'River';
        state = _createDummyRiverState();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Game State Preview - $stageText'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        color: Colors.black,
        child: PokerTable(
          gameState: state,
          localPlayerId: localPlayerId,
        ),
      ),
    );
  }

  // Create a dummy game state for preflop
  DisplayState _createDummyPreflopState() {
    // Player 1 - our player, has a decent hand
    final player1 = PlayerDisplay(
      playerId: 1,
      stack: 990,
      currentBet: 10,
      isFolded: false,
      seatPosition: 0,
      holeCards: [0xE3, 0xE4], // Ace of hearts, Ace of spades
    );

    // Player 2 - the villain, to our left
    final player2 = PlayerDisplay(
      playerId: 2,
      stack: 980,
      currentBet: 20,
      isFolded: false,
      seatPosition: 3,
      holeCards: [], // We don't know their cards
    );

    // Player 3 - the fish, to our right
    final player3 = PlayerDisplay(
      playerId: 3,
      stack: 1000,
      currentBet: 0,
      isFolded: false,
      seatPosition: 7,
      holeCards: [], // We don't know their cards
    );

    // Create the game state - preflop, no community cards
    return DisplayState(
      players: [player1, player2, player3],
      boardCards: [], // No community cards yet
      potSize: 30, // Just the blinds
      currentBet: 20, // Big blind is 20
      button: 7, // Dealer button at position 7 (player 3)
      activePlayerPosition: 0, // Player 1's turn to act
      isGameActive: true,
    );
  }

  // Create a dummy game state for flop
  DisplayState _createDummyFlopState() {
    // Player 1 - our player
    final player1 = PlayerDisplay(
      playerId: 1,
      stack: 950,
      currentBet: 50,
      isFolded: false,
      seatPosition: 0,
      holeCards: [0xE3, 0xE4], // Ace of hearts, Ace of spades
    );

    // Player 2 - the villain
    final player2 = PlayerDisplay(
      playerId: 2,
      stack: 950,
      currentBet: 50,
      isFolded: false,
      seatPosition: 3,
      holeCards: [], // We don't know their cards
    );

    // Player 3 - the fish
    final player3 = PlayerDisplay(
      playerId: 3,
      stack: 950,
      currentBet: 50,
      isFolded: false,
      seatPosition: 7,
      holeCards: [], // We don't know their cards
    );

    // Create the game state
    return DisplayState(
      players: [player1, player2, player3],
      // Flop: 10♥, J♥, Q♥ (flush draw)
      boardCards: [0xA3, 0xB3, 0xC3],
      potSize: 150, // Previous round + current bets
      currentBet: 0, // No bet yet on the flop
      button: 7, // Dealer button at position 7 (player 3)
      activePlayerPosition: 3, // Player 2's turn to act
      isGameActive: true,
    );
  }

  // Create a dummy game state with 3 players at the turn
  DisplayState _createDummyTurnState() {
    // Player 1 - our player, has a decent hand
    final player1 = PlayerDisplay(
      playerId: 1,
      stack: 950,
      currentBet: 50,
      isFolded: false,
      seatPosition: 0,
      holeCards: [0xE3, 0xE4], // Ace of hearts, Ace of spades
    );

    // Player 2 - the villain, to our left
    final player2 = PlayerDisplay(
      playerId: 2,
      stack: 850,
      currentBet: 150,
      isFolded: false,
      seatPosition: 3,
      holeCards: [], // We don't know their cards
    );

    // Player 3 - the fish, to our right
    final player3 = PlayerDisplay(
      playerId: 3,
      stack: 400,
      currentBet: 50,
      isFolded: false,
      seatPosition: 7,
      holeCards: [], // We don't know their cards
    );

    // Create the game state
    return DisplayState(
      players: [player1, player2, player3],
      // Community cards - 10♥, J♥, Q♥, K♠ (Turn - possible straight/flush draw)
      boardCards: [0xA3, 0xB3, 0xC3, 0xD4],
      potSize: 450, // Previous betting rounds + current bets
      currentBet: 150, // Player 2 has bet 150
      button: 7, // Dealer button at position 7 (player 3)
      activePlayerPosition: 0, // Player 1's turn to act
      isGameActive: true,
    );
  }

  // Create a dummy game state with 3 players at the river
  DisplayState _createDummyRiverState() {
    // Player 1 - our player
    final player1 = PlayerDisplay(
      playerId: 1,
      stack: 800,
      currentBet: 200,
      isFolded: false,
      seatPosition: 0,
      holeCards: [0xE3, 0xE4], // Ace of hearts, Ace of spades
    );

    // Player 2 - the villain
    final player2 = PlayerDisplay(
      playerId: 2,
      stack: 700,
      currentBet: 300,
      isFolded: false,
      seatPosition: 3,
      holeCards: [], // We don't know their cards
    );

    // Player 3 - the fish - folded after the turn
    final player3 = PlayerDisplay(
      playerId: 3,
      stack: 400,
      currentBet: 0,
      isFolded: true,
      seatPosition: 7,
      holeCards: [], // We don't know their cards
    );

    // Create the game state
    return DisplayState(
      players: [player1, player2, player3],
      // Community cards - 10♥, J♥, Q♥, K♠, A♦ (Royal flush possibility)
      boardCards: [0xA3, 0xB3, 0xC3, 0xD4, 0xE1],
      potSize: 1000, // Big pot at the river
      currentBet: 300, // Player 2 has bet 300
      button: 7, // Dealer button at position 7 (player 3)
      activePlayerPosition: 0, // Player 1's turn to act
      isGameActive: true,
    );
  }
}

enum GameStage {
  preflop,
  flop,
  turn,
  river,
}
