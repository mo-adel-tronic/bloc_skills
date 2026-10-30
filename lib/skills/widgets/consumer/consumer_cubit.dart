import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskInProgress extends TaskState {
  final double progress; // 0.0 to 1.0

  const TaskInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class TaskSuccess extends TaskState {
  final String fileName;
  const TaskSuccess(this.fileName);

  @override
  List<Object?> get props => [fileName];
}

class TaskFailure extends TaskState {
  final String error;
  const TaskFailure(this.error);

  @override
  List<Object?> get props => [error];
}

/// ConsumerCubit simulates an asynchronous file export/download task.
/// Demonstrates BlocConsumer handling both UI rendering and side-effects.
class ConsumerCubit extends Cubit<TaskState> {
  Timer? _timer;

  ConsumerCubit() : super(const TaskInitial());

  void startDownload({bool shouldFail = false}) {
    if (state is TaskInProgress) return;

    _timer?.cancel();
    double currentProgress = 0.0;
    emit(const TaskInProgress(0.0));

    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      currentProgress += 0.25;

      if (shouldFail && currentProgress >= 0.75) {
        timer.cancel();
        emit(const TaskFailure('Network dropped at 75% download.'));
        return;
      }

      if (currentProgress >= 1.0) {
        timer.cancel();
        emit(const TaskSuccess('flutter_bloc_guide.pdf (2.4 MB)'));
      } else {
        emit(TaskInProgress(currentProgress));
      }
    });
  }

  void reset() {
    _timer?.cancel();
    emit(const TaskInitial());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
