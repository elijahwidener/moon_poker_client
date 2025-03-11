# Moon Poker Lobby System

## Overview

The Moon Poker Lobby System manages the creation, listing, and joining of poker tables. It separates the concerns of game discovery (lobby) from gameplay, allowing for scalable and maintainable architecture.

## Architecture

The lobby system uses a **hybrid architecture**:

- **REST API** for table management (create, list, join)
- **gRPC** for real-time game communication

This approach leverages the strengths of each technology:
- REST/JSON for CRUD operations and administrative features
- gRPC for high-performance, bidirectional streaming during gameplay

## Components

### Client-Side

1. **Models**
   - `GameTable`: Data model for poker tables

2. **UI**
   - `LobbyScreen`: Main screen for browsing and filtering tables
   - `CreateGameDialog`: Dialog for creating new games

3. **State Management**
   - `TablesProvider`: Manages table list state and operations
   - `FilteredTablesProvider`: Provides filtered view of tables

4. **Network**
   - `LobbyService`: Client for REST API communication
   - `NetworkController`: Client for gRPC game communication

### Server-Side

1. **HTTP API Server**
   - Handles lobby-related requests (GET/POST tables)
   - Manages table metadata in Redis

2. **gRPC Game Server**
   - Handles real-time game communication
   - Manages active game state

3. **Database**
   - **Redis**: Active table information
   - **PostgreSQL**: User accounts and historical data

## Development Setup

### Running the Mock Server

The mock server provides a simulated REST API for development:

```bash
dart server/mock_lobby_api.dart
```

This starts a local server on port 8081 with endpoints:
- `GET /api/lobby/tables` - List available tables
- `POST /api/lobby/tables` - Create a new table
- `POST /api/lobby/tables/{id}/join` - Join a table
- `POST /api/lobby/tables/{id}/leave` - Leave a table

### Feature Flags

The lobby system uses feature flags to toggle between mock and real implementations:

```dart
// Use mock data for testing
const bool USE_MOCK_DATA = true;
```

This allows for easy switching between mock and real backends during development.

## Data Flow

1. **Table Listing**
   - Client sends GET request to `/api/lobby/tables`
   - Server returns list of available tables
   - UI displays filterable table list

2. **Creating a Table**
   - User fills out create table form
   - Client sends POST request to `/api/lobby/tables`
   - Server creates table record and returns ID
   - Client navigates to game screen or refreshes lobby

3. **Joining a Table**
   - User clicks "Join" on a table
   - Client sends POST request to `/api/lobby/tables/{id}/join`
   - Server adds player to table
   - Client transitions to game screen with gRPC connection

## Future Enhancements

1. **Authentication Integration**
   - JWT-based authentication for API requests
   - Role-based permissions for table management

2. **Real-Time Table Updates**
   - Websocket or Server-Sent Events for live table updates
   - Push notifications for game invites

3. **Advanced Filtering**
   - Saved filters and favorites
   - Search by player name or table ID

4. **Admin Features**
   - Moderation tools
   - Analytics dashboard

## Design Decisions

### Why REST for Lobby?

1. **Simplicity**: Standard HTTP verbs map well to CRUD operations
2. **Compatibility**: Works with various backend technologies
3. **Caching**: HTTP caching for improved performance
4. **Tooling**: Rich ecosystem of development and debugging tools

### Why Hybrid Architecture?

1. **Best of Both Worlds**: Using the right tool for each job
2. **Performance**: gRPC where it matters most (real-time gameplay)
3. **Development Velocity**: Faster iteration on admin/lobby features
4. **Scalability**: Independent scaling of lobby vs. game servers