// lib/features/login/providers/login_provider.dart
// (¡¡¡LA PUTA VERSIÓN NUEVA CON API, CARAJO!!!)

// import 'package:appuniv/database/repositories/repo_provider.dart'; 

// ¡¡¡TRAE AL NUEVO PUTO JEFE!!!
import 'package:appuniv/database/models/academic_models.dart';
import 'package:appuniv/services/api_service.dart'; 
// ¡¡¡NECESITAMOS EL MODELO ESTUDIANTE PARA PARSEAR EL JSON!!!
 // (¡¡¡REVISA ESTA PUTA RUTA, CARAJO!!!)

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'login_state.dart';
import '../../session/providers/session_provider.dart';
import '../../../utils/string_utils.dart'; // Tu normalizer (¡está bien, carajo!)

part 'login_provider.g.dart';
// lib/features/login/providers/login_provider.dart
// (¡¡¡LA PUTA VERSIÓN CON MÁS LOGS!!!)


@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  LoginState build() {
    return const LoginState.initial();
  }

  // (setUsername y setPassword se quedan igual, carajo)
  void setUsername(String value) {
    final cleanValue = AuthNormalizer.normalizeUsername(value);
    state = state.copyWith(
      username: cleanValue,
      errorMessage: '',
      isSuccess: false,
    );
  }
  void setPassword(String value) {
    final cleanValue = AuthNormalizer.normalizePassword(value);
    state = state.copyWith(
      password: cleanValue,
      errorMessage: '',
      isSuccess: false,
    );
  }

  Future<void> login() async {
    if (state.username.isEmpty || state.password.isEmpty) {
      state = state.copyWith(
        errorMessage: "Usuario y contraseña no pueden estar vacíos.",
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: '', isSuccess: false);

    print("LOGIN_PROVIDER: Intentando login con U: [${state.username}], P: [${state.password}]");

    try {
      final apiService = ref.read(apiServiceProvider); 
      final sessionNotifier = ref.read(sessionNotifierProvider.notifier); 

      final loginResponse = await apiService.login(
        state.username,
        state.password,
      );
      
      // ¡¡¡PUTO LOG #2: ¡ÉXITO, CARAJO!!!
      print("LOGIN_PROVIDER: ¡Login exitoso! Token recibido.");

      final estudianteMap = loginResponse['estudiante'] as Map<String, dynamic>?;

      if (estudianteMap == null) {
        throw Exception("Login exitoso pero el estudiante es nulo. ");
      }
      
      final estudiante = Estudiante.fromMap(estudianteMap);

      sessionNotifier.setSession(estudiante);
      state = state.copyWith(isSuccess: true, isLoading: false);

    } catch (e) {
      // ¡¡¡PUTO LOG #3: ¡LA CAGADA FINAL!!!
      // Este es el error que ve el usuario, carajo.
      print("LOGIN_PROVIDER: ¡ERROR CAPTURADO! : ${e.toString()}");

      state = state.copyWith(
        errorMessage: e.toString(), 
        isLoading: false,
      );
      print('LOGIN ERROR (API): $e');
    }
  }

  void reset() {
    state = const LoginState.initial();
  }
}