/// player_display.dart
///
/// This file defines the [PlayerDisplay] class, which represents a player's
/// current state at the poker table. It includes properties such as stack size,
/// current bet, folded status, and seat position.
///
/// The class provides:
/// - A factory constructor to create an instance from a protobuf message.
/// - An immutable `copyWith` method to facilitate state updates.
/// - Equality and hashCode overrides for efficient comparisons.
///
/// Author: Elijah Widener Ferreira
/// Date: 2021-06-30
///
library;

import '../generated/game_service.pb.dart';
import 'package:collection/collection.dart';

class PlayerDisplay {
  final int playerId; // Unique identifier for the player
  final int stack; // Current chip stack
  final int currentBet; // Current bet in this round
  final bool isFolded; // Whether the player has folded
  final int seatPosition; // Position at the table (0-8)
  final List<int> holeCards; // Player's hole cards

  const PlayerDisplay({
    required this.playerId,
    required this.stack,
    required this.currentBet,
    required this.isFolded,
    required this.seatPosition,
    this.holeCards = const [],
  });

  // Create from proto message
  factory PlayerDisplay.fromProto(PlayerView proto) {
    print('Cards received: ${proto.holeCards.toList()}');

    return PlayerDisplay(
      playerId: proto.playerId.toInt(),
      stack: proto.stack.toInt(),
      currentBet: proto.currentBet.toInt(),
      isFolded: proto.isFolded,
      seatPosition: proto.seatPosition,
      holeCards: proto.holeCards.toList(),
    );
  }

  // Copy with method for immutable updates
  PlayerDisplay copyWith({
    int? playerId,
    int? stack,
    int? currentBet,
    bool? isFolded,
    int? seatPosition,
    List<int>? holeCards,
  }) {
    return PlayerDisplay(
      playerId: playerId ?? this.playerId,
      stack: stack ?? this.stack,
      currentBet: currentBet ?? this.currentBet,
      isFolded: isFolded ?? this.isFolded,
      seatPosition: seatPosition ?? this.seatPosition,
      holeCards: holeCards ?? this.holeCards,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerDisplay &&
          other.playerId == playerId &&
          other.stack == stack &&
          other.currentBet == currentBet &&
          other.isFolded == isFolded &&
          other.seatPosition == seatPosition &&
          ListEquality().equals(other.holeCards, holeCards);

  @override
  int get hashCode => Object.hash(
        playerId,
        stack,
        currentBet,
        isFolded,
        seatPosition,
        ListEquality().hash(holeCards),
      );
}
