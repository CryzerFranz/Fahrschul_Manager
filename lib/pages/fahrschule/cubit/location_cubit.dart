import 'package:fahrschul_manager/src/db_classes/fahrschule.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class LocationState{}

class LocationLoading extends LocationState{}
class LocationLoaded extends LocationState{}
class LocationError extends LocationState{
  final String message;

  LocationError(this.message);
}

class LocationCubit extends Cubit<LocationState>{
  LocationCubit() : super(LocationLoaded());

  Future<void> addLocation({required String strasse, required String hausnummer, required ParseObject ortObject}) async
  {
    try{
      emit(LocationLoading());
      await registerOrtFromFahrschule(fahrschuleObject: Benutzer().fahrschule!, hausnummer: hausnummer, strasse: strasse, ortObject: ortObject);
    }catch(e)
    {
      emit(LocationError("Network error"));
    }
  }
}

