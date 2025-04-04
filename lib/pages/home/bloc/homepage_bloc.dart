import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:fahrschul_manager/pages/home/bloc/homePage_Event.dart';
import 'package:fahrschul_manager/pages/home/bloc/homePage_State.dart';
import 'package:fahrschul_manager/src/db_classes/fahrstunde.dart';
import 'package:fahrschul_manager/src/db_classes/fahrzeug.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  HomePageBloc() : super(DataLoading()) {
    on<FetchData>(_onFetchData);
  }

  Future<void> _onFetchData(
      FetchData event, Emitter<HomePageState> emit) async {
    emit(DataLoading());
    try {
        final int? activeFahrschueler = await Benutzer().countFahrschuelerByState(state: stateActive);
        final int? passiveFahrschueler = await Benutzer().countFahrschuelerByState(state: statePassive);
        if(activeFahrschueler == null || passiveFahrschueler == null)
        {
          throw("Query failed");
        }
        int total = activeFahrschueler + passiveFahrschueler;
        double activePercentage = (activeFahrschueler / total) * 100;
        double passivePercentage = (passiveFahrschueler / total) * 100;
        List<ParseObject> nextFahrstunden = await retrieveUpcomingFahrstunden();
        List<Fahrstunde> appointments = [];

        for(ParseObject fahrstunde in nextFahrstunden)
        {
          ParseObject? fahrzeug = fahrstunde.get<ParseObject>("Fahrzeug");
          ParseObject? fahrschueler = fahrstunde.get<ParseObject>("Fahrschueler");
          if(fahrzeug != null)
          {
           fahrzeug = await fetchFahrzeugById(Benutzer().fahrschule!, fahrzeug.objectId!);
          }
          appointments.add(Fahrstunde(date: fahrstunde.get<DateTime>("Datum")!, endDate: fahrstunde.get<DateTime>("EndDatum")!, fahrschueler:  fahrschueler, fahrzeug: fahrzeug));
        }
        emit(DataLoaded(appointments: appointments, activeCount: activeFahrschueler, passiveCount: passiveFahrschueler, percentActive: activePercentage, percentPassive: passivePercentage));
    } catch (e) {
      emit(DataError('Failed to fetch user data.'));
    }
  }
}