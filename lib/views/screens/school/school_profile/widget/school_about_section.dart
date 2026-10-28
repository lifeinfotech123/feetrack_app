import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/school/school_profile/widget/school_about_row_widget.dart';

class SchoolAboutSection extends StatelessWidget {
  const SchoolAboutSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "About",
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  color: blackText1,
                ),
          ),
          sizedBoxHeight(height: 12),
          Text(
            "St. Xavier's High School is committed to academic excellence and holistic development, providing a nurturing environment where students thrive through innovation, sports, and cultural enrichment.",
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: greyDart2,
                ),
          ),
          sizedBoxHeight(height: 16),
          ListView.separated(
            itemBuilder: (context, index) {
              final _schoolAboutRowModel = schoolAboutRowModelList[index];
              return SchoolAboutRowWidget(
                schoolAboutRowModel: _schoolAboutRowModel,
              );
            },
            separatorBuilder: (_, __) => sizedBoxHeight(height: 16),
            itemCount: schoolAboutRowModelList.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          )
        ],
      ),
    );
  }
}
