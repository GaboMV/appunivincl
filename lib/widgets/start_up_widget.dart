import 'package:appuniv/database/database_providers.dart';
import 'package:appuniv/database/repositories/repo_provider.dart';
// 🚨 CORRECCIÓN DE IMPORTACIÓN 🚨

import 'package:appuniv/features/login/presentation/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart'; // Necesario para el tipo Database

class AppStartUpWidget extends ConsumerWidget {
  const AppStartUpWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 💡 Paso CRÍTICO: Observamos el FutureProvider de la base de datos.
    // Esto obliga a la BD a inicializarse de forma ansiosa.
    final databaseState = ref.watch(databaseInstanceProvider);

    // Usamos .when para manejar los tres posibles estados del Future
    return databaseState.when(
      // ⏳ Estado de Carga (La BD se está abriendo/creando)
      loading:
          () => const Scaffold(
            backgroundColor: Colors.black, // Color oscuro para coherencia
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.greenAccent),
                  SizedBox(height: 16),
                  Text(
                    'Inicializando sistema académico...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

      // ❌ Estado de Error (Error al crear/abrir la BD)
      error:
          (err, stack) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'Error fatal al cargar la base de datos. Por favor, reinicia la aplicación. Detalles: ${err.toString()}',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

      // ✅ Estado de Datos (La BD está lista)
      data: (Database db) {
        final repo = ref.read(estudianteRepositoryProvider);
        print(repo.debugPrintAllTables());
        // La instancia de Database está disponible. Podemos mostrar el Login.
        // Usamos el nombre correcto de la clase: LoginPageAccesible
        return const LoginPageAccesible();
      },
    );
  }
}
