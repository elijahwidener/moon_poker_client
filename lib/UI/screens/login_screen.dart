import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_provider.dart';
import 'lobby_screen.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  final TextEditingController _idController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch connection state for changes
    final connectionState = ref.watch(connectionStateNotifierProvider);
    final uiState = ref.watch(uIStateNotifierProvider);

    // Show error if exists
    if (uiState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(uiState.errorMessage!)),
        );
        // Clear error after showing
        ref.read(uIStateNotifierProvider.notifier).clearError();
      });
    }

    // If connected, navigate to lobby screen
    if (connectionState.status == ConnectionStatus.connected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                LobbyScreen(clientId: connectionState.clientId),
          ),
        );
      });
    }

    return Scaffold(
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Moon Poker',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _idController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    hintText: 'Enter any number for testing',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  enabled:
                      connectionState.status != ConnectionStatus.connecting,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed:
                      connectionState.status == ConnectionStatus.connecting
                          ? null
                          : () => _handleConnect(ref, context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: connectionState.status == ConnectionStatus.connecting
                      ? const CircularProgressIndicator()
                      : const Text('Connect'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleConnect(WidgetRef ref, BuildContext context) {
    final userId = int.tryParse(_idController.text);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid user ID')),
      );
      return;
    }

    // Attempt connection
    ref.read(connectionStateNotifierProvider.notifier).connect(userId);
  }
}
