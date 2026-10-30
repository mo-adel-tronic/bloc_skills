import 'package:equatable/equatable.dart';

/// Base event sealed class.
/// `sealed` ensures exhaustive type checking across Dart 3 pattern matching.
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user presses the login button.
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Dispatched when user logs out.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Dispatched to reset back to initial form.
class AuthResetRequested extends AuthEvent {
  const AuthResetRequested();
}
