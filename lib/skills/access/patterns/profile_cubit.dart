import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfile extends Equatable {
  final String name;
  final int score;
  final String badge;

  const UserProfile({
    required this.name,
    required this.score,
    required this.badge,
  });

  UserProfile copyWith({
    String? name,
    int? score,
    String? badge,
  }) {
    return UserProfile(
      name: name ?? this.name,
      score: score ?? this.score,
      badge: badge ?? this.badge,
    );
  }

  @override
  List<Object?> get props => [name, score, badge];
}

/// ProfileCubit manages a multi-field state to demonstrate
/// fine-grained rebuilds using context.select vs context.watch.
class ProfileCubit extends Cubit<UserProfile> {
  ProfileCubit()
      : super(const UserProfile(
          name: 'Alex Johnson',
          score: 100,
          badge: 'Bronze',
        ));

  void incrementScore() {
    final newScore = state.score + 25;
    String newBadge = state.badge;
    if (newScore >= 200) {
      newBadge = 'Gold';
    } else if (newScore >= 150) {
      newBadge = 'Silver';
    }

    emit(state.copyWith(score: newScore, badge: newBadge));
  }

  void changeName() {
    final names = ['Alex Johnson', 'Samira Reed', 'Elena Rostova', 'Tariq Malik'];
    final currentIndex = names.indexOf(state.name);
    final nextName = names[(currentIndex + 1) % names.length];
    emit(state.copyWith(name: nextName));
  }

  void reset() {
    emit(const UserProfile(
      name: 'Alex Johnson',
      score: 100,
      badge: 'Bronze',
    ));
  }
}
