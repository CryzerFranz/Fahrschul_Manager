import 'package:fahrschul_manager/constants.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarBloc.dart';
import 'package:fahrschul_manager/widgets/navBar/navBarEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class CustomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavBarBloc, NavBarState>(
      builder: (context, state) {
        final icons = state.isFahrlehrer
            ? [
                Icons.people_alt_rounded,
                Icons.calendar_month_rounded,
                Icons.home,
                Icons.emoji_transportation,
                Icons.person,
              ]
            : [
                Icons.calendar_month_rounded,
                Icons.home,
                Icons.emoji_transportation,
                Icons.person,
              ];

        return Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
            bottom: 40.0,
          ),
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              color: navBarBackgroundColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(icons.length, (index) {
                return buildNavBarIcon(context, icons[index], index);
              }),
            ),
          ),
        );
      },
    );
  }

  Widget buildNavBarIcon(BuildContext context, IconData icon, int index) {
    return BlocBuilder<NavBarBloc, NavBarState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(
            icon,
            color: state.selectedIndex == index
                ? navBarSelectedColor
                : navBarUnSelectedColor,
          ),
          onPressed: () {
            context.read<NavBarBloc>().add(NavBarItemTapped(index));
          },
        );
      },
    );
  }
}
