import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fahrschul_manager/doc/intern/Fahrschule.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:random_password_generator/random_password_generator.dart';

import '../../../src/registration.dart'; // Import Parse SDK

// Define States
class FahrlehrerState extends Equatable {
  @override
  List<Object> get props => [];
}

class FahrlehrerLoading extends FahrlehrerState {}

class FahrlehrerLoaded extends FahrlehrerState {
  final List<ParseObject> fahrlehrer;

  FahrlehrerLoaded(this.fahrlehrer);

  @override
  List<Object> get props => [fahrlehrer];
}

class FahrlehrerError extends FahrlehrerState {
  final String message;

  FahrlehrerError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit Class
class FahrlehrerCubit extends Cubit<FahrlehrerState> {
  FahrlehrerCubit() : super(FahrlehrerLoading());

  Future<void> fetchAllFahrlehrer(String fahrschuleId) async {
    try {
      emit(FahrlehrerLoading());

      // Fetch data from Parse Server
      final list = await fetchAllFahrlehrerFromFahrschule(fahrschuleId);
      emit(FahrlehrerLoaded(list));
    } catch (e) {
      emit(FahrlehrerError("Error: $e"));
    }
  }

  Future<void> _createFahrschueler({required String eMail,required  String firstName,required  String lastName, required String password,ParseObject? fahrlehrer}) async
  {
    try{
     final obj = await createFahrschueler(fahrlehrer: fahrlehrer, eMail: eMail, lastName: lastName, firstName: firstName,password: password, fahrschule: Benutzer().fahrschule!);
    }
    catch(e){
      throw("Creating Fahrschueler failed");
    }
  }
  
  Future<void> sendMail({required String eMail,required  String firstName,required  String lastName, ParseObject? fahrlehrer}) async
  {
    emit(FahrlehrerLoading());
    try {
      final password = RandomPasswordGenerator().randomPassword(
          letters: true, numbers: true, specialChar: true, uppercase: true);
      await _createFahrschueler(eMail: eMail, firstName: firstName, lastName: lastName, password: password, fahrlehrer: fahrlehrer);
      String message = """
Hallo $firstName $lastName,

für Sie wurde ein Konto errichtet in der App FahrschulManager.
Ihre anmelde Daten lauten:

E-Mail: $eMail
Password: $password

Sie wurden von ${Benutzer().dbUser!.get<String>("Vorname")} ${Benutzer().dbUser!.get<String>("Name")} eingeladen
""";
      String username = "fahrschulmanagerteam@gmail.com";
      //TODO verschlüsseln
      String appPassword = "ezbc lbxd dnlv euyp";
      final smtpServer = gmail(username, appPassword);

      // Create our message.
      final mail = Message()
        ..from = Address(username, 'Team FahrschulManager')
        ..recipients.add(eMail)
        ..subject = 'Konto erstellung - Fahrschüler'
        ..text = message;
      final sendReport = await send(mail, smtpServer);
  }catch(e)
  {
      emit(FahrlehrerError("Error: $e"));
  }
}}
