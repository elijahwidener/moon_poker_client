// network_controller.dart
// This file contains the NetworkController class which handles network operations for the Moon Poker Client.
library;

import 'dart:async';
import 'package:fixnum/src/int64.dart';
import 'package:grpc/grpc.dart';
import '../generated/game_service.pbgrpc.dart';
import '../models/display_state.dart';

/// Manages network communications with game server
class NetworkController {
  late final ClientChannel _channel;
  late final GameServiceClient _stub;
  late final StreamController<DisplayState> _stateController;
  late final StreamController<String> _errorController;

  late final StreamController<GameCommand> _commandController;
  late final ResponseStream<GameUpdate> _responseStream;
  StreamSubscription? _responseSubscription;
  bool _isConnected = false;

  /// Public stream for UI to listen to
  Stream<DisplayState> get stateStream => _stateController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isConnected => _isConnected;

  NetworkController() {
    _stateController = StreamController<DisplayState>.broadcast();
    _errorController = StreamController<String>.broadcast();
  }

  /// Establish connection to server
  Future<void> connect({
    String host = 'localhost',
    int port = 50051,
  }) async {
    if (_isConnected) {
      await disconnect();
    }

    try {
      // Create channel and stub
      _channel = ClientChannel(
        host,
        port: port,
        options: const ChannelOptions(
          credentials: ChannelCredentials.insecure(),
        ),
      );
      _stub = GameServiceClient(_channel);

      // Start bidirectional stream
      _commandController = StreamController<GameCommand>();
      _responseStream = _stub.connect(_commandController.stream);

      // Listen for server updates
      _responseSubscription = _responseStream.listen(
        _handleServerUpdate,
        onError: _handleError,
        onDone: () {
          _isConnected = false;
          _handleError('Server connection closed');
        },
      );

      _isConnected = true;
    } catch (e) {
      _handleError('Failed to connect to server: $e');
      rethrow;
    }
  }

  /// disconnects from server
  Future<void> disconnect() async {
    _isConnected = false;
    await _responseSubscription?.cancel();
    await _commandController.close();
    await _channel.shutdown();
  }

  /// Sends a command to the server
  Future<void> sendCommand(GameCommand command) async {
    if (!_isConnected) {
      throw StateError('Not connected to server');
    }

    try {
      _commandController.add(command);
    } catch (e) {
      _handleError('Failed to send command: $e');
      rethrow;
    }
  }

  GameCommand createCommand({
    required CommandType type,
    required int playerId,
    int? raiseAmount,
    int? joinStack,
  }) {
    final command = GameCommand()
      ..type = type
      ..playerId = playerId
      ..sequenceNumber = DateTime.now().millisecondsSinceEpoch;

    switch (type) {
      case CommandType.RAISE:
        if (raiseAmount != null) {
          command.raise = RaiseData()..amount = raiseAmount as Int64;
        }
        break;
      case CommandType.JOIN:
        if (joinStack != null) {
          command.join = JoinData()..stack = joinStack as Int64;
        }
        break;
      default:
        break;
    }
    return command;
  }

  /// Handled incoming state updates from the server
  void _handleServerUpdate(GameUpdate update) {
    if (update.hasError()) {
      _errorController.add(update.error);
      return;
    }
    if (update.hasState()) {
      final newState = DisplayState.fromProto(update.state);
      _stateController.add(newState);
    }
  }

  /// Handles errors from the server connection
  void _handleError(dynamic error) {
    _errorController.add(error.toString());
    // TODO Could add reconnection logic here or UI feedback/other error handling
  }

  /// Cleanup resources
  void dispose() {
    _responseSubscription?.cancel();
    _stateController.close();
    _errorController.close();
    _commandController.close();
    _channel.shutdown();
  }
}
