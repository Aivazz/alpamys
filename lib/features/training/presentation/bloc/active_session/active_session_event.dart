abstract class ActiveSessionEvent {
  const ActiveSessionEvent();
}

class StartSessionEvent extends ActiveSessionEvent {
  final Map<String, dynamic> workoutData;
  const StartSessionEvent(this.workoutData);
}

class TimerTickedEvent extends ActiveSessionEvent {
  final int secondsElapsed;
  const TimerTickedEvent(this.secondsElapsed);
}

class UpdateSetDataEvent extends ActiveSessionEvent {
  final String exerciseName;
  final int setIndex;
  final double? weight;
  final int? reps;

  const UpdateSetDataEvent({
    required this.exerciseName,
    required this.setIndex,
    this.weight,
    this.reps,
  });
}

class CompleteSetEvent extends ActiveSessionEvent {
  final String exerciseName;
  final int setIndex;
  final int restSeconds;

  const CompleteSetEvent({
    required this.exerciseName,
    required this.setIndex,
    required this.restSeconds,
  });
}

class RestTickEvent extends ActiveSessionEvent {
  final int restSecondsLeft;
  const RestTickEvent(this.restSecondsLeft);
}

class FinishWorkoutEvent extends ActiveSessionEvent {}
