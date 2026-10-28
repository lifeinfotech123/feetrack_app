import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vlr/generated/assets.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class CampusAmenitiesWidget extends StatelessWidget {
  final CampusAmenitiesModel campusAmenitiesModel;
  const CampusAmenitiesWidget({
    super.key,
    required this.campusAmenitiesModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: pinLight,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            campusAmenitiesModel.icon,
            height: 20,
            width: 20,
            fit: BoxFit.cover,
          ),
          sizedBoxWidth(width: 12),
          Text(
            campusAmenitiesModel.title,
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 12,
                  color: blackText1,
                ),
          ),
          sizedBoxHeight(height: 16),
        ],
      ),
    );
  }
}

class CampusAmenitiesModel {
  final String icon;
  final String title;

  CampusAmenitiesModel({required this.icon, required this.title});
}

List<CampusAmenitiesModel> campusAmenitiesModelList = [
  CampusAmenitiesModel(icon: Assets.svgsLibrary, title: "Modern Library"),
  CampusAmenitiesModel(icon: Assets.svgsScienceLabs, title: "Science Labs"),
  CampusAmenitiesModel(icon: Assets.svgsSportStare, title: "Indoor Sports"),
  CampusAmenitiesModel(icon: Assets.svgsSmartClasses, title: "Indoor Sports"),
];
