// lib/data/repositories/repo_providers.dart

import 'package:appuniv/database/database_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import 'estudiante_repository.dart';
import 'materia_repository.dart';
import 'registro_repository.dart';
part 'repo_provider.g.dart';

// Esta función centraliza la lógica para obtener la BD.
Database _getDb(ProviderRef ref) {
  // 🚨 Usamos ProviderRef genérico
  final dbAsyncValue = ref.watch(databaseInstanceProvider);

  // 🚨 LA CORRECCIÓN ESTÁ AQUÍ 🚨
  // Tu versión de Riverpod no tiene '.requireValue'.
  // Usamos '.value' en su lugar.
  final db = dbAsyncValue.value;

  // Agregamos un chequeo de seguridad.
  // Tu AppStartUpWidget evita que esto pase, pero es una buena práctica.
  if (db == null) {
    throw Exception(
      "La base de datos (DB) es nula. El provider 'databaseInstanceProvider' aún no está listo o falló.",
    );
  }

  return db;
}

@Riverpod(keepAlive: true)
EstudianteRepository estudianteRepository(EstudianteRepositoryRef ref) {
  // Ahora esto funciona porque _getDb usa .value
  return EstudianteRepository(_getDb(ref));
}

@Riverpod(keepAlive: true)
MateriaRepository materiaRepository(MateriaRepositoryRef ref) {
  // Aplicamos la misma corrección aquí
  return MateriaRepository(_getDb(ref));
}

@Riverpod(keepAlive: true)
RegistroRepository registroRepository(RegistroRepositoryRef ref) {
  // Aplicamos la misma corrección aquí
  return RegistroRepository(_getDb(ref));
}
