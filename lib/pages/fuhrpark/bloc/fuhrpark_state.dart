import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class FuhrparkState {}

class DataLoading extends FuhrparkState {}

class DataLoaded extends FuhrparkState {
  final List<ParseObject> fahrzeuginfos;
  

  DataLoaded({
    required this.fahrzeuginfos,


  });
}

class DataError extends FuhrparkState {
  final String message;

  DataError(this.message);
}