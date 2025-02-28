// network_controller.dart
// This file contains the NetworkController class which handles network operations for the Moon Poker Client.
library;

import 'dart:async';
import 'package:fixnum/src/int64.dart';
import 'package:http/http.dart' as http;
import 'package:grpc/grpc_web.dart';
import 'package:grpc/grpc.dart';
import '../generated/game_service.pbgrpc.dart';
import '../models/display_state.dart';
import 'package:rxdart/rxdart.dart';

/// Manages network communications with game server
class NetworkController {
  late final GrpcWebClientChannel _channel;
  late final GameServiceClient _stub;
  StreamSubscription? _responseSubscription;
  final _stateController = BehaviorSubject<DisplayState>();
  final _errorController = BehaviorSubject<String>();
  bool _isConnected = false;
  int _clientId = 0;

  // Polling related members
  Timer? _pollingTimer;
  int _lastSequenceNumber = 0;
  bool _isPolling = false;
  static const Duration _pollingInterval = Duration(milliseconds: 500);

  /// Public stream for UI to listen to
  Stream<DisplayState> get stateStream => _stateController.stream;
  Stream<String> get errorStream => _errorController.stream;
  bool get isConnected => _isConnected;

  /// Establish connection to server
  Future<void> connect({
    required int clientId,
    String host = 'localhost',
    int port = 8080,
  }) async {
    if (_isConnected) {
      await disconnect();
    }

    try {
      _clientId = clientId;

      _channel = GrpcWebClientChannel.xhr(Uri(
        scheme: 'http',
        host: host,
        port: port,
      ));

      _stub = GameServiceClient(_channel);

      // First authenticate
      final authRequest = ConnectRequest()..playerId = clientId;
      final authResponse = await _stub.authenticate(authRequest);

      if (!authResponse.success) {
        throw Exception('Authentication failed');
      }

      _isConnected = true;
      print('Successfully authenticated with server');

      // Start polling for game state updates
      _startPolling();
    } catch (e) {
      _handleError('Failed to connect: $e');
      rethrow;
    }
  }

  /// disconnects from server
  Future<void> disconnect() async {
    _isConnected = false;
    _stopPolling();
    await _channel.shutdown();
  }

  /// Sends a command to the server
  Future<void> sendCommand(GameCommand command) async {
    if (!_isConnected) {
      throw StateError('Not connected to server');
    }

    try {
      final response = await _stub.sendCommand(command);
      if (!response.success) {
        throw Exception("Server rejected command");
      }
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
      case CommandType.PAUSE_UNPAUSE:
        // No additional data needed for this command
        break;
      default:
        break;
    }
    return command;
  }

  /// Start polling for game state updates
  void _startPolling() {
    if (_isPolling) return;

    _isPolling = true;
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _pollGameState());
    print('Started polling for game state updates');
  }

  /// Stop polling for game state
  void _stopPolling() {
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    print('Stopped polling for game state updates');
  }

  /// Poll the server for game state
  Future<void> _pollGameState() async {
    if (!_isConnected || !_isPolling) return;

    try {
      // Create state request with last known sequence number
      final request = StateRequest()
        ..playerId = _clientId
        ..lastSequenceNumber = _lastSequenceNumber;

      // Get game state
      final update = await _stub.getGameState(request);

      // Only process update if sequence number changed
      if (update.sequenceNumber > _lastSequenceNumber) {
        print('Received new game state: sequence ${update.sequenceNumber}');
        _lastSequenceNumber = update.sequenceNumber;
        _handleServerUpdate(update);
      }
    } catch (e) {
      _handleError('Polling error: $e');
      // Don't stop polling on errors, just log them
    }
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
    _stopPolling();
    _stateController.close();
    _errorController.close();
    _channel.shutdown();
  }
}
