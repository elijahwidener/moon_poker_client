// Updated NetworkController with improved polling and error handling
import 'dart:async';
import 'package:fixnum/src/int64.dart';
import 'package:grpc/grpc_web.dart';
import '../generated/game_service.pbgrpc.dart';
import '../models/display_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:logging/logging.dart';

/// Manages network communications with game server
class NetworkController {
  late GrpcWebClientChannel _channel;
  late GameServiceClient _stub;
  final _stateController = BehaviorSubject<DisplayState>();
  final _errorController = BehaviorSubject<String>();
  bool _isConnected = false;
  int _clientId = 0;
  int _reconnectionAttempts = 0;
  static const int _maxReconnectionAttempts = 3;

  // Polling related members
  Timer? _pollingTimer;
  int _lastSequenceNumber = 0;
  bool _isPolling = false;
  int _consecutiveErrors = 0;
  static const Duration _pollingInterval =
      Duration(milliseconds: 3000); // set long for testing
  static const Duration _reconnectInterval = Duration(seconds: 3);
  static const int _maxConsecutiveErrors = 3;

  // Logger
  final _log = Logger('NetworkController');

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
      _log.info(
          'Connecting to server at $host:$port with client ID: $clientId');

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
        final errorMsg = 'Authentication failed: ${authResponse.errorMessage}';
        _log.severe(errorMsg);
        throw Exception(errorMsg);
      }

      _isConnected = true;
      _consecutiveErrors = 0;
      _log.info('Successfully authenticated with server');

      // Start polling for game state updates
      _startPolling();
    } catch (e) {
      final errorMsg = 'Failed to connect: $e';
      _handleError(errorMsg);
      rethrow;
    }
  }

  /// Disconnects from server
  Future<void> disconnect() async {
    if (!_isConnected) return;

    _log.info('Disconnecting from server...');
    _isConnected = false;
    _stopPolling();

    try {
      await _channel.shutdown();
      _log.info('Disconnected from server');
    } catch (e) {
      _log.warning('Error during disconnect: $e');
    }
  }

  /// Sends a command to the server
  Future<void> sendCommand(GameCommand command) async {
    if (!_isConnected) {
      throw StateError('Not connected to server');
    }

    try {
      _log.info('Sending command: ${command.type}');
      final response = await _stub.sendCommand(command);

      if (!response.success) {
        final errorMsg = "Server rejected command: ${response.message}";
        _log.warning(errorMsg);
        throw Exception(errorMsg);
      }

      _log.info('Command successfully processed');

      // Force an immediate state poll to get updated state
      _pollGameState();
    } catch (e) {
      final errorMsg = 'Failed to send command: $e';
      _handleError(errorMsg);
      rethrow;
    }
  }

  /// Creates a game command to send to the server
  GameCommand createCommand({
    required CommandType type,
    required int playerId,
    int? raiseAmount,
    int? joinStack,
  }) {
    final command = GameCommand()
      ..type = type
      ..playerId = playerId
      ..sequenceNumber = _lastSequenceNumber;

    switch (type) {
      case CommandType.RAISE:
        if (raiseAmount != null) {
          command.raise = RaiseData()..amount = Int64(raiseAmount);
        }
        break;
      case CommandType.JOIN:
        if (joinStack != null) {
          command.join = JoinData()..stack = Int64(joinStack);
        }
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
    _log.info('Started polling for game state updates');
  }

  /// Stop polling for game state
  void _stopPolling() {
    _isPolling = false;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _log.info('Stopped polling for game state updates');
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

      // Reset consecutive errors counter on success
      _consecutiveErrors = 0;

      // Only process update if sequence number changed
      if (update.sequenceNumber > _lastSequenceNumber) {
        _log.info('Received new game state: sequence ${update.sequenceNumber}');
        _lastSequenceNumber = update.sequenceNumber;
        _handleServerUpdate(update);
      }
    } catch (e) {
      _consecutiveErrors++;
      _log.warning(
          'Polling error: $e (consecutive errors: $_consecutiveErrors)');

      if (_consecutiveErrors >= _maxConsecutiveErrors) {
        _handleReconnection();
      }
    }
  }

  /// Handle reconnection after multiple consecutive errors
  void _handleReconnection() {
    if (_reconnectionAttempts >= _maxReconnectionAttempts) {
      _log.warning('Max reconnection attempts reached. Giving up.');
      _errorController.add(
          'Unable to reconnect after $_maxReconnectionAttempts attempts. Please try again later.');
      _reconnectionAttempts = 0; // Reset for next time
      return;
    }

    _reconnectionAttempts++;
    _log.info(
        'Attempting to reconnect... (Attempt $_reconnectionAttempts of $_maxReconnectionAttempts)');
    _stopPolling();

    // Notify UI about reconnection attempt
    _errorController.add(
        'Connection lost. Attempting to reconnect... (${_reconnectionAttempts}/${_maxReconnectionAttempts})');

    // Attempt reconnection after delay
    Future.delayed(_reconnectInterval, () async {
      try {
        await connect(clientId: _clientId);
        _errorController.add('Reconnected successfully');
        _reconnectionAttempts = 0; // Reset on success
      } catch (e) {
        _errorController.add('Reconnection failed: $e');
        // Try again (with the limit check at the beginning)
        _handleReconnection();
      }
    });
  }

  /// Handle incoming state updates from the server
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

  /// Handle errors from the server connection
  void _handleError(dynamic error) {
    final errorMsg = error.toString();
    _log.severe('Network error: $errorMsg');
    _errorController.add(errorMsg);
  }

  /// Cleanup resources
  void dispose() {
    _stopPolling();
    _stateController.close();
    _errorController.close();

    try {
      if (_isConnected) {
        _channel.shutdown();
      }
    } catch (e) {
      _log.warning('Error during dispose: $e');
    }

    _log.info('NetworkController disposed');
  }
}
