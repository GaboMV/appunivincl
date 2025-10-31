// lib/features/session/providers/session_provider.dart
import 'package:appuniv/database/models/academic_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'session_state.dart';

part 'session_provider.g.dart';

@Riverpod(keepAlive: true)
class SessionNotifier extends _$SessionNotifier {
  @override
  SessionState build() {
    return SessionState.initial();
  }

  // Llamado por LoginNotifier si el login es exitoso
  void setSession(Estudiante estudiante) {
    state = state.copyWith(estudiante: estudiante, isLoggedIn: true);
  }

  void logout() {
    state = SessionState.initial();
  }
}
