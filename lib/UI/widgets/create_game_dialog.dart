// create_game_dialog.dart
//
// Dialog for creating a new poker game.
//
// Author: Elijah Widener Ferreira
// Date: 2025-03-10

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game_table.dart';
import '../providers/lobby_provider.dart';

class CreateGameDialog extends ConsumerStatefulWidget {
  final int clientId;
  final Function(String gameId) onGameCreated;

  const CreateGameDialog({
    Key? key,
    required this.clientId,
    required this.onGameCreated,
  }) : super(key: key);

  @override
  ConsumerState<CreateGameDialog> createState() => _CreateGameDialogState();
}

class _CreateGameDialogState extends ConsumerState<CreateGameDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Game settings
  GameType _gameType = GameType.holdem;
  int _smallBlind = 1;
  int _bigBlind = 2;
  int _ante = 0;
  int _minBuyIn = 100;
  int _maxBuyIn = 200;
  int _maxPlayers = 9;

  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Calculate sensible default buy-in limits based on blinds
  void _updateBuyInDefaults() {
    // Min buy-in typically 50 big blinds
    _minBuyIn = _bigBlind * 50;

    // Max buy-in typically 100-200 big blinds
    _maxBuyIn = _bigBlind * 100;

    setState(() {});
  }

  // Handle form submission with provider integration
  Future<void> _createGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isCreating = true);

    try {
      // Create the table using our provider
      final tableId = await ref.read(tablesProvider.notifier).createTable(
            name: _nameController.text,
            gameType: _gameType,
            smallBlind: _smallBlind,
            bigBlind: _bigBlind,
            ante: _ante,
            minBuyIn: _minBuyIn,
            maxBuyIn: _maxBuyIn,
            maxPlayers: _maxPlayers,
            clientId: widget.clientId,
            buyInAmount: _minBuyIn, // Default to min buy-in for now
          );

      if (tableId != null && mounted) {
        Navigator.of(context).pop();
        widget.onGameCreated(tableId);
      } else if (mounted) {
        throw Exception("Failed to create game");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create game: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Game'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Table Name',
                  hintText: 'My Poker Table',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a table name';
                  }
                  return null;
                },
                enabled: !_isCreating,
              ),
              const SizedBox(height: 16),

              // Game type
              DropdownButtonFormField<GameType>(
                decoration: const InputDecoration(
                  labelText: 'Game Type',
                  border: OutlineInputBorder(),
                ),
                value: _gameType,
                items: GameType.values
                    .map((type) => DropdownMenuItem<GameType>(
                          value: type,
                          child: Text(type.displayName),
                        ))
                    .toList(),
                onChanged: _isCreating
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _gameType = value);
                        }
                      },
              ),
              const SizedBox(height: 16),

              // Blinds row
              Row(
                children: [
                  // Small blind
                  Expanded(
                    child: TextFormField(
                      initialValue: _smallBlind.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Small Blind',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final small = int.tryParse(value);
                        if (small == null || small <= 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final small = int.tryParse(value) ?? 0;
                        if (small > 0) {
                          setState(() {
                            _smallBlind = small;
                            // Big blind is typically 2x small blind
                            _bigBlind = small * 2;
                            _updateBuyInDefaults();
                          });
                        }
                      },
                      enabled: !_isCreating,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Big blind
                  Expanded(
                    child: TextFormField(
                      initialValue: _bigBlind.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Big Blind',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final big = int.tryParse(value);
                        if (big == null || big <= 0) {
                          return 'Invalid';
                        }
                        if (big <= _smallBlind) {
                          return 'Must be > SB';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final big = int.tryParse(value) ?? 0;
                        if (big > 0) {
                          setState(() {
                            _bigBlind = big;
                            _updateBuyInDefaults();
                          });
                        }
                      },
                      enabled: !_isCreating,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ante (optional)
              TextFormField(
                initialValue: _ante.toString(),
                decoration: const InputDecoration(
                  labelText: 'Ante (Optional)',
                  prefixText: '\$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() => _ante = int.tryParse(value) ?? 0);
                },
                enabled: !_isCreating,
              ),
              const SizedBox(height: 16),

              // Buy-in range
              Row(
                children: [
                  // Min buy-in
                  Expanded(
                    child: TextFormField(
                      initialValue: _minBuyIn.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Min Buy-in',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final min = int.tryParse(value);
                        if (min == null || min <= 0) {
                          return 'Invalid';
                        }
                        if (min < _bigBlind * 20) {
                          return 'Too small';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final min = int.tryParse(value) ?? 0;
                        if (min > 0) {
                          setState(() => _minBuyIn = min);
                        }
                      },
                      enabled: !_isCreating,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Max buy-in
                  Expanded(
                    child: TextFormField(
                      initialValue: _maxBuyIn.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Max Buy-in',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final max = int.tryParse(value);
                        if (max == null || max <= 0) {
                          return 'Invalid';
                        }
                        if (max <= _minBuyIn) {
                          return 'Must be > min';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        final max = int.tryParse(value) ?? 0;
                        if (max > 0) {
                          setState(() => _maxBuyIn = max);
                        }
                      },
                      enabled: !_isCreating,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Max players
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Max Players',
                  border: OutlineInputBorder(),
                ),
                value: _maxPlayers,
                items: [2, 4, 6, 8, 9]
                    .map((count) => DropdownMenuItem<int>(
                          value: count,
                          child: Text('$count Players'),
                        ))
                    .toList(),
                onChanged: _isCreating
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _maxPlayers = value);
                        }
                      },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCreating ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createGame,
          child: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Game'),
        ),
      ],
    );
  }
}
