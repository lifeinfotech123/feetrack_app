import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vlr/generated/assets.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';

class GymVisitBookSuccessButtonsSection extends StatelessWidget {
  final Function()? onTapAddToCalendarButton;
  final Function()? onTapBackButton;
  const GymVisitBookSuccessButtonsSection({
    super.key,
    this.onTapAddToCalendarButton,
    this.onTapBackButton,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CustomButton(
        //   color: primaryText1,
        //   borderColor: primaryText1,
        //   radius: 99,
        //   height: 56,
        //   onTap: onTapAddToCalendarButton,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       SvgPicture.asset(
        //         Assets.svgsCalenderPlus,
        //       ),
        //       sizedBoxWidth(width: 12),
        //       Text(
        //         "Add to Calendar",
        //         style: Helper(context).textTheme.titleLarge?.copyWith(
        //               fontSize: 16,
        //               color: white,
        //             ),
        //       ),
        //     ],
        //   ),
        // ),
        sizedBoxHeight(height: 16),
        CustomButton(
          type: ButtonType.secondary,
          borderColor: primaryText1,
          radius: 99,
          height: 58,
          onTap: onTapBackButton,
          child: Center(
            child: Text(
              "Back to Home",
              style: Helper(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16,
                    color: blackText1,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
