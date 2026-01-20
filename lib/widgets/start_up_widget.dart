// lib/widgets/start_up_widget.dart
// (¡¡¡LA PUTA VERSIÓN CORREGIDA QUE NO FALLA EL PARSEO!!!)

import 'dart:convert';
import 'package:appuniv/features/home/presentation/menu_principal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ¡¡¡AJUSTA ESTOS PUTOS IMPORTS!!!
import 'package:appuniv/features/login/presentation/login.dart'; 

import 'package:appuniv/features/session/providers/session_provider.dart';
import 'package:appuniv/services/api_service.dart'; // Necesario para logout si hay error

// ¡Provider auxiliar para manejar el Future/Loading!
final _sessionInitializationProvider = FutureProvider<bool>((ref) async {
    final sessionNotifier = ref.read(sessionNotifierProvider.notifier);
    // Llama a la función que lee el token y los datos del estudiante
    return await sessionNotifier.initializeSession();
});

/// Este es el puto "Bouncer".
/// Inicializa la sesión y decide a dónde navegar.
class AppStartUpWidget extends ConsumerWidget {
  // ¡¡¡ARREGLO #1: NO LLEVA 'const'!!!
  AppStartUpWidget({super.key}); 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observamos el futuro de la inicialización
    final initFuture = ref.watch(_sessionInitializationProvider);

    // ¡¡¡ARREGLO #2: EL CÓDIGO DEL '.when' ES SINTÁCTICAMENTE SEGURO!!!
    return initFuture.when(
      
      // --- loading: ---
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            semanticsLabel: 'Verificando sesión...',
          ),
        ),
      ),
      
      // --- error: ---
      error: (err, stack) {
        // En caso de error de lectura de disco (JSON corrupto), limpiamos la sesión.
        ref.read(apiServiceProvider).logout();
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                "ERROR FATAL DE INICIO: $err. Sesión limpiada. Por favor, reinicia la app.", 
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      
      // --- data: --- (¡Este es el que fallaba, carajo!)
      data: (isRestored) {
        // Ahora, solo miramos el estado actual de Riverpod
        final sessionState = ref.watch(sessionNotifierProvider);
        
        if (sessionState.isLoggedIn) {
          // ¡Riverpod tiene datos! ¡A la casa!
          return const MenuPrincipalAccesible(); 
        } else {
          // No se pudo restaurar o no había token. ¡Al login!
          return const LoginPageAccesible(); 
        }
      },
    );
  }
}