import 'package:flutter/material.dart';
import '../../models/display_state.dart';
import '../../models/player_display.dart';
import 'dealer_button.dart';
import 'card_widgets.dart';
import 'dart:math' as math;

class PokerTable extends StatelessWidget {
  final DisplayState gameState;
  final int localPlayerId;

  const PokerTable({
    super.key,
    required this.gameState,
    required this.localPlayerId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;
        final radius = math.min(centerX, centerY) * 0.75;

        // Simple scale factor based on screen size
        final scale =
            math.min(constraints.maxWidth, constraints.maxHeight) / 800;

        // Push players farther from center
        final edgePushFactor = 1.1;

        return Stack(
          children: [
            // The main table
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF35654d), // Poker felt green
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: const Color(0xFF4a2c2a), // Dark wood trim
                    width: 12,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            // Community cards display
            Positioned(
              top: math.max(centerY - 100, 20),
              left: 0,
              right: 0,
              child: Center(
                child: CommunityCards(
                  cards: gameState.boardCards,
                  height: 140 * scale,
                  // Width is auto-calculated based on card aspect ratio
                ),
              ),
            ),

            // Pot display in center
            Positioned(
              top: centerY + 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pot: ${gameState.potSize}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Player positions
            ...List.generate(9, (index) {
              PlayerDisplay? player;
              for (var p in gameState.players) {
                if (p.seatPosition == index) {
                  player = p;
                  break;
                }
              }

              // Get player position, pushed farther from center
              final angle = (2 * math.pi * index / 9) - (math.pi / 2);
              final xRadius = radius * 1.2 * edgePushFactor;
              final yRadius = radius * 0.9 * edgePushFactor;

              final position = Offset(
                centerX + xRadius * math.cos(angle),
                centerY + yRadius * math.sin(angle),
              );

              return Positioned(
                left: position.dx - 60,
                top: position.dy - 40,
                child: _buildPlayerSeat(
                    player ??
                        PlayerDisplay(
                          playerId: 0,
                          stack: 0,
                          currentBet: 0,
                          isFolded: false,
                          seatPosition: index,
                        ),
                    scale),
              );
            }),

            // Current bet display
            if (gameState.currentBet > 0)
              Positioned(
                top: centerY + 75,
                left: centerX - 40,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Bet: \$${gameState.currentBet}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

            DealerButton(
              position: gameState.button,
              tableWidth: constraints.maxWidth,
              tableHeight: constraints.maxHeight,
            ),
          ],
        );
      },
    );
  }

  // TODO: Work on making this more dynamic and clean. Looks fine for now.

  Widget _buildPlayerSeat(PlayerDisplay player, double scale) {
    final isOccupied = player.playerId != 0;
    final isLocal = player.playerId == localPlayerId;
    final isActive = gameState.activePlayerPosition == player.seatPosition;

    // Scale the seat size but keep it simple
    final width = 120.0 * scale;
    final height = 150.0 * scale;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isOccupied
            ? (isActive ? Colors.blue.withOpacity(0.3) : Colors.black54)
            : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: isLocal ? Border.all(color: Colors.yellow, width: 2) : null,
      ),
      child: isOccupied
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Player ${player.playerId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),

                // Show cards if the player is still in the hand
                if (!player.isFolded)
                  Flexible(
                    // Add Flexible wrapper
                    child: HoleCards(
                      cards: isLocal
                          ? player.holeCards
                          : [1, 1], // Dummy cards for non-local players
                      showCards: isLocal,
                      height: 60 * scale,
                    ),
                  ),

                const SizedBox(height: 4),
                Text(
                  '\$${player.stack}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (player.currentBet > 0)
                  Text(
                    'Bet: \$${player.currentBet}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                    ),
                  ),
              ],
            )
          : Icon(
              Icons.chair,
              color: Colors.white24,
              size: 32 * scale,
            ),
    );
  }
}
