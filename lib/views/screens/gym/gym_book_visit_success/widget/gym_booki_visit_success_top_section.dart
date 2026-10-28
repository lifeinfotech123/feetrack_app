
import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class VisitBookingSuccessTopSection extends StatelessWidget {
  const VisitBookingSuccessTopSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        sizedBoxHeight(height: 20),
        Container(
          height: 160,
          width: 160,
          decoration: BoxDecoration(
            color: blueLight5.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomImage(
              path: Assets.imagesVisitSuccess,
              height: 100,
              width: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),
        sizedBoxHeight(height: 40),
        Text(
          "Booking Confirmed!",
          textAlign: TextAlign.center,
          style: Helper(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 32,
                color: primaryText1,
              ),
        ),
        sizedBoxHeight(height: 12),


        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Your visit has been successfully scheduled. We've sent the details to your registered email and mobile number.",
            textAlign: TextAlign.center,
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: greyText3,
                  height: 1.5,
                ),
          ),
        ),
      ],
    );
  }
}
