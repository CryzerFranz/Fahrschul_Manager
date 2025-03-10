import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class FahrzeugAddState {}

class DataLoading extends FahrzeugAddState {}

class DataLoaded extends FahrzeugAddState {
  final List<ParseObject> getriebeList;
  final List<ParseObject> markeList;
  final List<ParseObject> fahrzeugtypList;
  

  DataLoaded({
    required this.getriebeList,
    required this.markeList,
    required this.fahrzeugtypList,

  });
}

class DataError extends FahrzeugAddState {
  final String message;

  DataError(this.message);
}