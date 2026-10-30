import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ==========================================
// 1. DROPPABLE PATTERN (Payment / Submit Button)
// ==========================================

sealed class PaymentEvent extends Equatable {
  const PaymentEvent();
  @override
  List<Object?> get props => [];
}

class RegisterTapEvent extends PaymentEvent {}

class SubmitPaymentEvent extends PaymentEvent {
  final double amount;
  const SubmitPaymentEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class ResetPaymentEvent extends PaymentEvent {}

enum PaymentStatus { idle, processing, completed }

class PaymentState extends Equatable {
  final PaymentStatus status;
  final int tapsCount;
  final int processedCount;
  final int droppedCount;
  final String message;

  const PaymentState({
    required this.status,
    required this.tapsCount,
    required this.processedCount,
    required this.droppedCount,
    required this.message,
  });

  factory PaymentState.initial() => const PaymentState(
        status: PaymentStatus.idle,
        tapsCount: 0,
        processedCount: 0,
        droppedCount: 0,
        message: 'Ready to submit transaction.',
      );

  PaymentState copyWith({
    PaymentStatus? status,
    int? tapsCount,
    int? processedCount,
    int? droppedCount,
    String? message,
  }) {
    return PaymentState(
      status: status ?? this.status,
      tapsCount: tapsCount ?? this.tapsCount,
      processedCount: processedCount ?? this.processedCount,
      droppedCount: droppedCount ?? this.droppedCount,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, tapsCount, processedCount, droppedCount, message];
}

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  int _actualHandlerInvocations = 0;

  PaymentBloc() : super(PaymentState.initial()) {
    // DROPPABLE: While this handler is running, any new SubmitPaymentEvent is DROPPED!
    on<SubmitPaymentEvent>(
      _onSubmitPayment,
      transformer: droppable(),
    );

    on<RegisterTapEvent>((event, emit) {
      emit(state.copyWith(tapsCount: state.tapsCount + 1));
    });

    on<ResetPaymentEvent>((event, emit) {
      _actualHandlerInvocations = 0;
      emit(PaymentState.initial());
    });
  }

  Future<void> _onSubmitPayment(
    SubmitPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    _actualHandlerInvocations++;
    emit(state.copyWith(
      status: PaymentStatus.processing,
      message: '⏳ Processing transaction of \$${event.amount.toStringAsFixed(0)}...',
    ));

    // Simulate network processing delay
    await Future.delayed(const Duration(milliseconds: 1000));

    emit(state.copyWith(
      status: PaymentStatus.completed,
      processedCount: _actualHandlerInvocations,
      droppedCount: state.tapsCount - _actualHandlerInvocations,
      message: '✅ Payment of \$${event.amount.toStringAsFixed(0)} confirmed successfully!',
    ));
  }


}

// ==========================================
// 2. RESTARTABLE PATTERN (Live Search / Autocomplete)
// ==========================================

sealed class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class QueryChangedEvent extends SearchEvent {
  final String query;
  const QueryChangedEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchState extends Equatable {
  final bool isLoading;
  final String currentQuery;
  final List<String> results;
  final List<String> cancelLog;

  const SearchState({
    required this.isLoading,
    required this.currentQuery,
    required this.results,
    required this.cancelLog,
  });

  factory SearchState.initial() => const SearchState(
        isLoading: false,
        currentQuery: '',
        results: [],
        cancelLog: ['Search initialized with restartable() transformer.'],
      );

  SearchState copyWith({
    bool? isLoading,
    String? currentQuery,
    List<String>? results,
    List<String>? cancelLog,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      currentQuery: currentQuery ?? this.currentQuery,
      results: results ?? this.results,
      cancelLog: cancelLog ?? this.cancelLog,
    );
  }

  @override
  List<Object?> get props => [isLoading, currentQuery, results, cancelLog];
}

class LiveSearchBloc extends Bloc<SearchEvent, SearchState> {
  static const _database = [
    'Flutter Widgets',
    'Flutter Animations',
    'Flutter Architecture',
    'BLoC Pattern',
    'BLoC Concurrency',
    'BLoC Test Suite',
    'Dart 3 Patterns',
    'Dart Sealed Classes',
  ];

  LiveSearchBloc() : super(SearchState.initial()) {
    // RESTARTABLE: When a new query arrives, the previous in-flight handler is CANCELLED!
    on<QueryChangedEvent>(
      _onQueryChanged,
      transformer: restartable(),
    );
  }

  Future<void> _onQueryChanged(
    QueryChangedEvent event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(isLoading: false, currentQuery: '', results: []));
      return;
    }

    final newLog = List<String>.from(state.cancelLog)
      ..add('⚡ Fetching "$query" (previous in-flight cancelled)');

    emit(state.copyWith(
      isLoading: true,
      currentQuery: query,
      cancelLog: newLog,
    ));

    // Simulate search latency
    await Future.delayed(const Duration(milliseconds: 600));

    final matches = _database
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    emit(state.copyWith(
      isLoading: false,
      results: matches,
    ));
  }
}
