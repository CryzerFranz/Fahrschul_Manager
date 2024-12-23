import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/src/db_classes/fahrschueler.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class HomePageFahrschueler extends StatelessWidget {
  const HomePageFahrschueler({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 80),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Custom3DCard(title: "Fahrlehrer" ,widget:displayFahrlehrer(context)),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Custom3DCard(title: "Deine Fahrstunden" ,widget:displayFahrstunden(context)),
        ),
      ],
    );
  }

  Widget displayFahrstunden(BuildContext context){
    return Row(children: [
      Text(Benutzer().dbUser!.get("Gesamtfahrstunden")!.toString(),  style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
            ),
      const SizedBox(width: 10),
      Text("Fahrstunden vollbracht", style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.black),), 
    ],);
  }

  Widget displayFahrlehrer(BuildContext context){
    return Row(children: [
      Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                    hasFahrlehrer(Benutzer().dbUser!) ? Icons.person : Icons.question_mark,
                      size: 30,
                      color: mainColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  hasFahrlehrer(Benutzer().dbUser!) ? Text("${Benutzer().dbUser!.get<ParseObject>("Fahrlehrer")!.get<String>("Name")}, ${Benutzer().dbUser!.get<ParseObject>("Fahrlehrer")!.get<String>("Vorname")}", style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.black),) : 
                Text("Kein Fahrlehrer zugewiesen", style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.black),),
                  
    ],);
  }
}