import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class FahrschulePageState {}

class DataLoading extends FahrschulePageState {}

class DataLoaded extends FahrschulePageState {
  final List<ParseObject> fahrlehrer;
  final List<ParseObject> locations;
  final int currentIndex;

  DataLoaded({
    required this.fahrlehrer,
    required this.locations,
    required this.currentIndex
  });
}

class DataError extends FahrschulePageState {
  final String message;
  DataError(this.message);
}