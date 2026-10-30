import 'package:equatable/equatable.dart';

/// Base state sealed class.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final String username;
  const AuthAuthenticated(this.username);

  @override
  List<Object?> get props => [username];
}

class AuthFailure extends AuthState {
  final String errorMessage;
  const AuthFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
