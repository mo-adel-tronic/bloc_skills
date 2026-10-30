import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_session_cubit.dart';

// Events
sealed class SessionSyncEvent extends Equatable {
  const SessionSyncEvent();
  @override
  List<Object?> get props => [];
}

class AuthChangedEvent extends SessionSyncEvent {
  final AuthSessionState authState;
  const AuthChangedEvent(this.authState);

  @override
  List<Object?> get props => [authState];
}

class RefreshDataEvent extends SessionSyncEvent {
  const RefreshDataEvent();
}

// States
class SessionSyncState extends Equatable {
  final bool hasAccess;
  final String secretData;
  final List<String> eventLog;

  const SessionSyncState({
    required this.hasAccess,
    required this.secretData,
    required this.eventLog,
  });

  factory SessionSyncState.initial() => const SessionSyncState(
        hasAccess: false,
        secretData: 'Locked — Please Authenticate',
        eventLog: ['SessionSyncBloc initialized. Listening to AuthSessionCubit...'],
      );

  SessionSyncState copyWith({
    bool? hasAccess,
    String? secretData,
    List<String>? eventLog,
  }) {
    return SessionSyncState(
      hasAccess: hasAccess ?? this.hasAccess,
      secretData: secretData ?? this.secretData,
      eventLog: eventLog ?? this.eventLog,
    );
  }

  @override
  List<Object?> get props => [hasAccess, secretData, eventLog];
}

// BLoC demonstrating BLoC-to-BLoC communication via StreamSubscription
class SessionSyncBloc extends Bloc<SessionSyncEvent, SessionSyncState> {
  final AuthSessionCubit authSessionCubit;
  late final StreamSubscription<AuthSessionState> _authSubscription;

  SessionSyncBloc({required this.authSessionCubit})
      : super(SessionSyncState.initial()) {
    on<AuthChangedEvent>(_onAuthChanged);
    on<RefreshDataEvent>(_onRefreshData);

    // 1. Subscribe to external BLoC stream in constructor
    _authSubscription = authSessionCubit.stream.listen((authState) {
      add(AuthChangedEvent(authState));
    });

    // Sync with initial auth state if already logged in
    if (authSessionCubit.state.status == AuthStatus.authenticated) {
      add(AuthChangedEvent(authSessionCubit.state));
    }
  }

  void _onAuthChanged(
    AuthChangedEvent event,
    Emitter<SessionSyncState> emit,
  ) {
    final auth = event.authState;
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);

    if (auth.status == AuthStatus.authenticated) {
      final isAdm = auth.role == 'Administrator';
      final newLogs = List<String>.from(state.eventLog)
        ..add('[$timestamp] 📥 Stream Received: ${auth.username} (${auth.role})');

      emit(state.copyWith(
        hasAccess: true,
        secretData: isAdm
            ? '🔑 ADMIN VAULT: Full database read/write access granted.'
            : '📄 MEMBER VAULT: Standard user dashboard content.',
        eventLog: newLogs,
      ));
    } else {
      final newLogs = List<String>.from(state.eventLog)
        ..add('[$timestamp] 🔒 Stream Received: User Logged Out');

      emit(state.copyWith(
        hasAccess: false,
        secretData: 'Locked — Please Authenticate',
        eventLog: newLogs,
      ));
    }
  }

  void _onRefreshData(
    RefreshDataEvent event,
    Emitter<SessionSyncState> emit,
  ) {
    if (!state.hasAccess) return;
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    final newLogs = List<String>.from(state.eventLog)
      ..add('[$timestamp] 🔄 Manual refresh requested for current session');

    emit(state.copyWith(eventLog: newLogs));
  }

  // 2. CRITICAL: Always cancel stream subscription when closing the BLoC!
  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}

