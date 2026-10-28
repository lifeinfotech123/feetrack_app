import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class LoginBottomSection extends StatelessWidget {
  const LoginBottomSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: primaryText2,
              ),
              sizedBoxWidth(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Secure",
                    style: Helper(context).textTheme.titleMedium?.copyWith(
                          fontSize: 10.sp,
                          color: blackText3,
                        ),
                  ),
                  Text(
                    "Your data is safe",
                    style: Helper(context).textTheme.titleSmall?.copyWith(
                          fontSize: 10.sp,
                          color: greyDart,
                        ),
                  ),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.person_2_outlined,
                color: primaryText2,
              ),
              sizedBoxWidth(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trusted",
                      style: Helper(context).textTheme.titleMedium?.copyWith(
                            fontSize: 10.sp,
                            color: blackText3,
                          ),
                    ),
                    Text(
                      "Used by thousands",
                      style: Helper(context).textTheme.titleSmall?.copyWith(
                            fontSize: 10.sp,
                            color: greyDart,
                          ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
