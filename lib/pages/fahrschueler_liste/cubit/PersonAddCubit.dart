import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fahrschul_manager/doc/intern/Fahrschule.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:random_password_generator/random_password_generator.dart';

import '../../../src/registration.dart'; // Import Parse SDK

// Define States
class PersonAddState extends Equatable {
  @override
  List<Object> get props => [];
}

class PersonAddLoading extends PersonAddState {}

class PersonAddLoaded extends PersonAddState {
  final List<ParseObject> fahrlehrer;

  PersonAddLoaded(this.fahrlehrer);

  @override
  List<Object> get props => [fahrlehrer];
}

class PersonAddError extends PersonAddState {
  final String message;

  PersonAddError(this.message);

  @override
  List<Object> get props => [message];
}

// Cubit Class
class PersonAddCubit extends Cubit<PersonAddState> {
  PersonAddCubit() : super(PersonAddLoading());

  Future<void> fetchAllFahrlehrer(String fahrschuleId) async {
    try {
      emit(PersonAddLoading());

      // Fetch data from Parse Server
      final list = await fetchAllFahrlehrerFromFahrschule(fahrschuleId);
      emit(PersonAddLoaded(list));
    } catch (e) {
      emit(PersonAddError("Error: $e"));
    }
  }

  //Wenn wir einen Fahrlehrer erstellen wollen, brauchen wir keine liste der Fahrlehrer von der
  //Datenbank abzugreifen. Aber wir müssen den initial state FahrlehrerLoading überschreiben, sonst
  //hängen wir im loading screen fest.
  Future<void>dummyFetch() async 
  {
    emit(PersonAddLoaded(const []));
  }

  Future<void> _createPerson({required String eMail,required  String firstName,required  String lastName, required String password, required bool shouldCreateFahrlehrer,ParseObject? fahrlehrer}) async
  {
    try{
      if(!shouldCreateFahrlehrer) {
        final obj = await createFahrschueler(fahrlehrer: fahrlehrer, eMail: eMail, lastName: lastName, firstName: firstName,password: password, fahrschule: Benutzer().fahrschule!);
      }
      else{
        await createFahrlehrer(eMail: eMail, fahrschulObject: Benutzer().fahrschule!, name: lastName, vorname: firstName, password: password, createSession: false);
      }
    }
    catch(e){
      throw("Creating person failed");
    }
  }
  
  Future<void> sendMail({required String eMail,required  String firstName,required  String lastName,required bool createFahrlehrer, ParseObject? fahrlehrer}) async
  {
    emit(PersonAddLoading());
    try {
      final password = RandomPasswordGenerator().randomPassword(
          letters: true, numbers: true, specialChar: true, uppercase: true);
      await _createPerson(shouldCreateFahrlehrer: createFahrlehrer,eMail: eMail, firstName: firstName, lastName: lastName, password: password, fahrlehrer: fahrlehrer);
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
      emit(PersonAddError("Error: $e"));
  }
}}
