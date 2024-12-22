abstract class PasswordChangeEvent {}

class ChangePasswordEvent extends PasswordChangeEvent {
  final String password;

  ChangePasswordEvent(this.password);
}