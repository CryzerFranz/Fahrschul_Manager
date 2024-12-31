import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/pages/fahrzeug_add/fahrzeug_add_page.dart';
import 'package:fahrschul_manager/pages/fuhrpark/bloc/fuhrpark_bloc.dart';
import 'package:fahrschul_manager/pages/fuhrpark/bloc/fuhrpark_event.dart';
import 'package:fahrschul_manager/pages/fuhrpark/bloc/fuhrpark_state.dart';
import 'package:fahrschul_manager/pages/fuhrpark/cubit/fahrzeug_cubit.dart';
import 'package:fahrschul_manager/src/form_blocs/AsyncFahrzeugAddValidationFormBloc.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/snackbar.dart';
import 'package:fahrschul_manager/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class FuhrparkPage extends StatelessWidget {
  const FuhrparkPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FuhrparkBloc>().add(FetchFuhrparkEvent(stateActive));
    return BlocBuilder<FuhrparkBloc, FuhrparkState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: Builder(
            builder: (_) {
              if (state is DataLoading) {
                return loadingScreen(width_: 150, height_: 150);
              } else if (state is DataLoaded) {
                if (state.fahrzeuginfos.isNotEmpty) {
                  return ListView.builder(
                    itemCount: state.fahrzeuginfos.length,
                    itemBuilder: (BuildContext context, int index) {
                      return anzeigeFahrzeuge(
                          context: context, data: state.fahrzeuginfos[index]);
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 120),
                        ),
                        Icon(
                          FontAwesomeIcons.car,
                          size: 80,
                          color: Colors.red[600],
                          shadows: [
                            BoxShadow(
                              color:
                                  Colors.black.withOpacity(0.5), // Shadow color
                              spreadRadius: 1, // How far the shadow spreads
                              blurRadius: 10, // The softness of the shadow
                              offset: const Offset(5, 5), // X and Y offset
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text("Keine Fahrzeuge"),
                      ],
                    ),
                  );
                }
              } else if (state is DataError) {
                return Center(child: Text(state.message));
              } else {
                return const Center(child: Text('Unexpected state.'));
              }
            },
          ),
          floatingActionButton: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: mainColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FahrzeugAddPage(),
                ),
              );
            },
            child: const Icon(
              Icons.add,
              size: 32,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

Widget anzeigeFahrzeuge({
  required BuildContext context,
  required ParseObject data,
}) {
  return Padding(
    padding: const EdgeInsets.only(left:16.0, right: 16, top: 8),
    child: Column(
      children: [
        Row(
          children: [
            Custom3DCard(
              colors: const [
                mainColor,
                mainColor,
                tabBarMainColorShade100,
              ],
              width: 0.7,
              title:
                  "${data.get<ParseObject>("Marke")!.get<String>("Name")} | ${data.get<String>("Label")!}",
              widget: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.airport_shuttle_outlined, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            "Typ: ${data.get<ParseObject>("Fahrzeugtyp")!.get<String>("Typ")}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Icon(Icons.settings, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            "Getriebe: ${data.get<ParseObject>("Getriebe")!.get<String>("Typ")}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Icon(
            data.get<bool>("Anhaengerkupplung")!
                ? Icons.check_circle
                : Icons.cancel,
            color: data.get<bool>("Anhaengerkupplung")!
                ? Colors.white
                : Colors.red,
          ),
          const SizedBox(width: 10),
          const Text(
            "Anhängerkupplung"
                ,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    ],
    ),
            ),
            const SizedBox(width: 10),
            Custom3DCard(
              widget: IconButton(
                padding: const EdgeInsets.only(top: 48.0, bottom: 48.0),
                onPressed: () async {
                  dialogBuilderFahrzeug(context, data);
                },
                icon: const Icon(Icons.edit),
              ),
              colors: const [tabBarMainColorShade100, mainColor],
              width: 0.17,
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    ),
  );
}

Future<void> dialogBuilderFahrzeug(BuildContext context, ParseObject fahrzeug) {
  late FuhrparkCubit cubit;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext dialogContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final formBloc = context.read<AsyncFahrzeugAddValidationFormBloc>();
      return BlocProvider(
        create: (context) {
          cubit = FuhrparkCubit(fahrzeug);
          return cubit;
        },
        child: FormBlocListener<AsyncFahrzeugAddValidationFormBloc, String,
            String>(
          onSuccess: (context, state) {
            formBloc.labelBloc.clear();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                  showSuccessSnackbar("Änderungen wirksam", "HURA!"));
            Navigator.of(dialogContext).pop();
            // Close dialog on success
          },
          onFailure: (context, state) {},
          child: BlocBuilder<FuhrparkCubit, FuhrparkCubitState>(
            builder: (context, blocState) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  formBloc.labelBloc.clear();
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
                            if (blocState is FuhrparkCubitError) {
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
                                  child: blocState is FuhrparkCubitLoading
                                      ? SizedBox(
                                          height: 300, child: loadingScreen())
                                      : editWindow(formBloc, fahrzeug,
                                          cubit), // blocState kann in diesen Moment nur FahrlehrerLoaded sein
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
                                      backgroundColor: tabBarMainColorShade100,
                                      radius: 40,
                                      child: Icon(
                                        blocState is FuhrparkCubitLoaded
                                            ? FontAwesomeIcons.car
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
                                        formBloc.labelBloc.clear();
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

SingleChildScrollView editWindow(AsyncFahrzeugAddValidationFormBloc formBloc,
    ParseObject fahrzeug, FuhrparkCubit cubit) {
  //formBloc.fahrlehrerDropDownBloc.updateItems(fahrlehrer);
  return SingleChildScrollView(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFieldBlocBuilder(
          textFieldBloc: formBloc.labelBloc,
          decoration: inputDecoration('Label'),
          suffixButton: SuffixButton.clearText,
        ),
        const SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: () => formBloc.onSubmittingDelete(cubit),
          style: stadiumButtonStyle(background: tabBarRedShade300),
          child: const Text('Löschen'),
        ),
        const SizedBox(height: 4.0),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ElevatedButton(
            onPressed: () => formBloc.onSubmittingUpdateLabel(cubit),
            style: stadiumButtonStyle(),
            child: const Text('Ändern'),
          ),
        ),
      ],
    ),
  );
}
