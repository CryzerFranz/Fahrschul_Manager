import 'package:fahrschul_manager/pages/profil_page/bloc/profil_page_event.dart';
import 'package:fahrschul_manager/pages/profil_page/bloc/profil_page_bloc.dart';
import 'package:fahrschul_manager/pages/profil_page/bloc/profil_page_state.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fahrschul_manager/constants.dart';


class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<ProfilPageBloc>().add(FetchProfilPageEvent());

    return BlocBuilder<ProfilPageBloc, ProfilPageState>(
      builder: (context, state) {
        if (state is DataLoading) {
          return loadingScreen(height_: 150, width_: 150);
        } else if (state is DataLoaded) {
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: mainColor,
                      // border: Border.all(
                      //   color: Colors.green[200]!,
                      //   width: 1,
                      // ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${state.vorname} ${state.nachname}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 100),
                  TextFormField(
                    readOnly: true,
                    initialValue: state.email,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      fillColor: textFieldColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit, color: mainColor),
                        onPressed: () {
                          // Action when edit is clicked
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    readOnly: true,
                    initialValue: state.fahrschuleName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      fillColor: textFieldColor,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (state is DataError) {
          return Center(child: Text(state.message));
        } else {
          return const Center(child: Text('Unexpected state.'));
        }
      },
    );
  }
}
