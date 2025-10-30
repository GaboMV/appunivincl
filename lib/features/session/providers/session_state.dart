// lib/features/session/providers/session_state.dart
import 'package:appuniv/database/models/academic_models.dart';


class SessionState {
  final Estudiante? estudiante;
  final bool isLoggedIn;

  SessionState({this.estudiante, required this.isLoggedIn});

  // Estado inicial: Nadie logueado
  SessionState.initial() : this(estudiante: null, isLoggedIn: false);

  SessionState copyWith({
    Estudiante? estudiante,
    bool? isLoggedIn,
  }) {
    return SessionState(
      estudiante: estudiante ?? this.estudiante,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}