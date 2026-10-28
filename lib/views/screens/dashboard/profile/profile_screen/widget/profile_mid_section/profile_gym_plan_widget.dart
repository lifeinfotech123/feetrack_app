import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vlr/generated/assets.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';

class ProfileGymPlanWidget extends StatelessWidget {
  const ProfileGymPlanWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            primaryText1,
            primaryColor,
          ],
          begin: AlignmentGeometry.topLeft,
          end: AlignmentGeometry.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "Elite Gym Member ship",
                  overflow: TextOverflow.clip,
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: white,
                      ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topRight,
                  child: SvgPicture.asset(
                    Assets.svgsStrength,
                    height: 29.7,
                    width: 29.7,
                    colorFilter: ColorFilter.mode(
                      greyLight,
                      BlendMode.dstIn,
                    ),
                  ),
                ),
              )
            ],
          ),
          sizedBoxHeight(height: 2),
          Text(
            "Premium All-Access Pass",
            overflow: TextOverflow.clip,
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: white,
                ),
          ),
          sizedBoxHeight(height: 24),
          Text(
            "NEXT PAYMENT DUE",
            overflow: TextOverflow.clip,
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  color: white,
                  letterSpacing: 2,
                ),
          ),
          sizedBoxHeight(height: 4),
          RichText(
            text: TextSpan(
                text: "2,500",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 30,
                      color: white,
                    ),
                children: [
                  TextSpan(
                    text: " on May 05, 2026",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: white,
                        ),
                  ),
                ]),
          ),
          sizedBoxHeight(height: 24),
          CustomButton(
            onTap: () {},
            radius: 999,
            height: 56,
            color: white,
            child: Text(
              "Manage Plan",
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: primaryText1,
                  ),
            ),
          )
        ],
      ),
    );
  }
}
