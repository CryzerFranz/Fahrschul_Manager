// import 'package:fahrschul_manager/constants.dart';
// import 'package:fahrschul_manager/main.dart';
// import 'package:fahrschul_manager/pages/fahrschueler_liste_page.dart';
// import 'package:flutter/material.dart';

// class CustomNavBar extends StatefulWidget {
//   @override
//   _CustomNavBarState createState() => _CustomNavBarState();
// }

// class _CustomNavBarState extends State<CustomNavBar> {
//   int selectedIndex = 2;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         left: MediaQuery.of(context).size.width * 0.05, // 5% padding on left
//         right: MediaQuery.of(context).size.width * 0.05, // 5% padding on right
//         bottom: 40.0, // 10px bottom padding (adjust as needed)
//       ), // 5% padding on both sides
//       child: Container(
//         height: 66,
//         decoration: BoxDecoration(
//           color: navBarBackgroundColor.withOpacity(0.8),
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               spreadRadius: 2,
//               blurRadius: 10,
//               offset: const Offset(0, 20),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             buildNavBarIcon(Icons.people_alt_rounded, 0),
//             buildNavBarIcon(Icons.calendar_month_rounded, 1),
//             buildNavBarIcon(Icons.home, 2),
//             buildNavBarIcon(Icons.airport_shuttle, 3),
//             buildNavBarIcon(Icons.person, 4),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildNavBarIcon(IconData icon, int index) {
//     return IconButton(
//       icon: Icon(
//         icon,
//         color: selectedIndex == index ? navBarSelectedColor : navBarUnSelectedColor,
//       ),
//       onPressed: () {
//         setState(() {
//           selectedIndex = index;
//         });
//         switch(index)
//         {
//           case 0:
//              navigatorKey.currentState?.push(
//                               MaterialPageRoute(
//                                   builder: (context) => const fahrschuelerListePage()),
//                             );
//             break;
//           case 1:
//             break;
//           case 2:
//             break;
//           case 3:
//             break;
//           case 4:
//             break;
//         }
//       },
//     );
//   }
// }
