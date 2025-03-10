

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BooleanFieldState{}

class ChangeReadOnlyState extends BooleanFieldState{
  final bool value;
  ChangeReadOnlyState(this.value);
}


class BooleanFieldCubit extends Cubit<BooleanFieldState>{
  final bool initState;
  BooleanFieldCubit(this.initState) : super(ChangeReadOnlyState(initState));

  Future<void> changeState({required bool value}) async
  {
      emit(ChangeReadOnlyState(value));
  }
}
