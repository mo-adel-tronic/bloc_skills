import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_repository.dart';

// Events
sealed class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserRequested extends UserProfileEvent {
  final String userId;
  const FetchUserRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ResetUserRequested extends UserProfileEvent {
  const ResetUserRequested();
}

// States
sealed class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileSuccess extends UserProfileState {
  final UserData user;
  const UserProfileSuccess(this.user);

  @override
  List<Object?> get props => [user.id, user.name, user.email, user.role];
}

class UserProfileError extends UserProfileState {
  final String error;
  const UserProfileError(this.error);

  @override
  List<Object?> get props => [error];
}

// BLoC injected with UserRepository
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserRepository repository;

  UserProfileBloc({required this.repository})
      : super(const UserProfileInitial()) {
    on<FetchUserRequested>(_onFetchUser);
    on<ResetUserRequested>(_onResetUser);
  }

  Future<void> _onFetchUser(
    FetchUserRequested event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());
    try {
      final user = await repository.fetchUser(event.userId);
      emit(UserProfileSuccess(user));
    } catch (e) {
      emit(UserProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onResetUser(
    ResetUserRequested event,
    Emitter<UserProfileState> emit,
  ) {
    emit(const UserProfileInitial());
  }
}
