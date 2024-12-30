import 'package:fahrschul_manager/doc/intern/Fahrstunde.dart';

abstract class HomePageState {}

class DataLoading extends HomePageState {}

class DataLoaded extends HomePageState {
  final int activeCount;
  final int passiveCount;
  final double percentActive;
  final double percentPassive;
  final List<Fahrstunde> appointments;

  DataLoaded({
    required this.activeCount,
    required this.passiveCount,
    required this.percentActive,
    required this.percentPassive,
    required this.appointments
  });
}

class DataError extends HomePageState {
  final String message;

  DataError(this.message);
}