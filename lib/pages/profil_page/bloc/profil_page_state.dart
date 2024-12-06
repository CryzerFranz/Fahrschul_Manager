abstract class ProfilPageState {}

class DataLoading extends ProfilPageState {}

class DataLoaded extends ProfilPageState {
  final String vorname;
  final String nachname;
  final String email;
  final String fahrschuleName;

  DataLoaded({
    required this.vorname,
    required this.nachname,
    required this.email,
    required this.fahrschuleName,
  });
}

class DataError extends ProfilPageState {
  final String message;

  DataError(this.message);
}