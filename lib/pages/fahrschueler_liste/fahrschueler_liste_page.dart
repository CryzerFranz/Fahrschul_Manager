import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/Fahrschule.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/AsyncFahrschuelerDataValidationFormBloc.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_bloc.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_event.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/bloc/fahrschueler_liste_state.dart';
import 'package:fahrschul_manager/pages/fahrschueler_liste/cubit/fahrlehrerCubit.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/snackbar.dart';
import 'package:fahrschul_manager/widgets/styles.dart';
import 'package:flutter/material.dart';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class FahrschuelerListePage extends StatelessWidget {
  const FahrschuelerListePage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                bottom: 16.0, left: 16.0, right: 16.0, top: 38),
            child: SegmentedTabControl(
              tabTextColor: Colors.black,
              selectedTabTextColor: Colors.white,
              indicatorPadding: const EdgeInsets.all(4),
              squeezeIntensity: 2,
              tabPadding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: Theme.of(context).textTheme.bodyLarge,
              selectedTextStyle: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              tabs: const [
                SegmentTab(
                  label: "AKTIV",
                  color: tabBarMainColorShade300,
                  backgroundColor: tabBarMainColorShade100,
                ),
                SegmentTab(
                  label: 'PASSIV',
                  backgroundColor: tabBarOrangeShade100,
                  color: tabBarOrangeShade300,
                ),
                SegmentTab(
                  label: 'NEU',
                  backgroundColor: tabBarRedShade100,
                  color: tabBarRedShade300,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 70),
            child: TabBarView(
              physics: BouncingScrollPhysics(),
              children: [
                FahrschuelerListContent(state: stateActive, colors: [
                  tabBarMainColorShade300,
                  tabBarMainColorShade300,
                  tabBarMainColorShade100
                ]),
                FahrschuelerListContent(
                  state: statePassive,
                  colors: [
                    tabBarOrangeShade300,
                    tabBarOrangeShade300,
                    tabBarOrangeShade100
                  ],
                ),
                FahrschuelerListContent(state: stateUnassigned, colors: [
                  tabBarRedShade300,
                  tabBarRedShade300,
                  tabBarRedShade100
                ]),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16.0, left: 16, right: 16, bottom: 125),
              child: Container(
                decoration: BoxDecoration(
                  color: mainColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).canvasColor,
                    width: 9.0, // Thickness of the white border
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add),
                  color: Theme.of(context).canvasColor,
                  iconSize: 30.0, // Size of the icon
                  onPressed: () async {
                    // Handle icon button press

                    // ignore: use_build_context_synchronously
                    _dialogBuilderAddNew(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogBuilderAddNew(BuildContext context) {
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
            cubit.fetchAllFahrlehrer(Benutzer().fahrschule!.objectId!);
            return cubit;
          },
          child: FormBlocListener<AsyncFahrschuelerDataValidationFormBloc,
              String, String>(
            onSuccess: (context, state)  {
              cubit.sendMail(eMail: formBloc.emailFormBloc.value, lastName: formBloc.lastNameFormBloc.value, firstName: formBloc.firstNameFormBloc.value, fahrlehrer: formBloc.fahrlehrerDropDownBloc.value);
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
                                        : _editWindow(
                                            formBloc, (blocState as FahrlehrerLoaded).fahrlehrer), // blocState kann in diesen Moment nur FahrlehrerLoaded sein
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

  SingleChildScrollView _editWindow(AsyncFahrschuelerDataValidationFormBloc formBloc, List<ParseObject> fahrlehrer) {
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
          ),
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
}

class FahrschuelerListContent extends StatelessWidget {
  const FahrschuelerListContent({
    super.key,
    required this.state,
    this.colors = const [mainColor, mainColor, mainColorComplementaryFirst],
  });

  final String state;
  final List<Color> colors;
  @override
  Widget build(BuildContext context) {
    context.read<FahrschuelerListBloc>().add(FetchFahrschuelerListEvent(state));

    return Stack(
      children: [
        BlocBuilder<FahrschuelerListBloc, FahrschuelerListState>(
          builder: (context, blocState) {
            if (blocState is DataLoading) {
              return loadingScreen(height_: 150, width_: 150);
            } else if (blocState is DataLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: blocState.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return displayListEntryContent(
                      context: context,
                      data: blocState.data[index],
                      contentState: state);
                },
              );
            } else if (blocState is DataError) {
              return Center(
                  child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 120),
                  ),
                  Icon(
                    Icons.sentiment_dissatisfied,
                    size: 80,
                    color: Colors.red[600],
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5), // Shadow color
                        spreadRadius: 1, // How far the shadow spreads
                        blurRadius: 10, // The softness of the shadow
                        offset: const Offset(5, 5), // X and Y offset
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text("Keine Fahrschüler"),
                ],
              ));
            } else {
              return const Center(child: Text("No data"));
            }
          },
        ),
      ],
    );
  }

  /// Erstellt den Content für jedes einzelne Listen element
  ///
  /// ### Parameter:
  /// - **`BuildContext` [context]** : BuildContext
  /// - **`ParseObject` [data]** : ParseObject vom ausgewählten Index der Liste
  /// - **`String` [contentState]** : Der Aktuelle Tab
  ///
  /// ### Return value:
  /// - **[Widget]** : UI Element
  Widget displayListEntryContent(
      {required BuildContext context,
      required ParseObject data,
      required String contentState}) {
    IconData icon = contentState != stateActive ? Icons.add : Icons.check;
    return Column(
      children: [
        Row(
          children: [
            Custom3DCard(
              title: "${data.get<String>("Name")!}, "
                  "${data.get<String>("Vorname")!}",
              widget: Text("Fahrstunden: ${data.get("Gesamtfahrstunden")!}"),
              colors: colors,
              width: 0.7,
            ),
            const SizedBox(width: 10),
            Custom3DCard(
              widget: IconButton(
                  onPressed: () {
                    if (contentState == stateActive) {
                      context.read<FahrschuelerListBloc>().add(
                          ChangeStateFahrschuelerEvent(
                              stateDone, stateActive, data));
                    } else {
                      _dialogBuilder(context, data, contentState);
                    }
                  },
                  icon: Icon(icon)),
              colors: [colors.last, colors.first],
              width: 0.17,
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, ParseObject obj, String actualTab) {
    Color actualTabColor300 =
        actualTab == statePassive ? tabBarOrangeShade300 : tabBarRedShade300;
    Color actualTabColor100 =
        actualTab == statePassive ? tabBarOrangeShade100 : tabBarRedShade100;

    Color buttonColor_2 =
        actualTab == statePassive ? tabBarRedShade300 : tabBarOrangeShade300;
    String value_2 =
        actualTab == statePassive ? "Entfernen" : "$statePassive setzen";

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors
              .transparent, // Dialog hintergrundfarbe wird transparenz gesetzt damit wir unseren eigenen gestalten können
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, // Dialog hintergrund farbe
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: actualTabColor300,
                width: 2.3,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: SizedBox(
                    height: 170,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${obj.get<String>("Name")}, ${obj.get<String>("Vorname")}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16.0),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 80.0, right: 80.0),
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<FahrschuelerListBloc>().add(
                                  ChangeStateFahrschuelerEvent(
                                      stateActive, actualTab, obj));
                              Navigator.of(context).pop();
                            },
                            style: stadiumButtonStyle(
                                background: tabBarMainColorShade300),
                            child: const Text("$stateActive setzen"),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 80.0, right: 80.0),
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<FahrschuelerListBloc>().add(
                                  ChangeStateFahrschuelerEvent(
                                      actualTab == statePassive
                                          ? stateUnassigned
                                          : statePassive,
                                      actualTab,
                                      obj));
                              Navigator.of(context).pop();
                            },
                            style:
                                stadiumButtonStyle(background: buttonColor_2),
                            child: Text(value_2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -40,
                  child: Container(
                    // Border für CircleAvatar
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: actualTabColor300,
                        width: 2.3,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: actualTabColor100,
                      radius: 40,
                      child: Icon(
                        Icons.question_mark,
                        size: 60,
                        color: actualTabColor300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
