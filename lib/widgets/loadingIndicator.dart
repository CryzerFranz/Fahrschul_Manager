

import 'package:fahrschul_manager/constants.dart';
import 'package:loading_indicator/loading_indicator.dart';

LoadingIndicator ballTrianglePathColoredFilledLoadingIndicator()
{
  return const LoadingIndicator(
                          indicatorType: Indicator.ballTrianglePathColoredFilled,
                          colors: [mainColor, mainColorComplementaryFirst, mainColorComplementarySecond]
                        );
}