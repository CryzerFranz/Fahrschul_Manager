import 'package:fahrschul_manager/pages/authentication/first_login/bloc/password_change_event.dart';
import 'package:fahrschul_manager/pages/authentication/first_login/bloc/password_change_state.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../../src/db_classes/user.dart';

class PasswordChangeBloc
    extends Bloc<PasswordChangeEvent, PasswordChangeState> {
  PasswordChangeBloc() : super(Passive()) {
    on<ChangePasswordEvent>(_changePassword);
  }

  Future<void> _changePassword(
      ChangePasswordEvent event, Emitter<PasswordChangeState> emit) async {
    emit(Executing());
    try {
      Benutzer().parseUser!.password = event.password;
      Benutzer().parseUser!.set("firstSession", false);
      final ParseResponse updateResponse = await Benutzer().parseUser!.save();
      if (updateResponse.success) {
        emit(ExecutingDone());
      } else {
        emit(ExecutingError('Failed to fetch data'));
      }
    } catch (e) {
      emit(ExecutingError('Failed to fetch data'));
    }
  }
}
