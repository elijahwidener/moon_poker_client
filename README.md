# MoonPoker Client

Flutter-based client application for MoonPoker, a real-time multiplayer poker platform.

## Prerequisites

* **Flutter SDK** (latest stable)
* **Dart SDK** (latest stable) 
* **Protocol Buffer Compiler**
* **MoonPoker Server** (for local development)

## Quick Start

```bash
# Clone repository 
git clone https://github.com/your-org/moon_poker_client.git
cd moon_poker_client

# Install dependencies
flutter pub get

# Generate protocol buffers
protoc --dart_out=grpc:lib/network/generated -I protos protos/*.proto

# Run in debug mode
flutter run
```

## Development Setup

### Install Flutter

#### macOS
```bash
brew install flutter
```

#### Linux
```bash
sudo snap install flutter --classic
```

#### Windows
Download from flutter.dev

### Install VS Code Extensions
* Flutter
* Dart
* Error Lens

### Configure Environment
```bash
flutter doctor
flutter pub get
```

## Project Structure
```
lib/
├── main.dart                 # Application entry
├── network/                  # Network layer
│   ├── network_controller.dart
│   └── generated/           # Protocol buffer generated code
├── ui/                      # UI components
│   ├── controllers/
│   ├── screens/
│   └── widgets/
└── models/                  # Data models
```

## Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Contributing

1. Create a feature branch:
```bash
git checkout -b feature/name
```

2. Commit changes:
```bash
git commit -m 'Add feature'
```

3. Push to remote:
```bash
git push origin feature/name
```

4. Create a Pull Request.

## Running with Server

1. Start MoonPoker server (default: `localhost:50051`).
2. Run the client:
```bash
flutter run
```

## License

This project is licensed under the MIT License.