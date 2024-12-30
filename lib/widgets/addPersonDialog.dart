import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/AsyncFahrschuelerDataValidationFormBloc.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/cubit/fahrlehrerCubit.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/snackbar.dart';
import 'package:fahrschul_manager/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

Future<void> dialogBuilderAddNew(BuildContext context, bool createFahrlehrer) {
    late FahrlehrerCubit cubit;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext dialogContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        final formBloc =
            context.read<AsyncFahrschuelerDataValidationFormBloc>();

        return BlocProvider(
          create: (context) {
            cubit = FahrlehrerCubit();
            if(!createFahrlehrer) {
              cubit.fetchAllFahrlehrer(Benutzer().fahrschule!.objectId!);
            }
            else{
              cubit.dummyFetch();
            }
            return cubit;
          },
          child: FormBlocListener<AsyncFahrschuelerDataValidationFormBloc,
              String, String>(
            onSuccess: (context, state)  {
              cubit.sendMail(createFahrlehrer: createFahrlehrer, eMail: formBloc.emailFormBloc.value, lastName: formBloc.lastNameFormBloc.value, firstName: formBloc.firstNameFormBloc.value, fahrlehrer: formBloc.fahrlehrerDropDownBloc.value);
              formBloc.emailFormBloc.clear();
              formBloc.firstNameFormBloc.clear();
              formBloc.lastNameFormBloc.clear();

              ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                showSuccessSnackbar("Fahrschüler wurde erstellt", "HURA!"));
              Navigator.of(dialogContext).pop();
               // Close dialog on success
            },
            onFailure: (context, state) {},
            child: BlocBuilder<FahrlehrerCubit, FahrlehrerState>(
              builder: (context, blocState) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    formBloc.emailFormBloc.clear();
                    formBloc.firstNameFormBloc.clear();
                    formBloc.lastNameFormBloc.clear();
                    Navigator.of(dialogContext).pop();
                  },
                  child: Center(
                    child: GestureDetector(
                      onTap: () {}, // Prevent tap propagation
                      child: Dialog(
                        backgroundColor: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            border: Border.all(
                              color: mainColor,
                              width: 2.3,
                            ),
                          ),
                          child: Builder(
                            builder: (context) {
                              if(blocState is FahrlehrerError)
                              {
                                return const Center(child: Text("Error"));
                              }
                              return Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topCenter,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 60.0,
                                      left: 20.0,
                                      right: 20.0,
                                      bottom: 15.0,
                                    ),
                                    child: blocState is FahrlehrerLoading
                                        ? SizedBox(height: 300, child: loadingScreen())
                                        : editWindow(
                                            formBloc, (blocState as FahrlehrerLoaded).fahrlehrer, createFahrlehrer), // blocState kann in diesen Moment nur FahrlehrerLoaded sein
                                  ),
                                  Positioned(
                                    top: -40,
                                    child: Container(
                                      // Border für CircleAvatar
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: mainColor,
                                          width: 2.3,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor:
                                            tabBarMainColorShade100,
                                        radius: 40,
                                        child: Icon(
                                          blocState is FahrlehrerLoaded
                                              ? Icons.person_add
                                              : Icons.sync,
                                          size: 60,
                                          color: mainColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Rechter Button
                                  Positioned(
                                    top: -15,
                                    right: -15,
                                    child: Container(
                                      // Border für CircleAvatar
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: tabBarRedShade300,
                                          width: 2.3,
                                        ),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          //context.read<CalendarEventBloc>().add(ResetStateEvent());
                                          formBloc.emailFormBloc.clear();
                                          formBloc.firstNameFormBloc.clear();
                                          formBloc.lastNameFormBloc.clear();
                                          Navigator.of(context).pop();
                                        },
                                        child: const CircleAvatar(
                                          backgroundColor: tabBarRedShade100,
                                          radius: 15,
                                          child: Icon(
                                            Icons.close,
                                            color: tabBarRedShade300,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  SingleChildScrollView editWindow(AsyncFahrschuelerDataValidationFormBloc formBloc, List<ParseObject> fahrlehrer, bool createFahrlehrer) {
    formBloc.fahrlehrerDropDownBloc.updateItems(fahrlehrer);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFieldBlocBuilder(
            textFieldBloc: formBloc.firstNameFormBloc,
            decoration: inputDecoration('Vorname'),
            suffixButton: SuffixButton.clearText,

          ),
          const SizedBox(height: 16.0),
          TextFieldBlocBuilder(
            textFieldBloc: formBloc.lastNameFormBloc,
            suffixButton: SuffixButton.clearText,
            decoration: inputDecoration('Nachname'),
          ),
          const SizedBox(height: 16.0),
          TextFieldBlocBuilder(
            textFieldBloc: formBloc.emailFormBloc,
            suffixButton: SuffixButton.asyncValidating,
            decoration: inputDecoration('E-Mail'),
          ),
          const SizedBox(height: 16.0),
          if(!createFahrlehrer)...[
          DropdownFieldBlocBuilder(
            selectFieldBloc: formBloc.fahrlehrerDropDownBloc,
            itemBuilder: (context, value) => FieldItem(
              child: Text(
                  "${value.get<String>("Name") ?? ''}, ${value.get<String>("Vorname") ?? ''}"),
            ),
            decoration: const InputDecoration(
              labelText: "Fahrlehrer wählen",
              prefixIcon: Icon(Icons.face),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: mainColor, width: 2),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: mainColor, width: 1),
              ),
            ),
          ),],
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: formBloc.submit,
              style: stadiumButtonStyle(),
              child: const Text('Hinzufügen'),
            ),
          ),
        ],
      ),
    );
  }