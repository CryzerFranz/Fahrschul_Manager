import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../src/db_classes/fahrstunde.dart';

abstract class HomepageFahrschuelerCubitState {}

class CubitLoading extends HomepageFahrschuelerCubitState {}

class CubitLoaded extends HomepageFahrschuelerCubitState {
  final List<Fahrstunde> appointments;
  CubitLoaded(this.appointments);
}

class CubitError extends HomepageFahrschuelerCubitState {
  final String message;
  CubitError(this.message);
}

class HomepageFahrschuelerCubit extends Cubit<HomepageFahrschuelerCubitState> {
  HomepageFahrschuelerCubit() : super(CubitLoading());

  Future<void> fetchAppointmentsToSignIn() async {
    emit(CubitLoading());
    try {
      List<Fahrstunde> appointments = [];
      final appointmentsAsParseObject = await fetchFahrstundenFromFahrlehrer();
      for(var obj in appointmentsAsParseObject)
      {
        appointments.add(Fahrstunde(eventId: obj.objectId, date: obj.get<DateTime>("Datum")!, endDate: obj.get<DateTime>("EndDatum")!, fahrschueler:  null, fahrzeug: obj.get<ParseObject>("Fahrzeug")));
      }
      emit(CubitLoaded(appointments));    
    } catch (e) {
      emit(CubitError("Network Error"));
    }
  }

  Future<void> transfromAppointsments(List<ParseObject> objs) async {
    emit(CubitLoading());
    try {
      List<Fahrstunde> appointments = [];
      for(var obj in objs)
      {
        appointments.add(Fahrstunde(eventId: obj.objectId, date: obj.get<DateTime>("Datum")!, endDate: obj.get<DateTime>("EndDatum")!, fahrschueler:  null, fahrzeug: obj.get<ParseObject>("Fahrzeug")));
      }
      emit(CubitLoaded(appointments));    
    } catch (e) {
      emit(CubitError("Network Error"));
    }
  }

  Future<void> registerToAppointment(String id) async {
    emit(CubitLoading());
    try {
      final isRegistered = await registerUserToFahrstunde(id: id);
      if(!isRegistered)
      {
        throw();
      }    
    } catch (e) {
      emit(CubitError("Network Error"));
    }
  }
}

//List<Fahrstunde> appointments = [];