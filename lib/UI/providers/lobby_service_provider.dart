// lobby_service_provider.dart
//
// Provider for the lobby service.
//
// Author: Elijah Widener Ferreira
// Date: 2025-03-10

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../network/lobby_service.dart';
part 'lobby_service_provider.g.dart';

// Provider for the lobby service
@Riverpod(keepAlive: true)
LobbyService lobbyService(LobbyServiceRef ref) {
  // Create the service with the base URL from environment config
  // For now, use a local default
  final service = LobbyService(
    baseUrl: 'http://localhost:8081/api/lobby',
  );

  // Dispose the service when the provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
}
