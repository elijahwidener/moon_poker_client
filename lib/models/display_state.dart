/// display_state.dart
///
/// This file defines the [DisplayState] class, representing the current state
/// of the poker game display. It includes details about players, community cards,
/// pot size, betting, and game status.
///
/// The class provides:
/// - A factory constructor to create an instance from a protobuf message.
/// - An `empty` factory constructor for initializing a default state.
/// - An immutable `copyWith` method for state updates.
/// - Equality and hashCode overrides for efficient state comparison.
///
/// Author: Elijah Widener Ferreira
/// Date: 2021-06-30
///
library;

import 'package:flutter/foundation.dart';
import 'player_display.dart';
import '../generated/game_service.pb.dart';

class DisplayState {
  final List<PlayerDisplay> players; // All players at the table
  final List<int> boardCards; // Community cards (as 8-bit integers)
  final int potSize; // Total chips in the pot
  final int currentBet; // Current bet to call
  final int button; // Dealer button position
  final int activePlayerPosition; // Position of active player
  final bool isGameActive; // Whether a hand is in progress

  const DisplayState({
    required this.players,
    required this.boardCards,
    required this.potSize,
    required this.currentBet,
    required this.button,
    required this.activePlayerPosition,
    required this.isGameActive,
  });

  // Create from proto message
  factory DisplayState.fromProto(GameSnapshot proto) {
    return DisplayState(
      players: proto.players.map((p) => PlayerDisplay.fromProto(p)).toList(),
      boardCards: proto.cards.toList(),
      potSize: proto.potSize,
      currentBet: proto.currentBet,
      button: proto.button,
      activePlayerPosition: proto.currentPlayerPosition,
      isGameActive: proto.isGameActive,
    );
  }

  // Create empty state
  factory DisplayState.empty() {
    return DisplayState(
      players: List.filled(
          9,
          PlayerDisplay(
            playerId: 0,
            stack: 0,
            currentBet: 0,
            isFolded: false,
            seatPosition: 0,
          )),
      boardCards: List.filled(5, 0),
      potSize: 0,
      currentBet: 0,
      button: 0,
      activePlayerPosition: 0,
      isGameActive: false,
    );
  }

  // Copy with method for immutable updates
  DisplayState copyWith({
    List<PlayerDisplay>? players,
    List<int>? boardCards,
    int? potSize,
    int? currentBet,
    int? button,
    int? activePlayerPosition,
    bool? isGameActive,
  }) {
    return DisplayState(
      players: players ?? this.players,
      boardCards: boardCards ?? this.boardCards,
      potSize: potSize ?? this.potSize,
      currentBet: currentBet ?? this.currentBet,
      button: button ?? this.button,
      activePlayerPosition: activePlayerPosition ?? this.activePlayerPosition,
      isGameActive: isGameActive ?? this.isGameActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DisplayState &&
          listEquals(other.players, players) &&
          listEquals(other.boardCards, boardCards) &&
          other.potSize == potSize &&
          other.currentBet == currentBet &&
          other.button == button &&
          other.activePlayerPosition == activePlayerPosition &&
          other.isGameActive == isGameActive;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(players),
        Object.hashAll(boardCards),
        potSize,
        currentBet,
        button,
        activePlayerPosition,
        isGameActive,
      );
}
