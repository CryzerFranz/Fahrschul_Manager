

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

Widget ScaffoldLoadingScreen({double width_ = 100, double height_ = 100})
{
    return Scaffold(
                  body: Center(
                    child: Container(
                        width: width_,
                        height: height_,
                        child: pacmanLoadingIndicator()),
                  ),
                );
}

Widget loadingScreen({double width_ = 100, double height_ = 100})
{
    return  Center(
                    child: Container(
                        width: width_,
                        height: height_,
                        child: pacmanLoadingIndicator()),
                  );

}

