import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_provider.dart';
import '../providers/computed_provider.dart';
import '../widgets/poker_table.dart';
import '../widgets/betting_controls.dart';
import 'login_screen.dart';

class GameScreen extends ConsumerWidget {
  final int clientId;

  const GameScreen({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch connection state for disconnects
    final connectionState = ref.watch(connectionStateNotifierProvider);
    final gameState = ref.watch(gameStateProvider);
    final uiState = ref.watch(uIStateNotifierProvider);

    // Handle disconnection
    if (connectionState.status == ConnectionStatus.disconnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }

    // Show error if exists
    if (uiState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(uiState.errorMessage!)),
        );
        ref.read(uIStateNotifierProvider.notifier).clearError();
      });
    }

    // Watch if we're the active player
    final isActive = ref.watch(isActivePlayerProvider(clientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moon Poker'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label:
                const Text('Disconnect', style: TextStyle(color: Colors.white)),
            onPressed: () {
              ref.read(connectionStateNotifierProvider.notifier).disconnect();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main table view
          PokerTable(
            gameState: gameState,
            localPlayerId: clientId,
          ),

          // Status bar at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Street: ${ref.watch(currentStreetProvider)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    'Players: ${ref.watch(playerCountsProvider).playerCount}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (isActive)
                    const Text(
                      'Your Turn!',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Betting controls at bottom
          if (ref.watch(canShowBettingControlsProvider(clientId)))
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BettingControls(
                gameState: gameState,
                networkController: ref.watch(networkControllerProvider),
                localPlayerId: clientId,
                playerStack: gameState.players
                    .firstWhere((p) => p.playerId == clientId)
                    .stack,
                isActive: isActive,
              ),
            ),
        ],
      ),
    );
  }
}
