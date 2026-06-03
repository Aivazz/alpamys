abstract class AuthEvent {
  const AuthEvent();
}

class LoginSubmittedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmittedEvent(this.email, this.password);
}

class SignUpSubmittedEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String password;

  const SignUpSubmittedEvent(this.fullName, this.email, this.password);
}
