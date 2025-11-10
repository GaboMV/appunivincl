// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historial_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$historialSemestresHash() =>
    r'41f3658ab56ee431020944e2016d514f84f6c809';

/// Provider que obtiene los semestres donde el estudiante tuvo inscripciones
///
/// Copied from [historialSemestres].
@ProviderFor(historialSemestres)
final historialSemestresProvider = FutureProvider<List<Semestre>>.internal(
  historialSemestres,
  name: r'historialSemestresProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historialSemestresHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HistorialSemestresRef = FutureProviderRef<List<Semestre>>;
String _$historialMateriasHash() => r'c6134637923466f0eee54e67e741faa844dd0fcf';

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

/// Provider que obtiene las materias de UN semestre específico
/// Pasa el idSemestre como argumento
///
/// Copied from [historialMaterias].
@ProviderFor(historialMaterias)
const historialMateriasProvider = HistorialMateriasFamily();

/// Provider que obtiene las materias de UN semestre específico
/// Pasa el idSemestre como argumento
///
/// Copied from [historialMaterias].
class HistorialMateriasFamily
    extends Family<AsyncValue<List<HistorialMateria>>> {
  /// Provider que obtiene las materias de UN semestre específico
  /// Pasa el idSemestre como argumento
  ///
  /// Copied from [historialMaterias].
  const HistorialMateriasFamily();

  /// Provider que obtiene las materias de UN semestre específico
  /// Pasa el idSemestre como argumento
  ///
  /// Copied from [historialMaterias].
  HistorialMateriasProvider call(int idSemestre) {
    return HistorialMateriasProvider(idSemestre);
  }

  @override
  HistorialMateriasProvider getProviderOverride(
    covariant HistorialMateriasProvider provider,
  ) {
    return call(provider.idSemestre);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'historialMateriasProvider';
}

/// Provider que obtiene las materias de UN semestre específico
/// Pasa el idSemestre como argumento
///
/// Copied from [historialMaterias].
class HistorialMateriasProvider extends FutureProvider<List<HistorialMateria>> {
  /// Provider que obtiene las materias de UN semestre específico
  /// Pasa el idSemestre como argumento
  ///
  /// Copied from [historialMaterias].
  HistorialMateriasProvider(int idSemestre)
    : this._internal(
        (ref) => historialMaterias(ref as HistorialMateriasRef, idSemestre),
        from: historialMateriasProvider,
        name: r'historialMateriasProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$historialMateriasHash,
        dependencies: HistorialMateriasFamily._dependencies,
        allTransitiveDependencies:
            HistorialMateriasFamily._allTransitiveDependencies,
        idSemestre: idSemestre,
      );

  HistorialMateriasProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.idSemestre,
  }) : super.internal();

  final int idSemestre;

  @override
  Override overrideWith(
    FutureOr<List<HistorialMateria>> Function(HistorialMateriasRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HistorialMateriasProvider._internal(
        (ref) => create(ref as HistorialMateriasRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        idSemestre: idSemestre,
      ),
    );
  }

  @override
  FutureProviderElement<List<HistorialMateria>> createElement() {
    return _HistorialMateriasProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HistorialMateriasProvider && other.idSemestre == idSemestre;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, idSemestre.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HistorialMateriasRef on FutureProviderRef<List<HistorialMateria>> {
  /// The parameter `idSemestre` of this provider.
  int get idSemestre;
}

class _HistorialMateriasProviderElement
    extends FutureProviderElement<List<HistorialMateria>>
    with HistorialMateriasRef {
  _HistorialMateriasProviderElement(super.provider);

  @override
  int get idSemestre => (origin as HistorialMateriasProvider).idSemestre;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
