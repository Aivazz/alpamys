// lib/features/training/presentation/bloc/training_event.dart
import 'package:flutter/foundation.dart';

@immutable
abstract class TrainingEvent {
  const TrainingEvent();
}

// Событие для первоначальной загрузки плана с бэкенда Go
class FetchWorkoutPlanEvent extends TrainingEvent {}

// Событие для отметки упражнения выполненным/невыполненным
class ToggleExerciseCompletionEvent extends TrainingEvent {
  final String exerciseName;

  const ToggleExerciseCompletionEvent({required this.exerciseName});
}
