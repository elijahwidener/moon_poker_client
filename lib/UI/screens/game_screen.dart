import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_provider.dart';
import '../providers/computed_provider.dart';
import '../widgets/poker_table.dart';
import '../widgets/betting_controls.dart';
import '../widgets/join_dialog.dart';
import '../../generated/game_service.pbgrpc.dart';
import 'login_screen.dart';

class GameScreen extends ConsumerWidget {
  final int clientId;

  const GameScreen({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    // Check if we're seated at the table
    final isSeated = gameState.players.any((p) => p.playerId == clientId);
    final isActive = ref.watch(isActivePlayerProvider(clientId));
    final canShowControls =
        isActive && gameState.isGameActive && !uiState.isLoading;

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
          PokerTable(
            gameState: gameState,
            localPlayerId: clientId,
          ),
          // Debug panel (temporary - remove for production)
          Positioned(
            top: 50,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Debug Info:',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  Text('clientId: $clientId',
                      style: TextStyle(color: Colors.white)),
                  Text('isSeated: $isSeated',
                      style: TextStyle(color: Colors.white)),
                  Text('isActive: $isActive',
                      style: TextStyle(color: Colors.white)),
                  Text('gameActive: ${gameState.isGameActive}',
                      style: TextStyle(color: Colors.white)),
                  Text('isLoading: ${uiState.isLoading}',
                      style: TextStyle(color: Colors.white)),
                  Text('showControls: $canShowControls',
                      style: TextStyle(color: Colors.white)),
                  Text('activePos: ${gameState.activePlayerPosition}',
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
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
                    // Animate the "YOUR TURN!" text
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: const Text(
                        'YOUR TURN!',
                        style: TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Betting controls - use direct condition to bypass provider issues
          if (canShowControls)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: BettingControls(
                  gameState: gameState,
                  networkController: ref.watch(networkControllerProvider),
                  localPlayerId: clientId,
                  playerStack: isSeated
                      ? gameState.players
                          .firstWhere((p) => p.playerId == clientId)
                          .stack
                      : 0,
                  isActive: true,
                ),
              ),
            ),

          // Leave button for seated players
          if (isSeated)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                onPressed: () => _handleLeave(ref),
                child: const Icon(Icons.exit_to_app),
              ),
            ),
        ],
      ),
      // Join button for unseated players
      floatingActionButton: !isSeated
          ? FloatingActionButton.extended(
              onPressed: () => _showJoinDialog(context),
              label: const Text('Join Table'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showJoinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => JoinTableDialog(clientId: clientId),
    );
  }

  void _handleLeave(WidgetRef ref) async {
    try {
      final command = ref.read(networkControllerProvider).createCommand(
            type: CommandType.LEAVE,
            playerId: clientId,
          );
      await ref.read(networkControllerProvider).sendCommand(command);
    } catch (e) {
      ref.read(uIStateNotifierProvider.notifier).setError(e.toString());
    }
  }
}
