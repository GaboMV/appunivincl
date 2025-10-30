import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart'; // Importa la clase del paso 1
part 'database_providers.g.dart';

@Riverpod(keepAlive: true) // Mantiene la instancia viva en la app
DatabaseService databaseService(DatabaseServiceRef ref) {
  return DatabaseService();
}

// Opcional, pero útil: Proveedor para obtener la instancia DB (Future)
@Riverpod(keepAlive: true)
Future<Database> databaseInstance(DatabaseInstanceRef ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.database;
}