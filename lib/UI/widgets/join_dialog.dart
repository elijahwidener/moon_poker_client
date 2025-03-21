// join_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/core_provider.dart';
import '../../generated/game_service.pb.dart';

class JoinTableDialog extends ConsumerStatefulWidget {
  final int clientId;

  const JoinTableDialog({
    super.key,
    required this.clientId,
  });

  @override
  ConsumerState<JoinTableDialog> createState() => _JoinTableDialogState();
}

class _JoinTableDialogState extends ConsumerState<JoinTableDialog> {
  final _stackController = TextEditingController(text: '1000');
  bool _isJoining = false;

  @override
  void dispose() {
    _stackController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    final stack = int.tryParse(_stackController.text);
    if (stack == null || stack <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid stack amount')),
      );
      return;
    }

    setState(() => _isJoining = true);

    try {
      final command = ref.read(networkControllerProvider).createCommand(
            type: CommandType.JOIN,
            playerId: widget.clientId,
            joinStack: stack,
          );
      await ref.read(networkControllerProvider).sendCommand(command);
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog on success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Table'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _stackController,
            decoration: const InputDecoration(
              labelText: 'Buy-in Amount',
              prefixText: '\$',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: !_isJoining,
          ),
          const SizedBox(height: 16),
          // Could add seat selection here later
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isJoining ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isJoining ? null : _handleJoin,
          child: _isJoining
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Join'),
        ),
      ],
    );
  }
}
