import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/player_display.dart';
import 'core_provider.dart';

part 'computed_provider.g.dart';

// Active player related providers
@riverpod
bool isActivePlayer(Ref ref, int playerId) {
  final gameState = ref.watch(gameStateProvider);
  final activePosition = gameState.activePlayerPosition;

  final result = gameState.players
      .where((p) => p.playerId == playerId)
      .any((p) => p.seatPosition == activePosition);

  print('isActivePlayer($playerId): $result, activePosition: $activePosition');

  return result;
}

@riverpod
PlayerDisplay? activePlayer(Ref ref) {
  final gameState = ref.watch(gameStateProvider);
  final activePosition = gameState.activePlayerPosition;

  return gameState.players
      .where((p) => p.seatPosition == activePosition)
      .firstOrNull;
}

// Betting control providers
@riverpod
bool canShowBettingControls(Ref ref, int playerId) {
  final isActive = ref.watch(isActivePlayerProvider(playerId));
  final gameState = ref.watch(gameStateProvider);
  final uiState = ref.watch(uIStateNotifierProvider);
  print(
      'Controls check - Player: $playerId, isActive: $isActive, gameActive: ${gameState.isGameActive}, isLoading: ${uiState.isLoading}');

  return isActive && gameState.isGameActive && !uiState.isLoading;
}

@riverpod
({int minRaise, int maxRaise}) betRange(Ref ref, int playerId) {
  final gameState = ref.watch(gameStateProvider);
  final player =
      gameState.players.where((p) => p.playerId == playerId).firstOrNull;

  if (player == null) return (minRaise: 0, maxRaise: 0);

  // Minimum raise is current bet doubled
  final minRaise = gameState.currentBet * 2;
  // Maximum raise is player's stack
  final maxRaise = player.stack;

  return (minRaise: minRaise, maxRaise: maxRaise);
}

// Card visibility providers
@riverpod
bool shouldShowCards(Ref ref, int playerId, int seatPosition) {
  final gameState = ref.watch(gameStateProvider);
  final player = gameState.players
      .where((p) => p.seatPosition == seatPosition)
      .firstOrNull;

  if (player == null) return false;

  // Show cards if:
  // 1. They belong to the local player
  // 2. Game is in showdown
  // 3. Player has folded (optional - depends on game rules)
  final currentStreet = ref.watch(currentStreetProvider);
  final isShowdown = currentStreet == 'Showdown';
  return player.playerId == playerId || isShowdown || player.isFolded;
}

// Game status providers
@riverpod
({int playerCount, int activePlayers}) playerCounts(Ref ref) {
  final gameState = ref.watch(gameStateProvider);

  final totalPlayers = gameState.players.where((p) => p.playerId != 0).length;

  final activePlayers =
      gameState.players.where((p) => p.playerId != 0 && !p.isFolded).length;

  return (playerCount: totalPlayers, activePlayers: activePlayers);
}

@riverpod
double potOdds(Ref ref, int playerId) {
  final gameState = ref.watch(gameStateProvider);
  final player =
      gameState.players.where((p) => p.playerId == playerId).firstOrNull;

  if (player == null) return 0.0;

  final callAmount = gameState.currentBet - player.currentBet;
  if (callAmount <= 0) return 0.0;

  final potSize = gameState.potSize + callAmount;
  return (callAmount / potSize) * 100;
}

// Position providers
@riverpod
bool isInPosition(Ref ref, int playerId) {
  final gameState = ref.watch(gameStateProvider);
  final player =
      gameState.players.where((p) => p.playerId == playerId).firstOrNull;

  if (player == null) return false;

  // On the button or last to act
  return player.seatPosition == gameState.button ||
      player.seatPosition == (gameState.button + 1) % gameState.players.length;
}

// Street/round tracking
@riverpod
int visibleCommunityCards(Ref ref) {
  final gameState = ref.watch(gameStateProvider);
  return gameState.boardCards
      .where((card) => card != 0) // Assuming 0 is invalid card
      .length;
}

@riverpod
String currentStreet(Ref ref) {
  final cardCount = ref.watch(visibleCommunityCardsProvider);

  return switch (cardCount) {
    0 => 'Preflop',
    3 => 'Flop',
    4 => 'Turn',
    5 => 'River',
    _ => 'Unknown',
  };
}
