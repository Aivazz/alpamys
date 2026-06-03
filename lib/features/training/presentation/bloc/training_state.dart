// lib/features/training/presentation/bloc/training_state.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class TrainingState {
  const TrainingState();
}

class TrainingInitialState extends TrainingState {}

class TrainingLoadingState extends TrainingState {}

class TrainingLoadedState extends TrainingState {
  final List<dynamic> workoutDays; // Список дней с бэкенда (модели WorkoutDay)
  final Set<String>
  completedExercises; // Множество ID/имен выполненных упражнений

  const TrainingLoadedState({
    required this.workoutDays,
    required this.completedExercises,
  });

  // Метод copyWith для иммутабельного обновления состояния без триггера полной переинициализации
  TrainingLoadedState copyWith({
    List<dynamic>? workoutDays,
    Set<String>? completedExercises,
  }) {
    return TrainingLoadedState(
      workoutDays: workoutDays ?? this.workoutDays,
      completedExercises: completedExercises ?? this.completedExercises,
    );
  }
}

class TrainingErrorState extends TrainingState {
  final String errorMessage;

  const TrainingErrorState({required this.errorMessage});
}
