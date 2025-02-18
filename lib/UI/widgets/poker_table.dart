import 'package:flutter/material.dart';
import '../../models/display_state.dart';
import '../../models/player_display.dart';
import 'dealer_button.dart';
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
        final radius = math.min(centerX, centerY) * 0.8;

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

            // Pot display in center
            if (gameState.potSize > 0)
              Positioned(
                top: centerY - 25,
                left: centerX - 50,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pot: \$${gameState.potSize}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Player positions
            ...List.generate(9, (index) {
              final player = gameState.players[index];
              final position =
                  _getPlayerPosition(index, centerX, centerY, radius);

              return Positioned(
                left: position.dx - 60, // Half of seat width
                top: position.dy - 40, // Half of seat height
                child: _buildPlayerSeat(player),
              );
            }),

            // Current bet display
            if (gameState.currentBet > 0)
              Positioned(
                top: centerY + 40,
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

  Widget _buildPlayerSeat(PlayerDisplay player) {
    final isOccupied = player.playerId != 0;
    final isLocal = player.playerId == localPlayerId;
    final isActive = gameState.activePlayerPosition == player.seatPosition;

    return Container(
      width: 120,
      height: 80,
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
          : const Icon(
              Icons.chair,
              color: Colors.white24,
              size: 32,
            ),
    );
  }

  Offset _getPlayerPosition(
      int seatIndex, double centerX, double centerY, double radius) {
    // Arrange seats in an elliptical pattern
    final angle = (2 * math.pi * seatIndex / 9) - (math.pi / 2);
    // Make the table slightly oval by adjusting X radius
    final xRadius = radius * 1.2;
    final yRadius = radius * 0.9;

    return Offset(
      centerX + xRadius * math.cos(angle),
      centerY + yRadius * math.sin(angle),
    );
  }
}
