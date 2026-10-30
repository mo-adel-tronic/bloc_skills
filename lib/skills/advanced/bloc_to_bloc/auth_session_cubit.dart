import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthSessionState extends Equatable {
  final AuthStatus status;
  final String username;
  final String role;

  const AuthSessionState({
    required this.status,
    required this.username,
    required this.role,
  });

  const AuthSessionState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        username = 'Guest',
        role = 'None';

  @override
  List<Object?> get props => [status, username, role];
}

class AuthSessionCubit extends Cubit<AuthSessionState> {
  AuthSessionCubit() : super(const AuthSessionState.unauthenticated());

  void loginAsMember() {
    emit(const AuthSessionState(
      status: AuthStatus.authenticated,
      username: 'Sarah Connor',
      role: 'Member',
    ));
  }

  void loginAsAdmin() {
    emit(const AuthSessionState(
      status: AuthStatus.authenticated,
      username: 'Alex Vance',
      role: 'Administrator',
    ));
  }

  void logout() {
    emit(const AuthSessionState.unauthenticated());
  }
}

