

import 'package:fahrschul_manager/constants.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

LoadingIndicator pacmanLoadingIndicator()
{
  return const LoadingIndicator(
                          indicatorType: Indicator.pacman,
                          colors: [mainColor, mainColorComplementaryFirst, mainColorComplementarySecond]
                        );
}

Widget loadingScreen()
{
    return Scaffold(
                  body: Center(
                    child: Container(
                        width: 100,
                        height: 100,
                        child: pacmanLoadingIndicator()),
                  ),
                );
}