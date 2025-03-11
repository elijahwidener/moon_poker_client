// lobby_provider.dart
//
// Provides state management for the lobby screen.
//
// Author: Elijah Widener Ferreira
// Date: 2025-03-10

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../models/game_table.dart';

// State class for tables
class TablesState {
  final List<GameTable> tables;
  final bool isLoading;
  final String? errorMessage;

  TablesState({
    required this.tables,
    this.isLoading = false,
    this.errorMessage,
  });

  TablesState copyWith({
    List<GameTable>? tables,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TablesState(
      tables: tables ?? this.tables,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// Provider that manages table state
final tablesProvider =
    StateNotifierProvider<TablesNotifier, TablesState>((ref) {
  return TablesNotifier();
});

// Notifier class that handles table operations
class TablesNotifier extends StateNotifier<TablesState> {
  TablesNotifier() : super(TablesState(tables: []));

  // Load tables from server or mock data
  Future<void> fetchTables() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, use mock data
      final mockTables = GameTable.getMockTables();

      state = state.copyWith(
        tables: mockTables,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load tables: $e',
      );
    }
  }

  // Create a new table
  Future<String?> createTable({
    required String name,
    required GameType gameType,
    required int smallBlind,
    required int bigBlind,
    required int ante,
    required int minBuyIn,
    required int maxBuyIn,
    required int maxPlayers,
    required int clientId,
    required int buyInAmount,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate a mock table ID
      final tableId = 'table_${DateTime.now().millisecondsSinceEpoch}';

      // Add the new table to our state
      final newTable = GameTable(
        id: tableId,
        name: name,
        gameType: gameType,
        smallBlind: smallBlind,
        bigBlind: bigBlind,
        ante: ante,
        minBuyIn: minBuyIn,
        maxBuyIn: maxBuyIn,
        maxPlayers: maxPlayers,
        seatedPlayers: 1, // Creator is seated
        isRunning: false, // Not running yet
      );

      state = state.copyWith(
        tables: [...state.tables, newTable],
        isLoading: false,
      );

      return tableId;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to create table: $e',
      );
      return null;
    }
  }

  // Join a table
  Future<bool> joinTable({
    required String tableId,
    required int clientId,
    required int buyInAmount,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Update the table in our state
      final updatedTables = state.tables.map((table) {
        if (table.id == tableId) {
          return GameTable(
            id: table.id,
            name: table.name,
            gameType: table.gameType,
            smallBlind: table.smallBlind,
            bigBlind: table.bigBlind,
            ante: table.ante,
            minBuyIn: table.minBuyIn,
            maxBuyIn: table.maxBuyIn,
            maxPlayers: table.maxPlayers,
            seatedPlayers: table.seatedPlayers + 1,
            isRunning: table.isRunning,
          );
        }
        return table;
      }).toList();

      state = state.copyWith(
        tables: updatedTables,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to join table: $e',
      );
      return false;
    }
  }
}

// Provider that filters tables based on criteria
final filteredTablesProvider =
    Provider.family<List<GameTable>, Map<String, dynamic>>(
  (ref, filters) {
    final tablesState = ref.watch(tablesProvider);
    final selectedGameType = filters['gameType'] as GameType?;
    final stakesRange = filters['stakesRange'] as RangeValues;
    final showEmptyTables = filters['showEmptyTables'] as bool;
    final showFullTables = filters['showFullTables'] as bool;
    final showRunningTables = filters['showRunningTables'] as bool;

    return tablesState.tables.where((table) {
      // Game type filter
      if (selectedGameType != null && table.gameType != selectedGameType) {
        return false;
      }

      // Stakes filter
      if (table.bigBlind < stakesRange.start ||
          table.bigBlind > stakesRange.end) {
        return false;
      }

      // Empty tables filter
      if (!showEmptyTables && table.seatedPlayers == 0) {
        return false;
      }

      // Full tables filter
      if (!showFullTables && table.seatedPlayers == table.maxPlayers) {
        return false;
      }

      // Running tables filter
      if (!showRunningTables && table.isRunning) {
        return false;
      }

      return true;
    }).toList();
  },
);
