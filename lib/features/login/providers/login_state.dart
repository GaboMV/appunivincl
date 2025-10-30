// lib/features/login/providers/login_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

// Nota: Si usas 'freezed', debes usar la anotación '@Freezed(toString: false)'
// Si no usas 'freezed', simplemente usa una clase normal con un constructor y copyWith

class LoginState {
  final String username;
  final String password;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  const LoginState({
    this.username = '',
    this.password = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  // Constructor inicial para facilitar la lectura
  const LoginState.initial() : this();

  // Método necesario para actualizar el estado inmutablemente
  LoginState copyWith({
    String? username,
    String? password,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      // Si errorMessage es null, se mantiene el valor actual. Si se pasa '', se borra el error.
      errorMessage: (errorMessage != null) ? errorMessage : this.errorMessage,
    );
  }
}