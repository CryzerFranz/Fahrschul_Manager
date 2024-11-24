
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class fahrschuelerListePage extends StatelessWidget {
  const fahrschuelerListePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ParseObject>>(
      future: Benutzer().getAllFahrschueler(),
      builder: (context, snapshot) {
        switch(snapshot.connectionState){
          case ConnectionState.none:
          case ConnectionState.waiting:
           return loadingScreen();
          default:
            if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return Text("No data");
                } else {
                  return Text("muss noch machen");
                }
        };
      }
    );
  }
}