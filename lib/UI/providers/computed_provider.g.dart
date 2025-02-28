// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'computed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isActivePlayerHash() => r'f420fb2e12ea18f50c8c6b68a937dc1e3a8a5e92';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [isActivePlayer].
@ProviderFor(isActivePlayer)
const isActivePlayerProvider = IsActivePlayerFamily();

/// See also [isActivePlayer].
class IsActivePlayerFamily extends Family<bool> {
  /// See also [isActivePlayer].
  const IsActivePlayerFamily();

  /// See also [isActivePlayer].
  IsActivePlayerProvider call(
    int playerId,
  ) {
    return IsActivePlayerProvider(
      playerId,
    );
  }

  @override
  IsActivePlayerProvider getProviderOverride(
    covariant IsActivePlayerProvider provider,
  ) {
    return call(
      provider.playerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isActivePlayerProvider';
}

/// See also [isActivePlayer].
class IsActivePlayerProvider extends AutoDisposeProvider<bool> {
  /// See also [isActivePlayer].
  IsActivePlayerProvider(
    int playerId,
  ) : this._internal(
          (ref) => isActivePlayer(
            ref as IsActivePlayerRef,
            playerId,
          ),
          from: isActivePlayerProvider,
          name: r'isActivePlayerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isActivePlayerHash,
          dependencies: IsActivePlayerFamily._dependencies,
          allTransitiveDependencies:
              IsActivePlayerFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  IsActivePlayerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.playerId,
  }) : super.internal();

  final int playerId;

  @override
  Override overrideWith(
    bool Function(IsActivePlayerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsActivePlayerProvider._internal(
        (ref) => create(ref as IsActivePlayerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        playerId: playerId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsActivePlayerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsActivePlayerProvider && other.playerId == playerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, playerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsActivePlayerRef on AutoDisposeProviderRef<bool> {
  /// The parameter `playerId` of this provider.
  int get playerId;
}

class _IsActivePlayerProviderElement extends AutoDisposeProviderElement<bool>
    with IsActivePlayerRef {
  _IsActivePlayerProviderElement(super.provider);

  @override
  int get playerId => (origin as IsActivePlayerProvider).playerId;
}

String _$activePlayerHash() => r'ec35ef9adcd2d0fcfa2c3c76d0937eccf37f2a50';

/// See also [activePlayer].
@ProviderFor(activePlayer)
final activePlayerProvider = AutoDisposeProvider<PlayerDisplay?>.internal(
  activePlayer,
  name: r'activePlayerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activePlayerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivePlayerRef = AutoDisposeProviderRef<PlayerDisplay?>;
String _$canShowBettingControlsHash() =>
    r'7df5b79539cdb94569c5accc3016a4410e5f1be2';

/// See also [canShowBettingControls].
@ProviderFor(canShowBettingControls)
const canShowBettingControlsProvider = CanShowBettingControlsFamily();

/// See also [canShowBettingControls].
class CanShowBettingControlsFamily extends Family<bool> {
  /// See also [canShowBettingControls].
  const CanShowBettingControlsFamily();

  /// See also [canShowBettingControls].
  CanShowBettingControlsProvider call(
    int playerId,
  ) {
    return CanShowBettingControlsProvider(
      playerId,
    );
  }

  @override
  CanShowBettingControlsProvider getProviderOverride(
    covariant CanShowBettingControlsProvider provider,
  ) {
    return call(
      provider.playerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'canShowBettingControlsProvider';
}

/// See also [canShowBettingControls].
class CanShowBettingControlsProvider extends AutoDisposeProvider<bool> {
  /// See also [canShowBettingControls].
  CanShowBettingControlsProvider(
    int playerId,
  ) : this._internal(
          (ref) => canShowBettingControls(
            ref as CanShowBettingControlsRef,
            playerId,
          ),
          from: canShowBettingControlsProvider,
          name: r'canShowBettingControlsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$canShowBettingControlsHash,
          dependencies: CanShowBettingControlsFamily._dependencies,
          allTransitiveDependencies:
              CanShowBettingControlsFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  CanShowBettingControlsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.playerId,
  }) : super.internal();

  final int playerId;

  @override
  Override overrideWith(
    bool Function(CanShowBettingControlsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CanShowBettingControlsProvider._internal(
        (ref) => create(ref as CanShowBettingControlsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        playerId: playerId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _CanShowBettingControlsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanShowBettingControlsProvider &&
        other.playerId == playerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, playerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CanShowBettingControlsRef on AutoDisposeProviderRef<bool> {
  /// The parameter `playerId` of this provider.
  int get playerId;
}

class _CanShowBettingControlsProviderElement
    extends AutoDisposeProviderElement<bool> with CanShowBettingControlsRef {
  _CanShowBettingControlsProviderElement(super.provider);

  @override
  int get playerId => (origin as CanShowBettingControlsProvider).playerId;
}

String _$betRangeHash() => r'094240f76d1fb50878f342574852f9f2f40c95f3';

/// See also [betRange].
@ProviderFor(betRange)
const betRangeProvider = BetRangeFamily();

/// See also [betRange].
class BetRangeFamily extends Family<({int minRaise, int maxRaise})> {
  /// See also [betRange].
  const BetRangeFamily();

  /// See also [betRange].
  BetRangeProvider call(
    int playerId,
  ) {
    return BetRangeProvider(
      playerId,
    );
  }

  @override
  BetRangeProvider getProviderOverride(
    covariant BetRangeProvider provider,
  ) {
    return call(
      provider.playerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'betRangeProvider';
}

/// See also [betRange].
class BetRangeProvider
    extends AutoDisposeProvider<({int minRaise, int maxRaise})> {
  /// See also [betRange].
  BetRangeProvider(
    int playerId,
  ) : this._internal(
          (ref) => betRange(
            ref as BetRangeRef,
            playerId,
          ),
          from: betRangeProvider,
          name: r'betRangeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$betRangeHash,
          dependencies: BetRangeFamily._dependencies,
          allTransitiveDependencies: BetRangeFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  BetRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.playerId,
  }) : super.internal();

  final int playerId;

  @override
  Override overrideWith(
    ({int minRaise, int maxRaise}) Function(BetRangeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BetRangeProvider._internal(
        (ref) => create(ref as BetRangeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        playerId: playerId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<({int minRaise, int maxRaise})> createElement() {
    return _BetRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BetRangeProvider && other.playerId == playerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, playerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BetRangeRef on AutoDisposeProviderRef<({int minRaise, int maxRaise})> {
  /// The parameter `playerId` of this provider.
  int get playerId;
}

class _BetRangeProviderElement
    extends AutoDisposeProviderElement<({int minRaise, int maxRaise})>
    with BetRangeRef {
  _BetRangeProviderElement(super.provider);

  @override
  int get playerId => (origin as BetRangeProvider).playerId;
}

String _$shouldShowCardsHash() => r'c56b3bf7ceab7fcc7b0420d16b6bb32d3fb4a906';

/// See also [shouldShowCards].
@ProviderFor(shouldShowCards)
const shouldShowCardsProvider = ShouldShowCardsFamily();

/// See also [shouldShowCards].
class ShouldShowCardsFamily extends Family<bool> {
  /// See also [shouldShowCards].
  const ShouldShowCardsFamily();

  /// See also [shouldShowCards].
  ShouldShowCardsProvider call(
    int playerId,
    int seatPosition,
  ) {
    return ShouldShowCardsProvider(
      playerId,
      seatPosition,
    );
  }

  @override
  ShouldShowCardsProvider getProviderOverride(
    covariant ShouldShowCardsProvider provider,
  ) {
    return call(
      provider.playerId,
      provider.seatPosition,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'shouldShowCardsProvider';
}

/// See also [shouldShowCards].
class ShouldShowCardsProvider extends AutoDisposeProvider<bool> {
  /// See also [shouldShowCards].
  ShouldShowCardsProvider(
    int playerId,
    int seatPosition,
  ) : this._internal(
          (ref) => shouldShowCards(
            ref as ShouldShowCardsRef,
            playerId,
            seatPosition,
          ),
          from: shouldShowCardsProvider,
          name: r'shouldShowCardsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shouldShowCardsHash,
          dependencies: ShouldShowCardsFamily._dependencies,
          allTransitiveDependencies:
              ShouldShowCardsFamily._allTransitiveDependencies,
          playerId: playerId,
          seatPosition: seatPosition,
        );

  ShouldShowCardsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.playerId,
    required this.seatPosition,
  }) : super.internal();

  final int playerId;
  final int seatPosition;

  @override
  Override overrideWith(
    bool Function(ShouldShowCardsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShouldShowCardsProvider._internal(
        (ref) => create(ref as ShouldShowCardsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        playerId: playerId,
        seatPosition: seatPosition,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _ShouldShowCardsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShouldShowCardsProvider &&
        other.playerId == playerId &&
        other.seatPosition == seatPosition;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, playerId.hashCode);
    hash = _SystemHash.combine(hash, seatPosition.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShouldShowCardsRef on AutoDisposeProviderRef<bool> {
  /// The parameter `playerId` of this provider.
  int get playerId;

  /// The parameter `seatPosition` of this provider.
  int get seatPosition;
}

class _ShouldShowCardsProviderElement extends AutoDisposeProviderElement<bool>
    with ShouldShowCardsRef {
  _ShouldShowCardsProviderElement(super.provider);

  @override
  int get playerId => (origin as ShouldShowCardsProvider).playerId;
  @override
  int get seatPosition => (origin as ShouldShowCardsProvider).seatPosition;
}

String _$playerCountsHash() => r'dadbfd206128464b30c6aff8cf730c64f9aa8bbe';

/// See also [playerCounts].
@ProviderFor(playerCounts)
final playerCountsProvider =
    AutoDisposeProvider<({int playerCount, int activePlayers})>.internal(
  playerCounts,
  name: r'playerCountsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$playerCountsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlayerCountsRef
    = AutoDisposeProviderRef<({int playerCount, int activePlayers})>;
String _$potOddsHash() => r'b82b65f19db9c69b6fa86e23de1a3395de1a544d';

/// See also [potOdds].
@ProviderFor(potOdds)
const potOddsProvider = PotOddsFamily();

/// See also [potOdds].
class PotOddsFamily extends Family<double> {
  /// See also [potOdds].
  const PotOddsFamily();

  /// See also [potOdds].
  PotOddsProvider call(
    int playerId,
  ) {
    return PotOddsProvider(
      playerId,
    );
  }

  @override
  PotOddsProvider getProviderOverride(
    covariant PotOddsProvider provider,
  ) {
    return call(
      provider.playerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'potOddsProvider';
}

/// See also [potOdds].
class PotOddsProvider extends AutoDisposeProvider<double> {
  /// See also [potOdds].
  PotOddsProvider(
    int playerId,
  ) : this._internal(
          (ref) => potOdds(
            ref as PotOddsRef,
            playerId,
          ),
          from: potOddsProvider,
          name: r'potOddsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$potOddsHash,
          dependencies: PotOddsFamily._dependencies,
          allTransitiveDependencies: PotOddsFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  PotOddsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.playerId,
  }) : super.internal();

  final int playerId;

  @override
  Override overrideWith(
    double Function(PotOddsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PotOddsProvider._internal(
        (ref) => create(ref as PotOddsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        playerId: playerId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _PotOddsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PotOddsProvider && other.playerId == playerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, playerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PotOddsRef on AutoDisposeProviderRef<double> {
  /// The parameter `playerId` of this provider.
  int get playerId;
}

class _PotOddsProviderElement extends AutoDisposeProviderElement<double>
    with PotOddsRef {
  _PotOddsProviderElement(super.provider);

  @override
  int get playerId => (origin as PotOddsProvider).playerId;
}

String _$isInPositionHash() => r'740073a7434c039d6fab752c831dae284c771a82';

/// See also [isInPosition].
@ProviderFor(isInPosition)
const isInPositionProvider = IsInPositionFamily();

/// See also [isInPosition].
class IsInPositionFamily extends Family<bool> {
  /// See also [isInPosition].
  const IsInPositionFamily();

  /// See also [isInPosition].
  IsInPositionProvider call(
    int playerId,
  ) {
    return IsInPositionProvider(
      playerId,
    );
  }

  @override
  IsInPositionProvider getProviderOverride(
    covariant IsInPositionProvider provider,
  ) {
    return call(
      provider.playerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isInPositionProvider';
}

/// See also [isInPosition].
class IsInPositionProvider extends AutoDisposeProvider<bool> {
  /// See also [isInPosition].
  IsInPositionProvider(
    int playerId,
  ) : this._internal(
          (ref) => isInPosition(
            ref as IsInPositionRef,
            playerId,
          ),
          from: isInPositionProvider,
          name: r'isInPositionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isInPositionHash,
          dependencies: IsInPositionFamily._dependencies,
          allTransitiveDependencies:
              IsInPositionFamily._allTransitiveDependencies,
          playerId: playerId,
        );

  IsInPositionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.playerId,
  }) : super.internal();

  final int playerId;

  @override
  Override overrideWith(
    bool Function(IsInPositionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsInPositionProvider._internal(
        (ref) => create(ref as IsInPositionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        playerId: playerId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsInPositionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsInPositionProvider && other.playerId == playerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, playerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsInPositionRef on AutoDisposeProviderRef<bool> {
  /// The parameter `playerId` of this provider.
  int get playerId;
}

class _IsInPositionProviderElement extends AutoDisposeProviderElement<bool>
    with IsInPositionRef {
  _IsInPositionProviderElement(super.provider);

  @override
  int get playerId => (origin as IsInPositionProvider).playerId;
}

String _$visibleCommunityCardsHash() =>
    r'1d57e3ffb5b8878e7907b2f38eefd68868105d35';

/// See also [visibleCommunityCards].
@ProviderFor(visibleCommunityCards)
final visibleCommunityCardsProvider = AutoDisposeProvider<int>.internal(
  visibleCommunityCards,
  name: r'visibleCommunityCardsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$visibleCommunityCardsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VisibleCommunityCardsRef = AutoDisposeProviderRef<int>;
String _$currentStreetHash() => r'62a910092750efff0f30e7491dd1527b92723673';

/// See also [currentStreet].
@ProviderFor(currentStreet)
final currentStreetProvider = AutoDisposeProvider<String>.internal(
  currentStreet,
  name: r'currentStreetProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentStreetHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentStreetRef = AutoDisposeProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
