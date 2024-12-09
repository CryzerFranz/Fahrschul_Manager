import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class FahrschuelerListState {}

class DataLoading extends FahrschuelerListState {}

class DataLoaded extends FahrschuelerListState {
  final List<ParseObject> data;
  DataLoaded(this.data);
}

class DataError extends FahrschuelerListState {
  final String message;
  DataError(this.message);
}
