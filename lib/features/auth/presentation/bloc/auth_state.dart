abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final bool onboardingCompleted;

  const AuthSuccess({required this.onboardingCompleted});
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);
}
