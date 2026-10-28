import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/school/school_profile/widget/campus_amenities_widget.dart';

class CampusAmenitiesSchoolSection extends StatelessWidget {
  const CampusAmenitiesSchoolSection({
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
            "Campus Amenities",
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  color: blackText1,
                ),
          ),
          sizedBoxHeight(height: 14),
          Text(
            "St. Xavier's High School is committed to academic excellence and holistic development, providing a nurturing environment where students thrive through innovation, sports, and cultural enrichment.",
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: greyDart2,
                ),
          ),
          sizedBoxHeight(height: 16),

          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.9),
            itemBuilder: (context, index) {
              final _campusAmenitiesModel = campusAmenitiesModelList[index];
              return CampusAmenitiesWidget(
                campusAmenitiesModel: _campusAmenitiesModel,
              );
            },
            itemCount: campusAmenitiesModelList.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
          )
          // ()
        ],
      ),
    );
  }
}
