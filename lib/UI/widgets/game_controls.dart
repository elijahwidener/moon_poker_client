import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_provider.dart';
import '../../generated/game_service.pb.dart';
import '../../network/network_controller.dart';

/// Widget that provides game control buttons (start/pause/unpause)
class GameControls extends ConsumerWidget {
  final int clientId;

  const GameControls({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final networkController = ref.watch(networkControllerProvider);
    final uiState = ref.watch(uIStateNotifierProvider);
    final isAdmin =
        clientId == 1; // Simple check - in a real app this would be more robust

    // Only show controls to admins
    if (!isAdmin) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!gameState.isGameActive)
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, color: Colors.green),
              label: const Text('Start Game'),
              onPressed: uiState.isLoading
                  ? null
                  : () {
                      _sendGameCommand(networkController,
                          CommandType.PAUSE_UNPAUSE, clientId);
                      ref
                          .read(uIStateNotifierProvider.notifier)
                          .setLoading(true);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black45,
              ),
            ),

          if (gameState.isGameActive)
            ElevatedButton.icon(
              icon: const Icon(Icons.pause, color: Colors.orange),
              label: const Text('Pause Game'),
              onPressed: uiState.isLoading
                  ? null
                  : () {
                      _sendGameCommand(networkController,
                          CommandType.PAUSE_UNPAUSE, clientId);
                      ref
                          .read(uIStateNotifierProvider.notifier)
                          .setLoading(true);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black45,
              ),
            ),

          // Show loading indicator if needed
          if (uiState.isLoading)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _sendGameCommand(
    NetworkController controller,
    CommandType type,
    int playerId,
  ) async {
    try {
      final command = controller.createCommand(
        type: type,
        playerId: playerId,
      );
      await controller.sendCommand(command);
    } catch (e) {
      print('Error sending game command: $e');
    }
  }
}
