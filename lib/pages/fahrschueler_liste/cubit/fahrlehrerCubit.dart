import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fahrschul_manager/doc/intern/Fahrschule.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart'; // Import Parse SDK

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
}
