import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

abstract class FuhrparkCubitState{}

class FuhrparkCubitLoading extends FuhrparkCubitState{}
class FuhrparkCubitLoaded extends FuhrparkCubitState{
  final ParseObject fahrzeug;

  FuhrparkCubitLoaded(this.fahrzeug);}
class FuhrparkCubitError extends FuhrparkCubitState{
  final String message;

  FuhrparkCubitError(this.message);
}

class FuhrparkCubit extends Cubit<FuhrparkCubitState>{
  final ParseObject fahrzeug;
  FuhrparkCubit(this.fahrzeug) : super(FuhrparkCubitLoaded(fahrzeug));

Future<void> deleteFahrzeug({
  required ParseObject fahrzeug
})async{
emit(FuhrparkCubitLoading());
try {
  final response=await fahrzeug.delete();
  if(!response.success){
    emit(FuhrparkCubitError("error"));
  }



}catch(e){emit(FuhrparkCubitError("Network Error"));}

} 



}



