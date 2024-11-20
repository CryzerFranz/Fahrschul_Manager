

import 'package:fahrschul_manager/constants.dart';
import 'package:loading_indicator/loading_indicator.dart';

LoadingIndicator pacmanLoadingIndicator()
{
  return const LoadingIndicator(
                          indicatorType: Indicator.pacman,
                          colors: [mainColor, mainColorComplementaryFirst, mainColorComplementarySecond]
                        );
}