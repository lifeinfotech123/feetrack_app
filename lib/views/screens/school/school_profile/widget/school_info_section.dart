import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/school/school_profile/widget/school_info_widget.dart';

class SchoolInfoSection extends StatelessWidget {
  const SchoolInfoSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "School Home English medium School ",
          textAlign: TextAlign.center,
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 24,
                color: blackText1,
              ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 24, bottom: 16),
        ),
        Row(
          children: [
            const Expanded(
              child: SchoolInfoWidget(
                title: "1.2k",
                subTitle: "Student",
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: greyLight6,
            ),
            const Expanded(
              child: SchoolInfoWidget(
                title: "1.2k",
                subTitle: "Student",
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: greyLight6,
            ),
            const Expanded(
              child: SchoolInfoWidget(
                title: "1.2k",
                subTitle: "Student",
              ),
            ),
          ],
        ),
        sizedBoxHeight(height: 16)
      ],
    );
  }
}
