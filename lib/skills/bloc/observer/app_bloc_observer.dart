import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LogType { event, change, transition, error }

class ObserverLogEntry {
  final DateTime timestamp;
  final String blocName;
  final LogType type;
  final String details;

  ObserverLogEntry({
    required this.timestamp,
    required this.blocName,
    required this.type,
    required this.details,
  });
}

/// AppBlocObserver intercepts all lifecycle events across every Cubit & BLoC.
/// Registered globally via `Bloc.observer = AppBlocObserver();` in `main()`.
class AppBlocObserver extends BlocObserver {
  // Global log buffer for UI inspection
  static final ValueNotifier<List<ObserverLogEntry>> logsNotifier =
      ValueNotifier<List<ObserverLogEntry>>([]);

  static void _addLog(String blocName, LogType type, String details) {
    final entry = ObserverLogEntry(
      timestamp: DateTime.now(),
      blocName: blocName,
      type: type,
      details: details,
    );

    final current = List<ObserverLogEntry>.from(logsNotifier.value)..add(entry);
    if (current.length > 50) {
      current.removeAt(0); // keep last 50
    }
    logsNotifier.value = current;

    // Also print to console
    if (kDebugMode) {
      print('[$blocName] ${type.name.toUpperCase()}: $details');
    }
  }

  static void clearLogs() {
    logsNotifier.value = [];
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _addLog(bloc.runtimeType.toString(), LogType.event, event.toString());
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    _addLog(
      bloc.runtimeType.toString(),
      LogType.change,
      '${change.currentState} -> ${change.nextState}',
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _addLog(
      bloc.runtimeType.toString(),
      LogType.transition,
      'Event: ${transition.event} | Current: ${transition.currentState} | Next: ${transition.nextState}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    _addLog(bloc.runtimeType.toString(), LogType.error, error.toString());
    super.onError(bloc, error, stackTrace);
  }
}
