import 'package:fahrschul_manager/pages/fahrschule/cubit/location_cubit.dart';
import 'package:fahrschul_manager/pages/fuhrpark_page.dart';
import 'package:fahrschul_manager/src/form_blocs/AsyncRegistrationValidationFormBloc.dart';
import 'package:fahrschul_manager/widgets/addPersonDialog.dart';
import 'package:fahrschul_manager/widgets/snackbar.dart';
import 'package:fahrschul_manager/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/pages/fahrschule/bloc/fahrschule_page_bloc.dart';
import 'package:fahrschul_manager/pages/fahrschule/bloc/fahrschule_page_event.dart';
import 'package:fahrschul_manager/pages/fahrschule/bloc/fahrschule_page_state.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';

class FahrschulePage extends StatelessWidget {
  const FahrschulePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FahrschulePageBloc>().add(FetchData());

    return BlocBuilder<FahrschulePageBloc, FahrschulePageState>(
      builder: (context, state) {
        if (state is DataLoading) {
          return loadingScreen(height_: 150, width_: 150);
        } else if (state is DataLoaded) {
          return Stack(children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 80.0, bottom: 16, left: 16, right: 16),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Benutzer().fahrschule!.get<String>("Name")!,
                        style: const TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: mainColor,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Custom3DCard(
                        title: "Die Fahrlehrer",
                        colors: const [
                          mainColor,
                          mainColor,
                          tabBarMainColorShade100
                        ],
                        widget: LayoutBuilder(
                          builder: (context, constraints) {
                            final pageController =
                                PageController(); // For page indicator
                            return Stack(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      height: 120,
                                      color: Colors.transparent,
                                      child: PageView.builder(
                                        controller:
                                            pageController, // Assign the controller
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state.fahrlehrer.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            width: constraints.maxWidth,
                                            alignment: Alignment.center,
                                            child: fahrlehrerView(
                                                state.fahrlehrer[index]),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SmoothPageIndicator(
                                      // Connected to PageView via controller
                                      controller: pageController,
                                      count: state.fahrlehrer.length,
                                      effect: const WormEffect(
                                        dotHeight: 12,
                                        dotWidth: 12,
                                        activeDotColor:
                                            mainColorComplementarySecond,
                                        dotColor:
                                            mainColorComplementaryFirstShade100,
                                      ),
                                    ),
                                  ],
                                ),
                                if (Benutzer().isFahrlehrer!) ...[
                                  Positioned(
                                    bottom: 0, // Position the button at the top
                                    right:
                                        10, // Position the button to the right
                                    child: CircleAvatar(
                                      radius: 18, // Adjust size
                                      backgroundColor:
                                          mainColorComplementarySecond, // Button color
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.person_add,
                                          size: 20,
                                        ), // Car icon
                                        onPressed: () async {
                                          dialogBuilderAddNew(context, true);
                                          // Action when button is pressed
                                        },
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Custom3DCard(
                        title: "Die Standorte",
                        colors: const [
                          mainColor,
                          mainColor,
                          tabBarMainColorShade100
                        ],
                        widget: LayoutBuilder(
                          builder: (context, constraints) {
                            final pageController =
                                PageController(); // Für den Page indicator
                            return Stack(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      height: 50,
                                      color: Colors.transparent,
                                      child: PageView.builder(
                                        controller:
                                            pageController, //controller zuweisen
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state.locations.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            width: constraints.maxWidth,
                                            alignment: Alignment.center,
                                            child: locationsView(
                                                state.locations[index]),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SmoothPageIndicator(
                                      //verbunden mit dem PageView durch den controller
                                      controller: pageController,
                                      count: state.locations.length,
                                      effect: const WormEffect(
                                        dotHeight: 12,
                                        dotWidth: 12,
                                        activeDotColor:
                                            mainColorComplementarySecond,
                                        dotColor:
                                            mainColorComplementaryFirstShade100,
                                      ),
                                    ),
                                  ],
                                ),
                                if (Benutzer().isFahrlehrer!) ...[
                                  Positioned(
                                    bottom: 0, // Position the button at the top
                                    right:
                                        10, // Position the button to the right
                                    child: CircleAvatar(
                                      radius: 18, // Adjust size
                                      backgroundColor:
                                          mainColorComplementarySecond, // Button color
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.add_location_alt_rounded,
                                          size: 20,
                                        ), // Car icon
                                        onPressed: () async {
                                          // Action when button is pressed
                                          dialogBuilderAddNewLocation(context);
                                        },
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Fuhrpark button
            if (Benutzer().isFahrlehrer!) ...[
              Positioned(
                top: 50,
                right: 20,
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FuhrparkPage(),
                      ),
                    );
                  },
                  backgroundColor: mainColor,
                  child: const Icon(Icons.directions_car,
                      color: Colors.white, size: 37),
                ),
              ),
            ],
          ]);
        } else {
          return const Center(child: Text("Network error"));
        }
      },
    );
  }

  Widget locationsView(ParseObject location) {
    return Center(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${location.get<String>("Strasse")!} - ${location.get<String>("Hausnummer")!}",
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "${location.get<ParseObject>("Ort")!.get<String>("PLZ")}, ${location.get<ParseObject>("Ort")!.get<String>("Name")}",
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ));
  }

  Widget fahrlehrerView(ParseObject fahrlehrer) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Icon(
              Icons.person,
              size: 30,
              color: mainColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "${fahrlehrer.get<String>("Name")}, ${fahrlehrer.get<String>("Vorname")}",
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }



  Future<void> dialogBuilderAddNewLocation(BuildContext context) {
    late LocationCubit cubit;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (BuildContext dialogContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        final formBloc =
            context.read<AsyncRegistrationValidationFormBloc>();

        return BlocProvider(
          create: (context) {
            cubit = LocationCubit();
            return cubit;
          },
          child: FormBlocListener<AsyncRegistrationValidationFormBloc,
              String, String>(
            onSuccess: (context, state)  {
              //cubit.sendMail(createFahrlehrer: createFahrlehrer, eMail: formBloc.emailFormBloc.value, lastName: formBloc.lastNameFormBloc.value, firstName: formBloc.firstNameFormBloc.value, fahrlehrer: formBloc.fahrlehrerDropDownBloc.value);
              cubit.addLocation(strasse: formBloc.strasseBloc.value, hausnummer: formBloc.hausnummerBloc.value, ortObject: formBloc.plzDropDownBloc.value!);
              formBloc.plzBloc.clear();
              formBloc.plzDropDownBloc.clear();
              formBloc.hausnummerBloc.clear();
              formBloc.strasseBloc.clear();
              ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                showSuccessSnackbar("Ort wurde erstellt", "HURA!"));
              Navigator.of(dialogContext).pop();
               // Close dialog on success
            },
            onFailure: (context, state) {
              ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
                showErrorSnackbar("Fehler beim hinzufügen", "Ooooh!"));
              Navigator.of(dialogContext).pop();
            },
            child: BlocBuilder<LocationCubit, LocationState>(
              builder: (context, blocState) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    formBloc.plzBloc.clear();
                    formBloc.hausnummerBloc.clear();
                    formBloc.plzDropDownBloc.clear();
                    formBloc.strasseBloc.clear();
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
                              if(blocState is LocationError)
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
                                    child: blocState is LocationLoading
                                        ? SizedBox(height: 300, child: loadingScreen())
                                        : editWindow(
                                            formBloc), // blocState kann in diesen Moment nur FahrlehrerLoaded sein
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
                                          blocState is LocationLoaded
                                              ? Icons.add_location_alt_rounded
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
                                                              formBloc.plzBloc.clear();
                    formBloc.hausnummerBloc.clear();
                    formBloc.strasseBloc.clear();
                    formBloc.plzDropDownBloc.clear();

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

  SingleChildScrollView editWindow(AsyncRegistrationValidationFormBloc formBloc) {
    //formBloc.fahrlehrerDropDownBloc.updateItems(fahrlehrer);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFieldBlocBuilder(
            textFieldBloc: formBloc.strasseBloc,
            decoration: inputDecoration('Straße'),
            suffixButton: SuffixButton.clearText,

          ),
          const SizedBox(height: 16.0),
          TextFieldBlocBuilder(
            textFieldBloc: formBloc.hausnummerBloc,
            suffixButton: SuffixButton.clearText,
            decoration: inputDecoration('Hausnummer'),
          ),
          const SizedBox(height: 16.0),
           TextFieldBlocBuilder(
              textFieldBloc: formBloc.plzBloc,
              suffixButton: SuffixButton.asyncValidating,
              decoration: inputDecoration("PLZ"),
              maxLength: 5,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly // Nur Zahlen zulassen
              ],
            ),
            DropdownFieldBlocBuilder(
              selectFieldBloc: formBloc.plzDropDownBloc,
              itemBuilder: (context, value) => FieldItem(
                child: Text(value.get<String>("Name")!),
              ),
              decoration: const InputDecoration(
                labelText: "Stadt wählen",
                prefixIcon: Icon(Icons.house_rounded),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 2),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green, width: 1),
                ),
                // Optional: Customize the hintText or other properties if needed
              ),
              onChanged: (value) {
                formBloc.plzBloc.updateInitialValue(value!.get<String>("PLZ")!);
                //formBloc.plzDropDownBloc.updateValue(value);
              },
            ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: formBloc.onSubmittingLocation,
              style: stadiumButtonStyle(),
              child: const Text('Hinzufügen'),
            ),
          ),
        ],
      ),
    );
  }



}
