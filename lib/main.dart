import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'models/display_state.dart';
import 'network/network_controller.dart';
import 'generated/game_service.pb.dart';

void main() {
  // Initialize logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(const MoonPokerApp());
}

class MoonPokerApp extends StatelessWidget {
  const MoonPokerApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moon Poker',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NetworkTestScreen(title: 'Moon Poker Networking Test'),
    );
  }
}

class NetworkTestScreen extends StatefulWidget {
  const NetworkTestScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<NetworkTestScreen> createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  final _logger = Logger('NetworkTestScreen');
  final _networkController = NetworkController();
  final _idController = TextEditingController();
  String _connectionStatus = 'Disconnected';
  String _lastUpdate = 'No updates';
  DisplayState _currentState = DisplayState.empty();

  @override
  void initState() {
    super.initState();
    _setupNetworkListeners();
  }

  void _setupNetworkListeners() {
    // Listen for state updates
    _networkController.stateStream.listen(
      (state) {
        setState(() {
          _currentState = state;
          _lastUpdate =
              'Received state update: ${state.isGameActive ? 'Game Active' : 'Game Inactive'},'
              'Players: ${state.players.where((p) => p.playerId != 0).length}';
        });
        _logger.info('ReceivedS State Update: $_currentState');
      },
      onError: (error) {
        _logger.severe('State Stream Error: $error');
      },
    );

    // Listen for error messages
    _networkController.errorStream.listen(
      (error) {
        setState(() {
          _lastUpdate = 'Error: $error';
        });
        _logger.severe('Network Error: $error');
      },
    );
  }

  Future<void> _connect() async {
    try {
      final clientId = int.parse(_idController.text);
      setState(() => _connectionStatus = 'Connecting...');
      await _networkController.connect(clientId: clientId);
      setState(() => _connectionStatus = 'Connected');
      _logger.info('Connected to server');
    } catch (e) {
      setState(() => _connectionStatus = 'Connection Failed');
      _logger.severe('Connection Error: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      setState(() => _connectionStatus = 'Disconnecting...');
      await _networkController.disconnect();
      setState(() => _connectionStatus = 'Disconnected');
      _logger.info('Disconnected from server');
    } catch (e) {
      _logger.severe('Disconnection Error: $e');
    }
  }

  Future<void> _sendTestCommand() async {
    if (!_networkController.isConnected) {
      _logger.warning('Not connected to server');
      return;
    }
    try {
      final command = _networkController.createCommand(
        type: CommandType.JOIN,
        playerId: 1,
        joinStack: 1000,
      );
      await _networkController.sendCommand(command);
      _logger.info('Sent test command');
    } catch (e) {
      _logger.severe('Failed to send command: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Enter User ID (simulating account)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Text('Status: $_connectionStatus',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Last Update: $_lastUpdate',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _networkController.isConnected ? null : _connect,
                  child: const Text('Connect'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _networkController.isConnected ? _sendTestCommand : null,
                  child: const Text('Send Test Command'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _networkController.isConnected ? _disconnect : null,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Game State:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
                'Active Players: ${_currentState.players.where((p) => p.playerId != 0).length}'),
            Text('Pot: ${_currentState.potSize}'),
            Text('Current Bet: ${_currentState.currentBet}'),
            Text('Game Active: ${_currentState.isGameActive}'),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _networkController.dispose();
    super.dispose();
  }
}
