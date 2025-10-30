// lib/features/login/providers/login_provider.dart

import 'package:appuniv/database/repositories/repo_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'login_state.dart'; 
import '../../session/providers/session_provider.dart';
// 🚨 IMPORTAMOS LAS UTILIDADES 🚨
import '../../../utils/string_utils.dart'; 

part 'login_provider.g.dart';

@riverpod
class LoginNotifier extends _$LoginNotifier {
  
  @override
  LoginState build() {
    return const LoginState.initial(); 
  }

  // 🚨 APLICAMOS NORMALIZACIÓN AL SETTEAR EL ESTADO 🚨
  void setUsername(String value) {
    final cleanValue = AuthNormalizer.normalizeUsername(value);
    state = state.copyWith(username: cleanValue, errorMessage: '', isSuccess: false); 
  }

  void setPassword(String value) {
    final cleanValue = AuthNormalizer.normalizePassword(value);
    state = state.copyWith(password: cleanValue, errorMessage: '', isSuccess: false);
  }

  Future<void> login() async {
    
    // El estado ya contiene los valores limpios, pero verificamos si están vacíos
    if (state.username.isEmpty || state.password.isEmpty) {
        state = state.copyWith(
          errorMessage: "Usuario y contraseña no pueden estar vacíos.",
          isLoading: false,
        );
        return;
    }

    state = state.copyWith(isLoading: true, errorMessage: '', isSuccess: false);

    try {
      final repo = ref.read(estudianteRepositoryProvider); 
      final sessionNotifier = ref.read(sessionNotifierProvider.notifier);
      
      // 🚨 USO CLAVE: Enviamos las cadenas NORMALIZADAS al repositorio 🚨
      final estudiante = await repo.authenticate(state.username, state.password);
      print(repo.debugPrintAllStudents());
      if (estudiante != null) {
        sessionNotifier.setSession(estudiante); 
        state = state.copyWith(isSuccess: true, isLoading: false);
      } else {
        state = state.copyWith(
          errorMessage: "Usuario o contraseña incorrectos. Intenta de nuevo.",
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: "Error de sistema al verificar credenciales. (${e.toString()})",
        isLoading: false,
      );
      print('LOGIN ERROR: $e');
    }
  }

  void reset() {
    state = const LoginState.initial();
  }
}