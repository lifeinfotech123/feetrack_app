import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_screen/widget/profile_mid_section/profile_Pending_widget.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_screen/widget/profile_mid_section/profile_gym_plan_widget.dart';

class ProfileMidSection extends StatelessWidget {
  const ProfileMidSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ProfilePendingWidget(
                icon: Icons.pending_actions_rounded,
                title: "PENDING DUES",
                subTitle: "02",
                color: primaryText1,
              ),
            ),
            sizedBoxWidth(width: 16),
            const Expanded(
              child: ProfilePendingWidget(
                icon: Icons.sync_rounded,
                title: "AUTOPAY",
                subTitle: "Active",
                color: greenDark,
                isAutoPay: true,
              ),
            ),
          ],
        ),
        sizedBoxWidth(width: 32),
        Text(
          "CURRENT SUBSCRIPTION",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: greyText2,
              letterSpacing: 1.4),
        ),
        sizedBoxHeight(height: 16),
        ProfileGymPlanWidget()
      ],
    );
  }
}
