import 'dart:ffi';

import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:fahrschul_manager/pages/fahrzeug_add/fahrzeug_add_page.dart';
import 'package:fahrschul_manager/src/db_classes/fahrzeug.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class FuhrparkPage extends StatelessWidget {
  const FuhrparkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<List<ParseObject>>(
          future: fetchAllFahrzeug(Benutzer().fahrschule!),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return loadingScreen(width_: 150, height_: 150);
              default:
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return AnzeigeFahrzeuge(snapshot.data!);
                } else {
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
                            color:
                                Colors.black.withOpacity(0.5), // Shadow color
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
                }
            }
          }),
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
              builder: (context) => FahrzeugAddPage(),
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

    // Beispiel: Simuliere Fahrzeugdaten

    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text('Fuhrpark Page'),
    //   ),
    //   body: ListView.builder(
    //     padding: const EdgeInsets.all(20),
    //     itemCount: meinFahrzeugList.length,
    //     itemBuilder: (BuildContext context, int index) {
    //       // Extrahiere die Marke des Fahrzeugs
    //       ParseObject? marke = meinFahrzeugList[index].get<ParseObject>("Marke");
    //       String name = marke!.get<String>("Name")!;

    //       return Card(
    //         margin: const EdgeInsets.symmetric(vertical: 10),
    //         child: Padding(
    //           padding: const EdgeInsets.all(16),
    //           child: Text(
    //             name,
    //             style: const TextStyle(
    //               fontSize: 16,
    //               fontWeight: FontWeight.w500,
    //             ),
    //           ),
    //         ),
    //       );
    //     },
    //   ),
    // );
  }

  Widget AnzeigeFahrzeuge(List<ParseObject> meinFahrzeugList) {
     return ListView.builder(
      itemCount: meinFahrzeugList.length,
      itemBuilder: (BuildContext context, int index) {
        ParseObject fahrzeug = meinFahrzeugList[index];
        ParseObject marke = fahrzeug.get<ParseObject>("Marke")!;
        ParseObject fahrzeugtyp = fahrzeug.get<ParseObject>("Fahrzeugtyp")!;
        ParseObject getriebe = fahrzeug.get<ParseObject>("Getriebe")!;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
              child: Custom3DCard(
          title:
              "${marke.get<String>("Name")!}, ${fahrzeugtyp.get<String>("Typ")!} | Label: ${fahrzeug.get<String>("Label")!}",
          widget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Text("Getriebe: ${getriebe.get<String>("Typ")!}"),
              SizedBox(width: 10),
              Text(fahrzeug.get<bool>("Anhaengerkupplung")!
                  ? "Anhängerkupplung: Vorhanden"
                  : "Anhängerkupplung: Nicht Vorhanden"),
                  
            ],
          ),
          )
        );
      },
    );
  }

// AUFRUF VON ANZEIGE2 IN DEN CUSTOM3DCARD::::::::::::::::: ----> widget: Anzeige2(meinFahrzeugList[index]),
}
