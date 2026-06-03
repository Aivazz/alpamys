// lib/features/training/presentation/bloc/training_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/training_repository.dart';
import 'training_event.dart';
import 'training_state.dart';

class TrainingBloc extends Bloc<TrainingEvent, TrainingState> {
  final TrainingRepository repository;
  final Set<String> _completedExercisesRegistry = {};

  TrainingBloc({required this.repository}) : super(TrainingInitialState()) {
    on<FetchWorkoutPlanEvent>(_onFetchWorkoutPlan);
    on<ToggleExerciseCompletionEvent>(_onToggleExerciseCompletion);
  }

  Future<void> _onFetchWorkoutPlan(
    FetchWorkoutPlanEvent event,
    Emitter<TrainingState> emit,
  ) async {
    emit(TrainingLoadingState());
    try {
      final planData = await repository.getRemoteWorkoutPlan();
      emit(
        TrainingLoadedState(
          workoutDays: planData,
          completedExercises: Set.from(_completedExercisesRegistry),
        ),
      );
    } catch (e) {
      emit(
        TrainingErrorState(
          errorMessage: 'Antrenman planı yüklenemedi: ${e.toString()}',
        ),
      );
    }
  }

  void _onToggleExerciseCompletion(
    ToggleExerciseCompletionEvent event,
    Emitter<TrainingState> emit,
  ) {
    if (state is TrainingLoadedState) {
      final currentState = state as TrainingLoadedState;

      if (_completedExercisesRegistry.contains(event.exerciseName)) {
        _completedExercisesRegistry.remove(event.exerciseName);
      } else {
        _completedExercisesRegistry.add(event.exerciseName);
      }

      emit(
        currentState.copyWith(
          completedExercises: Set.from(_completedExercisesRegistry),
        ),
      );
    }
  }
}
