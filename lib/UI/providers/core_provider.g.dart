// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$networkControllerHash() => r'2cc12ef3000eb1ffa6b3014819340bbe65d45093';

/// See also [networkController].
@ProviderFor(networkController)
final networkControllerProvider = Provider<NetworkController>.internal(
  networkController,
  name: r'networkControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$networkControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NetworkControllerRef = ProviderRef<NetworkController>;
String _$gameStateHash() => r'21f8bb2e884cb18b1e7f2c3522ee7247c20b5da4';

/// See also [GameState].
@ProviderFor(GameState)
final gameStateProvider =
    AutoDisposeNotifierProvider<GameState, DisplayState>.internal(
  GameState.new,
  name: r'gameStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$gameStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GameState = AutoDisposeNotifier<DisplayState>;
String _$connectionStateNotifierHash() =>
    r'ced9a919c72b68ea8f0b9faad6fabd3219789143';

/// See also [ConnectionStateNotifier].
@ProviderFor(ConnectionStateNotifier)
final connectionStateNotifierProvider = AutoDisposeNotifierProvider<
    ConnectionStateNotifier, ConnectionState>.internal(
  ConnectionStateNotifier.new,
  name: r'connectionStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$connectionStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ConnectionStateNotifier = AutoDisposeNotifier<ConnectionState>;
String _$uIStateNotifierHash() => r'2c788dcef37029401ea6628eb56f7caadaf0effa';

/// See also [UIStateNotifier].
@ProviderFor(UIStateNotifier)
final uIStateNotifierProvider =
    AutoDisposeNotifierProvider<UIStateNotifier, UIState>.internal(
  UIStateNotifier.new,
  name: r'uIStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uIStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UIStateNotifier = AutoDisposeNotifier<UIState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
