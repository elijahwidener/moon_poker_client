// mock_lobby_api.dart
//
// A simple HTTP server that mocks the lobby API for development and testing.
// This would be replaced with a real server implementation.
//
// To run: dart server/mock_lobby_api.dart
//
// Author: Elijah Widener Ferreira
// Date: 2025-03-10

import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';

void main() async {
  final port = 8081;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('Mock Lobby API server listening on port $port');

  final tables = <Map<String, dynamic>>[];
  final uuid = Uuid();

  // Seed with some initial tables
  tables.addAll([
    {
      'id': uuid.v4(),
      'name': 'Main Table',
      'gameType': 'holdem',
      'smallBlind': 1,
      'bigBlind': 2,
      'ante': 0,
      'minBuyIn': 100,
      'maxBuyIn': 200,
      'maxPlayers': 9,
      'seatedPlayers': 3,
      'isRunning': true,
    },
    {
      'id': uuid.v4(),
      'name': 'High Stakes',
      'gameType': 'holdem',
      'smallBlind': 5,
      'bigBlind': 10,
      'ante': 0,
      'minBuyIn': 500,
      'maxBuyIn': 1000,
      'maxPlayers': 6,
      'seatedPlayers': 2,
      'isRunning': true,
    },
    {
      'id': uuid.v4(),
      'name': 'Omaha Table',
      'gameType': 'omaha',
      'smallBlind': 2,
      'bigBlind': 5,
      'ante': 0,
      'minBuyIn': 200,
      'maxBuyIn': 500,
      'maxPlayers': 9,
      'seatedPlayers': 5,
      'isRunning': true,
    },
  ]);

  await for (final request in server) {
    try {
      // Enable CORS for development
      request.response.headers.add('Access-Control-Allow-Origin', '*');
      request.response.headers
          .add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
      request.response.headers
          .add('Access-Control-Allow-Headers', 'Content-Type, Authorization');

      // Handle OPTIONS requests (CORS preflight)
      if (request.method == 'OPTIONS') {
        request.response.statusCode = HttpStatus.ok;
        await request.response.close();
        continue;
      }

      // Parse the request path
      final path = request.uri.path;

      // Log the request
      print('${request.method} $path');

      // Route the request
      if (path == '/api/lobby/tables' && request.method == 'GET') {
        // Get tables with optional filtering
        final queryParams = request.uri.queryParameters;

        // Apply filters (simplified for mock)
        final filteredTables = tables.where((table) {
          // Game type filter
          if (queryParams.containsKey('gameType') &&
              table['gameType'] != queryParams['gameType']) {
            return false;
          }

          // Stakes filter
          if (queryParams.containsKey('minStakes') &&
              table['bigBlind'] < int.parse(queryParams['minStakes']!)) {
            return false;
          }
          if (queryParams.containsKey('maxStakes') &&
              table['bigBlind'] > int.parse(queryParams['maxStakes']!)) {
            return false;
          }

          // Empty tables filter
          if (queryParams['showEmpty'] == 'false' &&
              table['seatedPlayers'] == 0) {
            return false;
          }

          // Full tables filter
          if (queryParams['showFull'] == 'false' &&
              table['seatedPlayers'] == table['maxPlayers']) {
            return false;
          }

          // Running tables filter
          if (queryParams['showRunning'] == 'false' &&
              table['isRunning'] == true) {
            return false;
          }

          return true;
        }).toList();

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(filteredTables));
      } else if (path == '/api/lobby/tables' && request.method == 'POST') {
        // Create a new table
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body) as Map<String, dynamic>;

        // Generate a table ID
        final tableId = uuid.v4();

        // Create the table
        final newTable = {
          'id': tableId,
          'name': data['name'],
          'gameType': data['gameType'],
          'smallBlind': data['smallBlind'],
          'bigBlind': data['bigBlind'],
          'ante': data['ante'] ?? 0,
          'minBuyIn': data['minBuyIn'],
          'maxBuyIn': data['maxBuyIn'],
          'maxPlayers': data['maxPlayers'],
          'seatedPlayers': 1, // Creator is seated
          'isRunning': false, // Not running yet
        };

        tables.add(newTable);

        request.response
          ..statusCode = HttpStatus.created
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({
            'tableId': tableId,
            'success': true,
          }));
      } else if (path.startsWith('/api/lobby/tables/') &&
          path.endsWith('/join') &&
          request.method == 'POST') {
        // Join a table
        final tableId = path.split('/')[4]; // Extract table ID from path
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body) as Map<String, dynamic>;

        // Find the table
        final tableIndex = tables.indexWhere((table) => table['id'] == tableId);
        if (tableIndex == -1) {
          request.response
            ..statusCode = HttpStatus.notFound
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({
              'success': false,
              'message': 'Table not found',
            }));
        } else {
          // Check if table is full
          final table = tables[tableIndex];
          if (table['seatedPlayers'] >= table['maxPlayers']) {
            request.response
              ..statusCode = HttpStatus.badRequest
              ..headers.contentType = ContentType.json
              ..write(jsonEncode({
                'success': false,
                'message': 'Table is full',
              }));
          } else {
            // Join the table
            table['seatedPlayers'] = table['seatedPlayers'] + 1;

            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.json
              ..write(jsonEncode({
                'success': true,
              }));
          }
        }
      } else if (path.startsWith('/api/lobby/tables/') &&
          path.endsWith('/leave') &&
          request.method == 'POST') {
        // Leave a table
        final tableId = path.split('/')[4]; // Extract table ID from path
        final body = await utf8.decoder.bind(request).join();
        final data = jsonDecode(body) as Map<String, dynamic>;

        // Find the table
        final tableIndex = tables.indexWhere((table) => table['id'] == tableId);
        if (tableIndex == -1) {
          request.response
            ..statusCode = HttpStatus.notFound
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({
              'success': false,
              'message': 'Table not found',
            }));
        } else {
          // Leave the table
          final table = tables[tableIndex];
          if (table['seatedPlayers'] > 0) {
            table['seatedPlayers'] = table['seatedPlayers'] - 1;
          }

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(jsonEncode({
              'success': true,
            }));
        }
      } else {
        // Route not found
        request.response
          ..statusCode = HttpStatus.notFound
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({
            'error': 'Route not found',
            'path': path,
            'method': request.method,
          }));
      }
    } catch (e, stackTrace) {
      print('Error handling request: $e');
      print(stackTrace);

      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          'error': 'Internal server error',
          'message': e.toString(),
        }));
    } finally {
      await request.response.close();
    }
  }
}
