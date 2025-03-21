import 'package:flutter/material.dart';
import '../../models/display_state.dart';
import '../../models/player_display.dart';
import 'dart:math' as math;
import 'dealer_button.dart';
import 'card_widgets.dart';
import 'active_player_highlight.dart';
import 'chip_animation.dart';

class PokerTable extends StatefulWidget {
  final DisplayState gameState;
  final int localPlayerId;

  const PokerTable({
    super.key,
    required this.gameState,
    required this.localPlayerId,
  });

  @override
  State<PokerTable> createState() => _PokerTableState();
}

class _PokerTableState extends State<PokerTable> {
  DisplayState? _previousState;
  final Map<int, GlobalKey> _playerKeys = {};
  final GlobalKey _potKey = GlobalKey();
  final List<Widget> _chipAnimations = [];

  @override
  void initState() {
    super.initState();
    _previousState = widget.gameState;

    // Initialize player position keys
    for (int i = 0; i < 9; i++) {
      _playerKeys[i] = GlobalKey();
    }
  }

  @override
  void didUpdateWidget(PokerTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check for changes that would trigger animations
    if (_previousState != null) {
      _checkForBetChanges();
      _checkForCardChanges();
    }

    _previousState = widget.gameState;
  }

  void _checkForBetChanges() {
    // Check if any player's bet has changed
    for (final player in widget.gameState.players) {
      final previousPlayer = _previousState?.players.firstWhere(
        (p) => p.playerId == player.playerId,
        orElse: () => PlayerDisplay(
          playerId: 0,
          stack: 0,
          currentBet: 0,
          isFolded: false,
          seatPosition: 0,
        ),
      );

      // If bet increased, animate chips from player to pot
      if (player.currentBet > (previousPlayer?.currentBet ?? 0)) {
        _animateChipsTowardsPot(player.seatPosition,
            player.currentBet - (previousPlayer?.currentBet ?? 0));
      }
    }
  }

  void _checkForCardChanges() {
    // Check if community cards have changed
    final previousCardCount =
        _previousState?.boardCards.where((c) => c != 0).length ?? 0;
    final currentCardCount =
        widget.gameState.boardCards.where((c) => c != 0).length;

    if (currentCardCount > previousCardCount) {
      // New community cards were dealt
      setState(() {
        // Animation will be triggered by the animate flag in CommunityCards
      });
    }
  }

  void _animateChipsTowardsPot(int playerSeatPosition, int betAmount) {
    // Find positions for animation
    if (!_playerKeys.containsKey(playerSeatPosition) ||
        _potKey.currentContext == null) {
      return;
    }

    final RenderBox playerBox = _playerKeys[playerSeatPosition]!
        .currentContext!
        .findRenderObject() as RenderBox;
    final RenderBox potBox =
        _potKey.currentContext!.findRenderObject() as RenderBox;

    final Offset playerPos = playerBox.localToGlobal(
      Offset(playerBox.size.width / 2, playerBox.size.height / 2),
    );

    final Offset potPos = potBox.localToGlobal(
      Offset(potBox.size.width / 2, potBox.size.height / 2),
    );

    // Create chip animation
    setState(() {
      _chipAnimations.add(
        ChipAnimation(
          amount: betAmount,
          startPosition: playerPos,
          endPosition: potPos,
          duration: const Duration(milliseconds: 800),
          chipCount:
              math.min(5, betAmount ~/ 10 + 1), // Scale chip count with bet
          onComplete: () {
            // Remove animation when done
            setState(() {
              _chipAnimations.removeWhere((anim) =>
                  anim is ChipAnimation &&
                  anim.startPosition == playerPos &&
                  anim.endPosition == potPos);
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;
        final radius = math.min(centerX, centerY) * 0.75;
        final scale =
            math.min(constraints.maxWidth, constraints.maxHeight) / 800;
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
                      color: Colors.black.withAlpha((0.5 * 255).toInt()),
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
                  cards: widget.gameState.boardCards,
                  height: 140 * scale,
                  // Animate cards if they're newly added
                  animate: _previousState != null &&
                      widget.gameState.boardCards.where((c) => c != 0).length >
                          (_previousState?.boardCards
                                  .where((c) => c != 0)
                                  .length ??
                              0),
                ),
              ),
            ),

            // Pot display in center
            Positioned(
              top: centerY + 40,
              left: 0,
              right: 0,
              child: Center(
                key: _potKey, // Add key for animation targeting
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pot: \$${widget.gameState.potSize}',
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
              for (var p in widget.gameState.players) {
                if (p.seatPosition == index) {
                  player = p;
                  break;
                }
              }

              // Get player position
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
                child: Container(
                  key: _playerKeys[index], // Add key for animation targeting
                  child: _buildPlayerSeat(
                    player ??
                        PlayerDisplay(
                          playerId: 0,
                          stack: 0,
                          currentBet: 0,
                          isFolded: false,
                          seatPosition: index,
                        ),
                    scale,
                  ),
                ),
              );
            }),

            // Current bet display
            if (widget.gameState.currentBet > 0)
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
                    'Bet: \$${widget.gameState.currentBet}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

            // Dealer button
            DealerButton(
              position: widget.gameState.button,
              tableWidth: constraints.maxWidth,
              tableHeight: constraints.maxHeight,
            ),

            // Chip animations layer
            ..._chipAnimations,
          ],
        );
      },
    );
  }

  Widget _buildPlayerSeat(PlayerDisplay player, double scale) {
    final isOccupied = player.playerId != 0;
    final isLocal = player.playerId == widget.localPlayerId;
    final isActive =
        widget.gameState.activePlayerPosition == player.seatPosition;

    // Scale the seat size but keep it simple
    final width = 120.0 * scale;
    final height = 150.0 * scale;

    final seat = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isOccupied ? Colors.black54 : Colors.black26,
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
                    child: HoleCards(
                      cards: isLocal
                          ? player.holeCards
                          : [1, 1], // Dummy cards for non-local players
                      showCards: isLocal,
                      height: 60 * scale,
                      // Animate only new cards being dealt
                      animate: _previousState != null &&
                          player.holeCards.length >
                              (_previousState!.players
                                  .firstWhere(
                                    (p) => p.playerId == player.playerId,
                                    orElse: () => PlayerDisplay(
                                      playerId: 0,
                                      stack: 0,
                                      currentBet: 0,
                                      isFolded: false,
                                      seatPosition: 0,
                                      holeCards: [],
                                    ),
                                  )
                                  .holeCards
                                  .length),
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

    // Wrap with active player highlight if this is the active player
    return ActivePlayerHighlight(
      isActive: isActive,
      highlightColor: Colors.blue,
      child: seat,
    );
  }
}
