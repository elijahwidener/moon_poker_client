import 'package:flutter/material.dart';
import '../../models/display_state.dart';
import '../../network/network_controller.dart';
import '../../generated/game_service.pb.dart';

class BettingControls extends StatefulWidget {
  final DisplayState gameState;
  final NetworkController networkController;
  final int localPlayerId;
  final int playerStack;
  final bool isActive;

  const BettingControls({
    super.key,
    required this.gameState,
    required this.networkController,
    required this.localPlayerId,
    required this.playerStack,
    required this.isActive,
  });

  @override
  State<BettingControls> createState() => _BettingControlsState();
}

class _BettingControlsState extends State<BettingControls> {
  double _raiseAmount = 0;
  bool _showRaiseSlider = false;

  void _handleAction(CommandType action) async {
    try {
      final command = widget.networkController.createCommand(
        type: action,
        playerId: widget.localPlayerId,
        raiseAmount: action == CommandType.RAISE ? _raiseAmount.toInt() : null,
      );
      await widget.networkController.sendCommand(command);
      if (mounted && _showRaiseSlider) {
        setState(() => _showRaiseSlider = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Calculate minimum and maximum raise amounts
  int get _minRaise => widget.gameState.currentBet * 2;
  int get _maxRaise => widget.playerStack;

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    final callAmount = widget.gameState.currentBet;
    final canCheck = callAmount == 0;
    final canCall = callAmount > 0 && callAmount <= widget.playerStack;
    final canRaise = widget.playerStack > _minRaise;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ActionButton(
              label: 'Fold',
              onPressed: () => _handleAction(CommandType.FOLD),
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            ActionButton(
              label: canCheck ? 'Check' : 'Call \$$callAmount',
              onPressed: canCheck || canCall
                  ? () => _handleAction(
                      canCheck ? CommandType.CHECK : CommandType.CALL)
                  : null,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            ActionButton(
              label: 'Raise',
              onPressed: canRaise
                  ? () => setState(() => _showRaiseSlider = !_showRaiseSlider)
                  : null,
              color: Colors.blue,
              selected: _showRaiseSlider,
            ),
          ],
        ),

        // Raise slider
        if (_showRaiseSlider && canRaise) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Raise: \$${_raiseAmount.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RaiseButton(
                          label: '2x',
                          onPressed: () => setState(
                              () => _raiseAmount = _minRaise.toDouble()),
                        ),
                        const SizedBox(width: 8),
                        _RaiseButton(
                          label: '3x',
                          onPressed: () => setState(() =>
                              _raiseAmount = (_minRaise * 1.5).toDouble()),
                        ),
                        const SizedBox(width: 8),
                        _RaiseButton(
                          label: 'Max',
                          onPressed: () => setState(
                              () => _raiseAmount = _maxRaise.toDouble()),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.blue,
                    thumbColor: Colors.blue,
                    overlayColor: Colors.blue.withOpacity(0.3),
                  ),
                  child: Slider(
                    value: _raiseAmount,
                    min: _minRaise.toDouble(),
                    max: _maxRaise.toDouble(),
                    onChanged: (value) => setState(() => _raiseAmount = value),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _handleAction(CommandType.RAISE),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(200, 40),
                  ),
                  child: const Text('Confirm Raise'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool selected;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.color,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: selected ? color : color.withOpacity(0.8),
        minimumSize: const Size(100, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _RaiseButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _RaiseButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        minimumSize: const Size(50, 30),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(label),
    );
  }
}
