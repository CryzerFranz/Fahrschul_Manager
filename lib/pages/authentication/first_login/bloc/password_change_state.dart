abstract class PasswordChangeState {}

class Passive extends PasswordChangeState{}

class Executing extends PasswordChangeState {}

class ExecutingDone extends PasswordChangeState {}

class ExecutingError extends PasswordChangeState {
  final String message;
  ExecutingError(this.message);
}
