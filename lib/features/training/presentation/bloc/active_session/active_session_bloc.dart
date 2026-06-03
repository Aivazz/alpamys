import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../../../../core/services/api_service.dart';
import 'active_session_event.dart';
import 'active_session_state.dart';

class ActiveSessionBloc extends Bloc<ActiveSessionEvent, ActiveSessionState> {
  StreamSubscription<int>? _timerSubscription;
  StreamSubscription<int>? _restSubscription;
  late Map<String, dynamic> _currentWorkoutData;

  ActiveSessionBloc() : super(ActiveSessionState.initial()) {
    on<StartSessionEvent>(_onStartSession);
    on<TimerTickedEvent>(_onTimerTicked);
    on<UpdateSetDataEvent>(_onUpdateSetData);
    on<CompleteSetEvent>(_onCompleteSet);
    on<RestTickEvent>(_onRestTick);
    on<FinishWorkoutEvent>(_onFinishWorkout);
  }

  void _onStartSession(
    StartSessionEvent event,
    Emitter<ActiveSessionState> emit,
  ) {
    _currentWorkoutData = event.workoutData;
    _timerSubscription?.cancel();

    // Запуск главного таймера тренировки
    _timerSubscription = Stream.periodic(
      const Duration(seconds: 1),
      (x) => x + 1,
    ).listen((tick) => add(TimerTickedEvent(tick)));

    // Формируем изначальную структуру подходов по умолчанию на базе плана
    final Map<String, List<Map<String, dynamic>>> progress = {};
    final exercises = event.workoutData['exercises'] as List<dynamic>? ?? [];

    for (var ex in exercises) {
      final name = ex['name'] as String;
      // Допустим, по умолчанию делаем 4 подхода
      progress[name] = List.generate(
        4,
        (index) => {
          'set_number': index + 1,
          'weight': 60.0, // Дефолтный подстановочный вес
          'reps': 10, // Дефолтные повторения
          'is_completed': false,
        },
      );
    }

    emit(
      ActiveSessionState(
        secondsElapsed: 0,
        exerciseProgress: progress,
        restSecondsLeft: 0,
      ),
    );
  }

  void _onTimerTicked(
    TimerTickedEvent event,
    Emitter<ActiveSessionState> emit,
  ) {
    emit(state.copyWith(secondsElapsed: event.secondsElapsed));
  }

  void _onUpdateSetData(
    UpdateSetDataEvent event,
    Emitter<ActiveSessionState> emit,
  ) {
    final currentProgress = Map<String, List<Map<String, dynamic>>>.from(
      state.exerciseProgress,
    );
    final sets = List<Map<String, dynamic>>.from(
      currentProgress[event.exerciseName]!,
    );

    if (event.weight != null) sets[event.setIndex]['weight'] = event.weight;
    if (event.reps != null) sets[event.setIndex]['reps'] = event.reps;

    currentProgress[event.exerciseName] = sets;
    emit(state.copyWith(exerciseProgress: currentProgress));
  }

  void _onCompleteSet(
    CompleteSetEvent event,
    Emitter<ActiveSessionState> emit,
  ) {
    final currentProgress = Map<String, List<Map<String, dynamic>>>.from(
      state.exerciseProgress,
    );
    final sets = List<Map<String, dynamic>>.from(
      currentProgress[event.exerciseName]!,
    );

    sets[event.setIndex]['is_completed'] =
        !sets[event.setIndex]['is_completed'];
    currentProgress[event.exerciseName] = sets;

    emit(state.copyWith(exerciseProgress: currentProgress));

    // Если подход отметили как выполненный, запускаем Rest-Timer отдыха
    if (sets[event.setIndex]['is_completed'] == true && event.restSeconds > 0) {
      _restSubscription?.cancel();
      emit(state.copyWith(restSecondsLeft: event.restSeconds));

      _restSubscription =
          Stream.periodic(
                const Duration(seconds: 1),
                (x) => event.restSeconds - x - 1,
              )
              .take(event.restSeconds)
              .listen((secondsLeft) => add(RestTickEvent(secondsLeft)));
    }
  }

  void _onRestTick(RestTickEvent event, Emitter<ActiveSessionState> emit) {
    emit(state.copyWith(restSecondsLeft: event.restSecondsLeft));
  }

  Future<void> _onFinishWorkout(
    FinishWorkoutEvent event,
    Emitter<ActiveSessionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    _timerSubscription?.cancel();
    _restSubscription?.cancel();

    try {
      // Собираем массив для отправки на Go бэкенд
      final List<Map<String, dynamic>> exercisesPayload = [];

      state.exerciseProgress.forEach((exName, setsList) {
        final List<Map<String, dynamic>> setsPayload = [];
        for (var s in setsList) {
          if (s['is_completed'] == true) {
            setsPayload.add({
              'set_number': s['set_number'],
              'weight': s['weight'],
              'reps': s['reps'],
            });
          }
        }
        if (setsPayload.isNotEmpty) {
          exercisesPayload.add({'exercise_name': exName, 'sets': setsPayload});
        }
      });

      final token =
          "mock-firebase-token"; // В проде: await ApiService.getIdToken();
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/user/workout/finish'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'workout_title': _currentWorkoutData['title'] ?? 'Antrenman',
          'duration_seconds': state.secondsElapsed,
          'exercises': exercisesPayload,
        }),
      );

      if (response.statusCode == 200) {
        emit(state.copyWith(isFinished: true, isLoading: false));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (_) {
      emit(
        state.copyWith(isFinished: true, isLoading: false),
      ); // Оффлайн-фоллбэк
    }
  }

  @override
  Future<void> close() {
    _timerSubscription?.cancel();
    _restSubscription?.cancel();
    return super.close();
  }
}
