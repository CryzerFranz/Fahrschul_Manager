import 'package:fahrschul_manager/doc/intern/User.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: Benutzer().hasUserLogged(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return ScaffoldLoadingScreen();
            default:
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
                          color: Color(0xFFF5FCF9),
                          border: Border.all(
                            color: Colors.green[200]!,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${Benutzer().dbUser!.get<String>("Vorname")} ${Benutzer().dbUser!.get<String>("Name")}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 100),
                      TextFormField(
                          readOnly: true,
                          initialValue:
                              '${Benutzer().dbUser!.get<String>("Email")}',
                          style: const TextStyle(
                            color: Colors.black, // Textfarbe
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              fillColor: Colors.green.withOpacity(
                                  0.1), // Leichter Grünton als Hintergrund
                              filled: true, // Aktiviert den Hintergrund
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    12), // Abgerundete Ecken
                                borderSide: BorderSide
                                    .none, // Keine sichtbare Umrandung
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                                onPressed:
                                    () {
                                      
                                    }, // Funktion, die beim Klicken auf das Icon ausgeführt wird
                              ))),
                      const SizedBox(height: 16),
                      TextFormField(
                          readOnly: true,
                          initialValue:
                              '${Benutzer().fahrschule!.get<String>("Name")}',
                          style: const TextStyle(
                            color: Colors.black, // Textfarbe
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            fillColor: Colors.green.withOpacity(
                                0.1), // Leichter Grünton als Hintergrund
                            filled: true, // Aktiviert den Hintergrund
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // Abgerundete Ecken
                              borderSide:
                                  BorderSide.none, // Keine sichtbare Umrandung
                            ),
                          )),
                    ],
                  ),
                ),
              );
          }
        });
  }
}
