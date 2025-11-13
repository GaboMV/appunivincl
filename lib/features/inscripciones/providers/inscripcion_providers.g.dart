// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inscripcion_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$facultadesHash() => r'a3a678c32a729e7c4fd358b2bf60ee4847959c6a';

/// See also [facultades].
@ProviderFor(facultades)
final facultadesProvider = FutureProvider<List<Facultad>>.internal(
  facultades,
  name: r'facultadesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$facultadesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FacultadesRef = FutureProviderRef<List<Facultad>>;
String _$materiasPorFacultadHash() =>
    r'2f8510cbd4495c3a6ae41407e37770f5768a4354';

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

/// See also [materiasPorFacultad].
@ProviderFor(materiasPorFacultad)
const materiasPorFacultadProvider = MateriasPorFacultadFamily();

/// See also [materiasPorFacultad].
class MateriasPorFacultadFamily extends Family<AsyncValue<List<Materia>>> {
  /// See also [materiasPorFacultad].
  const MateriasPorFacultadFamily();

  /// See also [materiasPorFacultad].
  MateriasPorFacultadProvider call(int idFacultad) {
    return MateriasPorFacultadProvider(idFacultad);
  }

  @override
  MateriasPorFacultadProvider getProviderOverride(
    covariant MateriasPorFacultadProvider provider,
  ) {
    return call(provider.idFacultad);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'materiasPorFacultadProvider';
}

/// See also [materiasPorFacultad].
class MateriasPorFacultadProvider extends FutureProvider<List<Materia>> {
  /// See also [materiasPorFacultad].
  MateriasPorFacultadProvider(int idFacultad)
    : this._internal(
        (ref) => materiasPorFacultad(ref as MateriasPorFacultadRef, idFacultad),
        from: materiasPorFacultadProvider,
        name: r'materiasPorFacultadProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$materiasPorFacultadHash,
        dependencies: MateriasPorFacultadFamily._dependencies,
        allTransitiveDependencies:
            MateriasPorFacultadFamily._allTransitiveDependencies,
        idFacultad: idFacultad,
      );

  MateriasPorFacultadProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.idFacultad,
  }) : super.internal();

  final int idFacultad;

  @override
  Override overrideWith(
    FutureOr<List<Materia>> Function(MateriasPorFacultadRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MateriasPorFacultadProvider._internal(
        (ref) => create(ref as MateriasPorFacultadRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        idFacultad: idFacultad,
      ),
    );
  }

  @override
  FutureProviderElement<List<Materia>> createElement() {
    return _MateriasPorFacultadProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MateriasPorFacultadProvider &&
        other.idFacultad == idFacultad;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, idFacultad.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MateriasPorFacultadRef on FutureProviderRef<List<Materia>> {
  /// The parameter `idFacultad` of this provider.
  int get idFacultad;
}

class _MateriasPorFacultadProviderElement
    extends FutureProviderElement<List<Materia>>
    with MateriasPorFacultadRef {
  _MateriasPorFacultadProviderElement(super.provider);

  @override
  int get idFacultad => (origin as MateriasPorFacultadProvider).idFacultad;
}

String _$materiasPorBusquedaHash() =>
    r'33c0ef266765e894a99a6a664d3cfa561b0c946b';

/// See also [materiasPorBusqueda].
@ProviderFor(materiasPorBusqueda)
const materiasPorBusquedaProvider = MateriasPorBusquedaFamily();

/// See also [materiasPorBusqueda].
class MateriasPorBusquedaFamily extends Family<AsyncValue<List<Materia>>> {
  /// See also [materiasPorBusqueda].
  const MateriasPorBusquedaFamily();

  /// See also [materiasPorBusqueda].
  MateriasPorBusquedaProvider call(String query) {
    return MateriasPorBusquedaProvider(query);
  }

  @override
  MateriasPorBusquedaProvider getProviderOverride(
    covariant MateriasPorBusquedaProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'materiasPorBusquedaProvider';
}

/// See also [materiasPorBusqueda].
class MateriasPorBusquedaProvider extends FutureProvider<List<Materia>> {
  /// See also [materiasPorBusqueda].
  MateriasPorBusquedaProvider(String query)
    : this._internal(
        (ref) => materiasPorBusqueda(ref as MateriasPorBusquedaRef, query),
        from: materiasPorBusquedaProvider,
        name: r'materiasPorBusquedaProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$materiasPorBusquedaHash,
        dependencies: MateriasPorBusquedaFamily._dependencies,
        allTransitiveDependencies:
            MateriasPorBusquedaFamily._allTransitiveDependencies,
        query: query,
      );

  MateriasPorBusquedaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Materia>> Function(MateriasPorBusquedaRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MateriasPorBusquedaProvider._internal(
        (ref) => create(ref as MateriasPorBusquedaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  FutureProviderElement<List<Materia>> createElement() {
    return _MateriasPorBusquedaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MateriasPorBusquedaProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MateriasPorBusquedaRef on FutureProviderRef<List<Materia>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _MateriasPorBusquedaProviderElement
    extends FutureProviderElement<List<Materia>>
    with MateriasPorBusquedaRef {
  _MateriasPorBusquedaProviderElement(super.provider);

  @override
  String get query => (origin as MateriasPorBusquedaProvider).query;
}

String _$paralelosMateriaHash() => r'e3dd71c3c4568520cc982e324935c3396bbc69ae';

/// See also [paralelosMateria].
@ProviderFor(paralelosMateria)
const paralelosMateriaProvider = ParalelosMateriaFamily();

/// See also [paralelosMateria].
class ParalelosMateriaFamily
    extends Family<AsyncValue<List<ParaleloDetalleCompleto>>> {
  /// See also [paralelosMateria].
  const ParalelosMateriaFamily();

  /// See also [paralelosMateria].
  ParalelosMateriaProvider call(int idMateria) {
    return ParalelosMateriaProvider(idMateria);
  }

  @override
  ParalelosMateriaProvider getProviderOverride(
    covariant ParalelosMateriaProvider provider,
  ) {
    return call(provider.idMateria);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'paralelosMateriaProvider';
}

/// See also [paralelosMateria].
class ParalelosMateriaProvider
    extends FutureProvider<List<ParaleloDetalleCompleto>> {
  /// See also [paralelosMateria].
  ParalelosMateriaProvider(int idMateria)
    : this._internal(
        (ref) => paralelosMateria(ref as ParalelosMateriaRef, idMateria),
        from: paralelosMateriaProvider,
        name: r'paralelosMateriaProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$paralelosMateriaHash,
        dependencies: ParalelosMateriaFamily._dependencies,
        allTransitiveDependencies:
            ParalelosMateriaFamily._allTransitiveDependencies,
        idMateria: idMateria,
      );

  ParalelosMateriaProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.idMateria,
  }) : super.internal();

  final int idMateria;

  @override
  Override overrideWith(
    FutureOr<List<ParaleloDetalleCompleto>> Function(
      ParalelosMateriaRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ParalelosMateriaProvider._internal(
        (ref) => create(ref as ParalelosMateriaRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        idMateria: idMateria,
      ),
    );
  }

  @override
  FutureProviderElement<List<ParaleloDetalleCompleto>> createElement() {
    return _ParalelosMateriaProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ParalelosMateriaProvider && other.idMateria == idMateria;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, idMateria.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ParalelosMateriaRef on FutureProviderRef<List<ParaleloDetalleCompleto>> {
  /// The parameter `idMateria` of this provider.
  int get idMateria;
}

class _ParalelosMateriaProviderElement
    extends FutureProviderElement<List<ParaleloDetalleCompleto>>
    with ParalelosMateriaRef {
  _ParalelosMateriaProviderElement(super.provider);

  @override
  int get idMateria => (origin as ParalelosMateriaProvider).idMateria;
}

String _$inscripcionServiceHash() =>
    r'fa54d93c55b8f9b29aea2060a30d2e5e7391a3ae';

/// See also [InscripcionService].
@ProviderFor(InscripcionService)
final inscripcionServiceProvider =
    NotifierProvider<InscripcionService, void>.internal(
      InscripcionService.new,
      name: r'inscripcionServiceProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$inscripcionServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InscripcionService = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
