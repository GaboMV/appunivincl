// lib/data/repositories/repo_providers.dart

import 'package:appuniv/database/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// Importa la instancia de DB que creamos

import 'estudiante_repository.dart';
import 'materia_repository.dart';
import 'registro_repository.dart';
part 'repo_provider.g.dart';

@Riverpod(keepAlive: true)
EstudianteRepository estudianteRepository(EstudianteRepositoryRef ref) {
  final dbInstanceFuture = ref.watch(databaseInstanceProvider.future);
  return EstudianteRepository(dbInstanceFuture);
}

@Riverpod(keepAlive: true)
MateriaRepository materiaRepository(MateriaRepositoryRef ref) {
  final dbInstanceFuture = ref.watch(databaseInstanceProvider.future);
  return MateriaRepository(dbInstanceFuture);
}

@Riverpod(keepAlive: true)
RegistroRepository registroRepository(RegistroRepositoryRef ref) {
  final dbInstanceFuture = ref.watch(databaseInstanceProvider.future);
  return RegistroRepository(dbInstanceFuture);
}
