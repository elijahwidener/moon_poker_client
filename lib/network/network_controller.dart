// network_controller.dart
// This file contains the NetworkController class which handles network operations for the Moon Poker Client.

class NetworkController {
  // Single gRPC channel and stub for game service
  final channel = ClientChannel('localhost',
      port: 50051,
      options:
          const ChannelOptions(credentials: ChannelCredentials.insecure()));
  late final GameServiceClient stub;

  // Stream controller for game state updates
  final _stateController = StreamController<DisplayState>.broadcast();
  Stream<DisplayState> get stateStream => _stateController.stream;

  // Establish connection and start listening
  Future<void> connect() async {
    stub = GameServiceClient(channel);
    // TODO: Setup bidirectional stream
    // TODO: Error handling for connection failures
  }

  // Clean shutdown
  Future<void> disconnect() async {
    await channel.shutdown();
    await _stateController.close();
  }

  // Send game commands to server
  Future<void> sendCommand(GameCommand command) async {
    // TODO: Implement command serialization and sending
  }

  // Helper to create commands (similar to C++ command handler)
  GameCommand createCommand(
    CommandType type, {
    int? playerId,
    // Additional parameters as needed
  }) {
    // TODO: Implement command creation logic
  }
}
