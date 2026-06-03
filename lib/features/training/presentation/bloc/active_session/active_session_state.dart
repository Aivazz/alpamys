import 'package:flutter/foundation.dart';

@immutable
class ActiveSessionState {
  final int secondsElapsed;
  final Map<String, List<Map<String, dynamic>>>
  exerciseProgress; // Изменения весов/повторений
  final int restSecondsLeft; // Время отдыха (0 если отдыха нет)
  final bool isFinished;
  final bool isLoading;

  const ActiveSessionState({
    required this.secondsElapsed,
    required this.exerciseProgress,
    required this.restSecondsLeft,
    this.isFinished = false,
    this.isLoading = false,
  });

  factory ActiveSessionState.initial() {
    return const ActiveSessionState(
      secondsElapsed: 0,
      exerciseProgress: {},
      restSecondsLeft: 0,
    );
  }

  ActiveSessionState copyWith({
    int? secondsElapsed,
    Map<String, List<Map<String, dynamic>>>? exerciseProgress,
    int? restSecondsLeft,
    bool? isFinished,
    bool? isLoading,
  }) {
    return ActiveSessionState(
      secondsElapsed: secondsElapsed ?? this.secondsElapsed,
      exerciseProgress: exerciseProgress ?? this.exerciseProgress,
      restSecondsLeft: restSecondsLeft ?? this.restSecondsLeft,
      isFinished: isFinished ?? this.isFinished,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
