// lobby_screen.dart
//
// Displays the main lobby screen with game tables and filters.
//
// Author: Elijah Widener Ferreira
// Date: 2025-03-10

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/game_table.dart';
import '../providers/core_provider.dart';
import './game_screen.dart';
import './login_screen.dart';
import '../widgets/create_game_dialog.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final int clientId;

  const LobbyScreen({
    Key? key,
    required this.clientId,
  }) : super(key: key);

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  // Filter state
  GameType? _selectedGameType;
  RangeValues _stakesRange = const RangeValues(1, 10);
  bool _showEmptyTables = true;
  bool _showFullTables = true;
  bool _showRunningTables = true;

  // Mock data - would come from a provider in real implementation
  late List<GameTable> _tables;
  late List<GameTable> _filteredTables;

  @override
  void initState() {
    super.initState();
    _tables = GameTable.getMockTables();
    _applyFilters();
  }

  // Apply current filters to the table list
  void _applyFilters() {
    setState(() {
      _filteredTables = _tables.where((table) {
        // Game type filter
        if (_selectedGameType != null && table.gameType != _selectedGameType) {
          return false;
        }

        // Stakes filter
        if (table.bigBlind < _stakesRange.start ||
            table.bigBlind > _stakesRange.end) {
          return false;
        }

        // Empty tables filter
        if (!_showEmptyTables && table.seatedPlayers == 0) {
          return false;
        }

        // Full tables filter
        if (!_showFullTables && table.seatedPlayers == table.maxPlayers) {
          return false;
        }

        // Running tables filter
        if (!_showRunningTables && table.isRunning) {
          return false;
        }

        return true;
      }).toList();
    });
  }

  // Handle joining a table
  void _joinTable(GameTable table) {
    // In a real implementation, this would send a join request to the server
    // and navigate to the game screen on success
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(clientId: widget.clientId),
      ),
    );
  }

  // Show dialog to create a new game
  void _showCreateGameDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateGameDialog(
        clientId: widget.clientId,
        onGameCreated: (gameId) {
          // In a real implementation, we would refresh the table list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Game created with ID: $gameId')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStateNotifierProvider);

    // Handle disconnection
    if (connectionState.status == ConnectionStatus.disconnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moon Poker - Lobby'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // In a real implementation, this would fetch the latest tables
              _applyFilters();
            },
            tooltip: 'Refresh tables',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(connectionStateNotifierProvider.notifier).disconnect();
            },
            tooltip: 'Disconnect',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter controls
          _buildFilterBar(),

          // Table list
          Expanded(
            child: _buildTableList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateGameDialog,
        icon: const Icon(Icons.add),
        label: const Text('Create Game'),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Game type dropdown
              Expanded(
                child: DropdownButtonFormField<GameType?>(
                  decoration: const InputDecoration(
                    labelText: 'Game Type',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: _selectedGameType,
                  items: [
                    const DropdownMenuItem<GameType?>(
                      value: null,
                      child: Text('All Games'),
                    ),
                    ...GameType.values
                        .map((type) => DropdownMenuItem<GameType?>(
                              value: type,
                              child: Text(type.displayName),
                            )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGameType = value;
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Table state filters
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterChip(
                      label: 'Empty Tables',
                      selected: _showEmptyTables,
                      onSelected: (value) {
                        setState(() {
                          _showEmptyTables = value;
                          _applyFilters();
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Full Tables',
                      selected: _showFullTables,
                      onSelected: (value) {
                        setState(() {
                          _showFullTables = value;
                          _applyFilters();
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Running Games',
                      selected: _showRunningTables,
                      onSelected: (value) {
                        setState(() {
                          _showRunningTables = value;
                          _applyFilters();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stakes range slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Stakes Range: \$${_stakesRange.start.toInt()} - \$${_stakesRange.end.toInt()}'),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  showValueIndicator: ShowValueIndicator.always,
                ),
                child: RangeSlider(
                  min: 1,
                  max: 100,
                  divisions: 20,
                  values: _stakesRange,
                  labels: RangeLabels(
                    '\$${_stakesRange.start.toInt()}',
                    '\$${_stakesRange.end.toInt()}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _stakesRange = values;
                    });
                  },
                  onChangeEnd: (values) {
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      checkmarkColor: Colors.white,
      selectedColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildTableList() {
    if (_filteredTables.isEmpty) {
      return const Center(
        child: Text(
          'No tables match your filters',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredTables.length,
      itemBuilder: (context, index) {
        final table = _filteredTables[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: _buildGameTypeIcon(table.gameType),
            title: Text(table.name),
            subtitle:
                Text('${table.gameType.displayName} · ${table.stakesString}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Players: ${table.playerCount}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Buy-in: ${table.buyInRange}'),
                  ],
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: table.seatedPlayers < table.maxPlayers
                      ? () => _joinTable(table)
                      : null,
                  child: const Text('Join'),
                ),
              ],
            ),
            isThreeLine: false,
          ),
        );
      },
    );
  }

  Widget _buildGameTypeIcon(GameType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case GameType.holdem:
        iconData = Icons.grid_4x4;
        color = Colors.blue;
        break;
      case GameType.omaha:
        iconData = Icons.dashboard;
        color = Colors.green;
        break;
      case GameType.stud:
        iconData = Icons.view_column;
        color = Colors.orange;
        break;
      case GameType.razz:
        iconData = Icons.arrow_downward;
        color = Colors.red;
        break;
      case GameType.mixed:
        iconData = Icons.shuffle;
        color = Colors.purple;
        break;
    }

    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(iconData, color: color),
    );
  }
}
