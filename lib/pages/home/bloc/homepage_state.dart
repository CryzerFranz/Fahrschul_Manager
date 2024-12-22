abstract class HomePageState {}

class DataLoading extends HomePageState {}

class DataLoaded extends HomePageState {
  final int activeCount;
  final int passiveCount;
  final double percentActive;
  final double percentPassive;

  DataLoaded({
    required this.activeCount,
    required this.passiveCount,
    required this.percentActive,
    required this.percentPassive,
  });
}

class DataError extends HomePageState {
  final String message;

  DataError(this.message);
}