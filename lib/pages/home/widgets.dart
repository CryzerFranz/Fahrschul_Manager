import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/pages/home/cubit/homepage_fahrschueler_cubit.dart';
import 'package:fahrschul_manager/src/db_classes/fahrstunde.dart';
import 'package:fahrschul_manager/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget nextFahrstundeContent({required Fahrstunde next,required int currentIndex,required int length, HomepageFahrschuelerCubit? cubit}) {
    String fahrschuelerText = next.getFahrschueler();
    String fahrzeugText = next.getFahrzeug();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    fahrschuelerText == "-"
                        ? FontAwesomeIcons.userXmark
                        : FontAwesomeIcons.user,
                    size: 18,
                    color: fahrschuelerText == "-"
                        ? tabBarRedShade300
                        : Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Fahrschüler:",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        fahrschuelerText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                children: [
                  Icon(
                    fahrzeugText == "-"
                        ? Icons.car_crash
                        : FontAwesomeIcons.car,
                    size: fahrzeugText == "-" ? 24 : 18,
                    color:
                        fahrzeugText == "-" ? tabBarRedShade300 : Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Fahrzeug:",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        next.getFahrzeug(),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
            child: Column(children: [
          const Icon(Icons.access_time_outlined, size: 20, color: Colors.white),
          const SizedBox(height: 3),
          Text(
            next.getDateRange(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          Text(
            next.getTimeRange(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ])),
        const SizedBox(height: 5),
        if(next.eventId != null)...[
           ElevatedButton(
              onPressed: () async  {
                if(cubit != null)
                {
                  await cubit.registerToAppointment(next.eventId!);
                }
              },
              style: stadiumButtonStyle(background: mainColorComplementaryFirst),
              child: const Text('Annehmen'),
            ),
        ]
      ],
    );
  }