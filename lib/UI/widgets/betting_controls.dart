import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _raiseInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeRaiseAmount();
  }

  @override
  void didUpdateWidget(BettingControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset the raise amount when the game state changes
    if (oldWidget.gameState != widget.gameState) {
      _initializeRaiseAmount();
    }
  }

  @override
  void dispose() {
    _raiseInputController.dispose();
    super.dispose();
  }

  void _initializeRaiseAmount() {
    // Start with min raise as initial amount
    _raiseAmount = _minRaise.toDouble();
    _raiseInputController.text = _raiseAmount.toInt().toString();
  }

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

  // Get current pot size for percentage calculations
  int get _potSize => widget.gameState.potSize;

  // Calculate call amount for current player
  int get _callAmount => widget.gameState.currentBet;

  // Check if player can check (no bet to call)
  bool get _canCheck => _callAmount == 0;

  // Check if player can call (has a bet to call and enough stack)
  bool get _canCall => _callAmount > 0;

  // Check if player can raise (previous bet reopened action for them)
  bool get _canRaise => true; // Placeholder, TODO: need to find a way

  // Update raise amount with validation
  void _updateRaiseAmount(double value) {
    setState(() {
      _raiseAmount = value.clamp(_minRaise.toDouble(), _maxRaise.toDouble());
      _raiseInputController.text = _raiseAmount.toInt().toString();
    });
  }

  // Update raise amount from text input
  void _updateRaiseFromInput(String value) {
    final intValue = int.tryParse(value) ?? _minRaise;
    _updateRaiseAmount(intValue.toDouble());
  }

  // Set raise to percentage of pot
  void _setRaiseToPercentOfPot(double percent) {
    final amount = (_potSize * percent).toInt();
    _updateRaiseAmount(
        amount > _minRaise ? amount.toDouble() : _minRaise.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
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
                label: _canCheck ? 'Check' : 'Call \$${_callAmount}',
                onPressed: _canCheck || _canCall
                    ? () => _handleAction(
                        _canCheck ? CommandType.CHECK : CommandType.CALL)
                    : null,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              ActionButton(
                label: 'Raise',
                onPressed: _canRaise
                    ? () => setState(() => _showRaiseSlider = !_showRaiseSlider)
                    : null,
                color: Colors.blue,
                selected: _showRaiseSlider,
              ),
            ],
          ),

          // Raise slider
          if (_showRaiseSlider && _canRaise) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Raise amount display and input
                  Row(
                    children: [
                      Text(
                        'Raise to:',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 100,
                        height: 40,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _raiseInputController,
                          decoration: InputDecoration(
                            prefixText: '\$',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: _updateRaiseFromInput,
                        ),
                      ),
                      Spacer(),
                      // Percentage buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RaiseButton(
                            label: 'Min',
                            onPressed: () =>
                                _updateRaiseAmount(_minRaise.toDouble()),
                          ),
                          const SizedBox(width: 4),
                          RaiseButton(
                            label: '1/2 Pot',
                            onPressed: () => _setRaiseToPercentOfPot(0.5),
                          ),
                          const SizedBox(width: 4),
                          RaiseButton(
                            label: 'Pot',
                            onPressed: () => _setRaiseToPercentOfPot(1.0),
                          ),
                          const SizedBox(width: 4),
                          RaiseButton(
                            label: 'All In',
                            onPressed: () =>
                                _updateRaiseAmount(_maxRaise.toDouble()),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Raise slider with formatted min/max values
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blue,
                      thumbColor: Colors.blue,
                      overlayColor: Colors.blue.withOpacity(0.3),
                      trackHeight: 8,
                    ),
                    child: Column(
                      children: [
                        Slider(
                          value: _raiseAmount,
                          min: _minRaise.toDouble(),
                          max: _maxRaise.toDouble(),
                          onChanged: _updateRaiseAmount,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$${_minRaise}',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              Text('\$${_maxRaise}',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _handleAction(CommandType.RAISE),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(200, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Raise to \$${_raiseAmount.toInt()}'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
        backgroundColor: onPressed == null
            ? Colors.grey.withOpacity(0.3)
            : (selected ? color : color.withOpacity(0.8)),
        minimumSize: const Size(100, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: selected ? 8 : 4,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: onPressed == null ? Colors.grey : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
    );
  }
}

class RaiseButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const RaiseButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        minimumSize: const Size(0, 30),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}
