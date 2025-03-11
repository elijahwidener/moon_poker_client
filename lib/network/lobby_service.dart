// lobby_service.dart
//
// REST API service for lobby operations.
//
// Author: Elijah Widener Ferreira
// Date: 2025-03-10

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import '../models/game_table.dart';

/// Service for interacting with the lobby API
class LobbyService {
  final String baseUrl;
  final http.Client _client = http.Client();
  final _log = Logger('LobbyService');

  // Authentication token for API requests
  String? _authToken;

  LobbyService({
    this.baseUrl = 'http://localhost:8081/api/lobby', // Default API URL
  });

  /// Set the authentication token for API requests
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Get all available tables
  Future<List<GameTable>> getTables({
    GameType? gameType,
    int? minStakes,
    int? maxStakes,
    bool? showFull,
    bool? showEmpty,
    bool? showRunning,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (gameType != null) queryParams['gameType'] = gameType.name;
      if (minStakes != null) queryParams['minStakes'] = minStakes.toString();
      if (maxStakes != null) queryParams['maxStakes'] = maxStakes.toString();
      if (showFull != null) queryParams['showFull'] = showFull.toString();
      if (showEmpty != null) queryParams['showEmpty'] = showEmpty.toString();
      if (showRunning != null)
        queryParams['showRunning'] = showRunning.toString();

      // Build request URL
      final uri =
          Uri.parse('$baseUrl/tables').replace(queryParameters: queryParams);

      // Make API request
      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        final jsonList = jsonDecode(response.body) as List;
        return jsonList.map((json) => _parseGameTable(json)).toList();
      } else {
        _handleErrorResponse(response);
        return []; // Return empty list on error
      }
    } catch (e) {
      _log.severe('Error fetching tables: $e');
      throw Exception('Failed to load tables: $e');
    }
  }

  /// Create a new game table
  Future<String> createTable({
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
      // Build request body
      final body = jsonEncode({
        'name': name,
        'gameType': gameType.name,
        'smallBlind': smallBlind,
        'bigBlind': bigBlind,
        'ante': ante,
        'minBuyIn': minBuyIn,
        'maxBuyIn': maxBuyIn,
        'maxPlayers': maxPlayers,
        'creatorId': clientId,
        'creatorBuyIn': buyInAmount,
      });

      // Make API request
      final response = await _client.post(
        Uri.parse('$baseUrl/tables'),
        headers: _getHeaders(),
        body: body,
      );

      if (response.statusCode == 201) {
        // Parse response to get table ID
        final responseData = jsonDecode(response.body);
        return responseData['tableId'] as String;
      } else {
        _handleErrorResponse(response);
        throw Exception('Failed to create table');
      }
    } catch (e) {
      _log.severe('Error creating table: $e');
      throw Exception('Failed to create table: $e');
    }
  }

  /// Join an existing table
  Future<bool> joinTable({
    required String tableId,
    required int clientId,
    required int buyInAmount,
  }) async {
    try {
      // Build request body
      final body = jsonEncode({
        'playerId': clientId,
        'buyInAmount': buyInAmount,
      });

      // Make API request
      final response = await _client.post(
        Uri.parse('$baseUrl/tables/$tableId/join'),
        headers: _getHeaders(),
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        _handleErrorResponse(response);
        return false;
      }
    } catch (e) {
      _log.severe('Error joining table: $e');
      throw Exception('Failed to join table: $e');
    }
  }

  /// Leave a table
  Future<bool> leaveTable({
    required String tableId,
    required int clientId,
  }) async {
    try {
      // Make API request
      final response = await _client.post(
        Uri.parse('$baseUrl/tables/$tableId/leave'),
        headers: _getHeaders(),
        body: jsonEncode({'playerId': clientId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        _handleErrorResponse(response);
        return false;
      }
    } catch (e) {
      _log.severe('Error leaving table: $e');
      throw Exception('Failed to leave table: $e');
    }
  }

  /// Get HTTP headers for API requests
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Handle error responses from the API
  void _handleErrorResponse(http.Response response) {
    _log.warning('API error: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 401) {
      throw Exception('Authentication required');
    } else if (response.statusCode == 403) {
      throw Exception('Permission denied');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Unknown error');
      } catch (e) {
        throw Exception('Server error: ${response.statusCode}');
      }
    }
  }

  /// Parse a JSON object into a GameTable
  GameTable _parseGameTable(Map<String, dynamic> json) {
    return GameTable(
      id: json['id'] as String,
      name: json['name'] as String,
      gameType: _parseGameType(json['gameType'] as String),
      smallBlind: json['smallBlind'] as int,
      bigBlind: json['bigBlind'] as int,
      ante: json['ante'] as int? ?? 0,
      minBuyIn: json['minBuyIn'] as int,
      maxBuyIn: json['maxBuyIn'] as int,
      maxPlayers: json['maxPlayers'] as int,
      seatedPlayers: json['seatedPlayers'] as int,
      isRunning: json['isRunning'] as bool,
    );
  }

  /// Parse a string into a GameType
  GameType _parseGameType(String type) {
    switch (type.toLowerCase()) {
      case 'holdem':
        return GameType.holdem;
      case 'omaha':
        return GameType.omaha;
      case 'stud':
        return GameType.stud;
      case 'razz':
        return GameType.razz;
      case 'mixed':
        return GameType.mixed;
      default:
        return GameType.holdem;
    }
  }

  /// Cleanup resources
  void dispose() {
    _client.close();
  }
}
