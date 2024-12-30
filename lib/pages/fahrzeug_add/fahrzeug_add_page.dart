import 'package:fahrschul_manager/pages/fahrzeug_add/bloc/fahrzeug_add_bloc.dart';
import 'package:fahrschul_manager/pages/fahrzeug_add/bloc/fahrzeug_add_event.dart';
import 'package:fahrschul_manager/pages/fahrzeug_add/bloc/fahrzeug_add_state.dart';
import 'package:fahrschul_manager/src/form_blocs/AsyncFahrzeugAddValidationFormBloc.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class FahrzeugAddPage extends StatelessWidget {
  const FahrzeugAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formBloc = context.read<AsyncFahrzeugAddValidationFormBloc>();
    context.read<FahrzeugAddBloc>().add(FetchFahrzeugAddEvent());

    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<FahrzeugAddBloc, FahrzeugAddState>(
          builder: (context, state) {
        if (state is DataLoading) {
          return loadingScreen(height_: 150, width_: 150);
        } else if (state is DataLoaded) {
          formBloc.markeDropDownBloc.updateItems(state.markeList);
          formBloc.typDropDownBloc.updateItems(state.fahrzeugtypList);
          formBloc.getriebeDropDownBloc.updateItems(state.getriebeList);

          return FormBlocListener<AsyncFahrzeugAddValidationFormBloc, String,
              String>(
            onSuccess: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Fahrzeug erfolgreich hinzugefügt!")),
              );
            },
            onFailure: (context, state) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text("Fehler: ${state.failureResponse}")),
                );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [

                  DropdownFieldBlocBuilder(
                    selectFieldBloc: formBloc.markeDropDownBloc,
                    decoration: inputDecoration("Marke"),
                    itemBuilder: (context, value) => FieldItem(
                      child: Text(value.get<String>("Name")!),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownFieldBlocBuilder(
                    selectFieldBloc: formBloc.typDropDownBloc,
                    decoration: inputDecoration("Typ"),
                    itemBuilder: (context, value) => FieldItem(
                      child: Text(value.get<String>("Typ")!),
                    ),
                  ),
                                    const SizedBox(height: 10),
                  DropdownFieldBlocBuilder(
                    selectFieldBloc: formBloc.getriebeDropDownBloc,
                    decoration: inputDecoration("Getriebe"),
                    itemBuilder: (context, value) => FieldItem(
                      child: Text(value.get<String>("Typ")!),
                    ),
                  ),
                                    TextFieldBlocBuilder(
                    textFieldBloc: formBloc.labelBloc,
                    decoration: inputDecoration("Label"),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  CheckboxFieldBlocBuilder(
                    booleanFieldBloc: formBloc.anhaenger,
                    body: Container(
                      alignment: Alignment.centerLeft,
                      child: const Text('Anhängerkupplung'),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: formBloc.submit,
                    style: stadiumButtonStyle(),
                    child: const Text("Fahrzeug speichern"),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Text("Fehler");
        }
      }),
    );
  }
}
