import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/display_state.dart';
import '../../models/player_display.dart';
import '../../network/network_controller.dart';

part 'core_provider.g.dart';

// Connection States
enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class ConnectionState {
  final ConnectionStatus status;
  final String? error;
  final int clientId;

  const ConnectionState({
    required this.status,
    this.error,
    required this.clientId,
  });

  ConnectionState copyWith({
    ConnectionStatus? status,
    String? error,
    int? clientId,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      error: error ?? this.error,
      clientId: clientId ?? this.clientId,
    );
  }
}

// UI States that need to be tracked
class UIState {
  final bool showBettingControls;
  final bool showRaiseSlider;
  final String? errorMessage;
  final bool isLoading;

  const UIState({
    this.showBettingControls = false,
    this.showRaiseSlider = false,
    this.errorMessage,
    this.isLoading = false,
  });

  UIState copyWith({
    bool? showBettingControls,
    bool? showRaiseSlider,
    String? errorMessage,
    bool? isLoading,
  }) {
    return UIState(
      showBettingControls: showBettingControls ?? this.showBettingControls,
      showRaiseSlider: showRaiseSlider ?? this.showRaiseSlider,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Network Controller Provider
@riverpod
NetworkController networkController(Ref ref) {
  // Create and initialize network controller
  final controller = NetworkController();

  // Dispose when no longer needed
  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
}

// Game State Notifier
@riverpod
class GameState extends _$GameState {
  @override
  DisplayState build() {
    // Listen to network controller's state stream
    ref.listen(
        networkControllerProvider
            .select((controller) => controller.stateStream), (previous, next) {
      next.listen(
        (state) => state = state,
        onError: (error) {
          ref.read(uIStateNotifierProvider.notifier).setError(error.toString());
        },
      );
    });

    return DisplayState.empty();
  }

  // Methods to update game state
  void updateState(DisplayState newState) {
    state = newState;
  }
}

// Connection State Notifier
@riverpod
class ConnectionStateNotifier extends _$ConnectionStateNotifier {
  @override
  ConnectionState build() {
    // Initialize with disconnected state
    return ConnectionState(
      status: ConnectionStatus.disconnected,
      clientId: 0,
    );
  }

  Future<void> connect(int clientId) async {
    state = ConnectionState(
      status: ConnectionStatus.connecting,
      clientId: clientId,
    );

    try {
      await ref.read(networkControllerProvider).connect(clientId: clientId);
      state = ConnectionState(
        status: ConnectionStatus.connected,
        clientId: clientId,
      );
    } catch (e) {
      state = ConnectionState(
        status: ConnectionStatus.error,
        error: e.toString(),
        clientId: clientId,
      );
    }
  }

  void disconnect() {
    ref.read(networkControllerProvider).disconnect();
    state = ConnectionState(
      status: ConnectionStatus.disconnected,
      clientId: state.clientId,
    );
  }
}

// UI State Notifier
@riverpod
class UIStateNotifier extends _$UIStateNotifier {
  @override
  UIState build() {
    return const UIState();
  }

  void toggleBettingControls() {
    state = state.copyWith(
      showBettingControls: !state.showBettingControls,
      showRaiseSlider: false,
    );
  }

  void toggleRaiseSlider() {
    state = state.copyWith(
      showRaiseSlider: !state.showRaiseSlider,
    );
  }

  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }
}
