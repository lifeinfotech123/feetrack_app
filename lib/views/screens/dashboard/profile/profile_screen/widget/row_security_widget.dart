import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_screen/widget/profile_personal_detail_section/profile_security_and_account.dart';

class RowOfSecurityWidget extends StatelessWidget {
  final ProfileInfoRowModel profileInfoRowModel;
  const RowOfSecurityWidget({
    super.key,
    required this.profileInfoRowModel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: profileInfoRowModel.onTap,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                color: primaryText1.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(999)),
            padding: EdgeInsets.all(12),
            child: SvgPicture.asset(
              profileInfoRowModel.icon,
              height: 17,
              width: 17,
              fit: BoxFit.cover,
            ),
          ),
          sizedBoxWidth(width: 16),
          Expanded(
            child: Text(
              profileInfoRowModel.title ?? "",
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: blackText1,
                  ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_outlined,
            color: greyText3,
          )
        ],
      ),
    );
  }
}
