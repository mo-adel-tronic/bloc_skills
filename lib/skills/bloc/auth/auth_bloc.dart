import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc manages authentication using asynchronous event handlers.
/// Key concept for Commit 6:
/// - Handlers can be async: `Future<void> _onLoginSubmitted(event, emit) async`
/// - Emit Loading -> await API -> Emit Success or Failure
/// - Always wrap in try/catch to handle network/server exceptions cleanly
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthResetRequested>(_onResetRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    // 1. Immediately emit Loading so UI reflects progress
    emit(const AuthLoading());

    try {
      // 2. Simulate realistic network latency (1.5 seconds)
      await Future.delayed(const Duration(milliseconds: 1500));

      // 3. Validation checks
      if (!event.email.contains('@')) {
        emit(const AuthFailure('Please enter a valid email address with @'));
        return;
      }
      if (event.password.length < 6) {
        emit(const AuthFailure('Password must be at least 6 characters long'));
        return;
      }

      // 4. Simulated backend authentication
      if (event.email == 'admin@flutter.dev' && event.password == 'flutter123') {
        emit(const AuthAuthenticated('Admin User'));
      } else if (event.email.startsWith('error@')) {
        throw Exception('Server 500: Database connection timed out');
      } else {
        emit(const AuthFailure('Invalid email or password. Hint: admin@flutter.dev / flutter123'));
      }
    } catch (e) {
      // 5. Catch any unexpected exceptions and emit user-friendly failure
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }

  void _onResetRequested(AuthResetRequested event, Emitter<AuthState> emit) {
    emit(const AuthInitial());
  }
}
