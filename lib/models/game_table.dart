// game_table.dart
//
// Represents a poker game table in the lobby.
//
// Author: Elijah Widener Ferreira
// Date: 2025-03-10

class GameTable {
  final String id;
  final String name;
  final GameType gameType;
  final int smallBlind;
  final int bigBlind;
  final int ante;
  final int minBuyIn;
  final int maxBuyIn;
  final int maxPlayers;
  final int seatedPlayers;
  final bool isRunning;

  const GameTable({
    required this.id,
    required this.name,
    required this.gameType,
    required this.smallBlind,
    required this.bigBlind,
    this.ante = 0,
    required this.minBuyIn,
    required this.maxBuyIn,
    required this.maxPlayers,
    required this.seatedPlayers,
    required this.isRunning,
  });

  // Returns formatted stakes string (e.g., "$1/$2")
  String get stakesString => '\$$smallBlind/\$$bigBlind';

  // Returns formatted buy-in range (e.g., "$100-$200")
  String get buyInRange => '\$$minBuyIn-\$$maxBuyIn';

  // Returns player count display (e.g., "3/9")
  String get playerCount => '$seatedPlayers/$maxPlayers';

  // Factory to create from server JSON response
  factory GameTable.fromJson(Map<String, dynamic> json) {
    return GameTable(
      id: json['id'] as String,
      name: json['name'] as String,
      gameType: _parseGameType(json['gameType']),
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

  // Helper method to parse gameType from string
  static GameType _parseGameType(String type) {
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

  // Convert to JSON for sending to server
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gameType': gameType.name,
      'smallBlind': smallBlind,
      'bigBlind': bigBlind,
      'ante': ante,
      'minBuyIn': minBuyIn,
      'maxBuyIn': maxBuyIn,
      'maxPlayers': maxPlayers,
      'seatedPlayers': seatedPlayers,
      'isRunning': isRunning,
    };
  }

  // Factory for creating mock data
  static List<GameTable> getMockTables() {
    return [
      GameTable(
        id: '1',
        name: 'Main Table',
        gameType: GameType.holdem,
        smallBlind: 1,
        bigBlind: 2,
        minBuyIn: 100,
        maxBuyIn: 200,
        maxPlayers: 9,
        seatedPlayers: 3,
        isRunning: true,
      ),
      GameTable(
        id: '2',
        name: 'High Stakes',
        gameType: GameType.holdem,
        smallBlind: 5,
        bigBlind: 10,
        minBuyIn: 500,
        maxBuyIn: 1000,
        maxPlayers: 6,
        seatedPlayers: 2,
        isRunning: true,
      ),
      GameTable(
        id: '3',
        name: 'Omaha Table',
        gameType: GameType.omaha,
        smallBlind: 2,
        bigBlind: 5,
        minBuyIn: 200,
        maxBuyIn: 500,
        maxPlayers: 9,
        seatedPlayers: 5,
        isRunning: true,
      ),
      GameTable(
        id: '4',
        name: 'Stud Table',
        gameType: GameType.stud,
        smallBlind: 1,
        bigBlind: 2,
        ante: 1,
        minBuyIn: 100,
        maxBuyIn: 300,
        maxPlayers: 8,
        seatedPlayers: 0,
        isRunning: false,
      ),
      GameTable(
        id: '5',
        name: 'Mixed Game',
        gameType: GameType.mixed,
        smallBlind: 2,
        bigBlind: 4,
        minBuyIn: 200,
        maxBuyIn: 400,
        maxPlayers: 6,
        seatedPlayers: 4,
        isRunning: true,
      ),
    ];
  }
}

// Enum for game types
enum GameType {
  holdem,
  omaha,
  stud,
  razz,
  mixed,
}

// Extension to provide display names for game types
extension GameTypeExtension on GameType {
  String get displayName {
    switch (this) {
      case GameType.holdem:
        return 'No-Limit Hold\'em';
      case GameType.omaha:
        return 'Pot-Limit Omaha';
      case GameType.stud:
        return 'Seven-Card Stud';
      case GameType.razz:
        return 'Razz';
      case GameType.mixed:
        return 'Mixed Games';
    }
  }
}
