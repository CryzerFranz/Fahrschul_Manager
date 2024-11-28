import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/src/db_classes/user.dart';
import 'package:fahrschul_manager/widgets/3dCard.dart';
import 'package:fahrschul_manager/widgets/loadingIndicator.dart';
import 'package:fahrschul_manager/widgets/navBar/navBar.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class FahrschuelerListePage extends StatelessWidget {
  const FahrschuelerListePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ParseObject>>(
        future: Benutzer().getAllFahrschueler(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return loadingScreen();
            default:
              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Text("No data");
              } else {
                return _buildTestTab(snapshot.data!, context);
              }
          }
        });
  }

  Widget _buildTestTab(List<ParseObject> data, BuildContext context) {
    return Scaffold(
      extendBody: true,
      body:DefaultTabController(
        length: 3,
        child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SegmentedTabControl(
                    // Customization of widget
                    tabTextColor: Colors.black,
                    selectedTabTextColor: Colors.white,
                    indicatorPadding: const EdgeInsets.all(4),
                    squeezeIntensity: 2,
                    tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    selectedTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    // Options for selection
                    // All specified values will override the [SegmentedTabControl] setting
                    tabs: [
                      SegmentTab(
                        label: 'AKTIV',
                        // For example, this overrides [indicatorColor] from [SegmentedTabControl]
                        color: mainColorShade300,
                        backgroundColor: mainColorShade100,
                      ),
                      SegmentTab(
                        label: 'PASSIV',
                        backgroundColor: Colors.orange.shade100,
                        color: Colors.orange.shade300,
                      ),
                      SegmentTab(
                        label: 'NEU',
                        backgroundColor: Colors.red.shade100,
                        color: Colors.red.shade300,
                      ),
                    ],
                  ),
                ),
                // Sample pages
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: TabBarView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildDataContent(data),
                      _buildDataContent(data),
                      _buildDataContent(data),

                      //SampleWidget(
                      //  icon: const Icon(Icons.person_add_alt),
                      //  color: Colors.blue.shade100,
                      //),
                      //SampleWidget(
                      //  icon: const Icon(Icons.person_add_alt),
                      //  color: Colors.orange.shade100,
                      //),
                    ],
                  ),
                ),
              ],
            ),
      
  ), bottomNavigationBar: CustomNavBar(),);}
}
// class fahrschuelerListAktiv extends StatelessWidget {
//   const fahrschuelerListAktiv({
//     Key? key,
//     required this.status,
//   }) : super(key: key);

//   final String status;

//   @override
//   Widget build(BuildContext context) {
//     if(status == "aktiv")
//     {

//     }
//     return Container(
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
//       ),
//       child: icon,
//     );
//   }
// }

  Widget _buildDataContent(List<ParseObject> data) {
    return  ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: data.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                Custom3DCard(
                    title:
                        "${data[index].get<String>("Name")!}, ${data[index].get<String>("Vorname")!}",
                    widget: const Text("Test")),SizedBox(height: 10),
              ]
            );
          });
  }
