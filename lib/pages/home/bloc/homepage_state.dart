import 'package:fahrschul_manager/doc/intern/Fahrstunde.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class HomePageState {}

class DataLoading extends HomePageState {}

class DataLoaded extends HomePageState {
  final int activeCount;
  final int passiveCount;
  final double percentActive;
  final double percentPassive;
  final Fahrstunde? nextFahrstunde;

  DataLoaded({
    required this.activeCount,
    required this.passiveCount,
    required this.percentActive,
    required this.percentPassive,
    required this.nextFahrstunde
  });
}

class DataError extends HomePageState {
  final String message;

  DataError(this.message);
}