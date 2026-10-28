import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class SchoolAboutRowWidget extends StatelessWidget {
  final SchoolAboutRowModel schoolAboutRowModel;
  const SchoolAboutRowWidget({
    super.key,
    required this.schoolAboutRowModel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        schoolAboutRowModel.icon,
        sizedBoxWidth(width: 16),
        Expanded(
          child: Text(
            schoolAboutRowModel.title,
            style: schoolAboutRowModel.isBold
                ? Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      color: greyDart2,
                    )
                : Helper(context).textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: greyDart2,
                    ),
          ),
        ),
      ],
    );
  }
}

class SchoolAboutRowModel {
  final Widget icon;
  final String title;
  final bool isBold;

  SchoolAboutRowModel(
      {required this.icon, required this.title, required this.isBold});
}

List<SchoolAboutRowModel> schoolAboutRowModelList = [
  SchoolAboutRowModel(
      icon: SvgPicture.asset(
        Assets.svgsLocation,
        height: 20,
        width: 16,
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          greyDart2,
          BlendMode.srcIn,
        ),
      ),
      title: "Main Campus at 123 Academic Way, Education District, NY",
      isBold: false),
  SchoolAboutRowModel(
      icon: SvgPicture.asset(
        Assets.svgsEarch,
        height: 20,
        width: 16,
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          greyDart2,
          BlendMode.srcIn,
        ),
      ),
      title: "www.stxaviers-edu.com",
      isBold: false),
  SchoolAboutRowModel(
      icon: SvgPicture.asset(
        Assets.svgsHead,
        height: 20,
        width: 16,
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          greyDart2,
          BlendMode.srcIn,
        ),
      ),
      title: "Grades: Pre-primary to Grade 12",
      isBold: true),
  SchoolAboutRowModel(
      icon: SvgPicture.asset(
        Assets.svgsWatch,
        height: 20,
        width: 16,
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          greyDart2,
          BlendMode.srcIn,
        ),
      ),
      title: "School Hours: 08:00 AM - 03:30 PM",
      isBold: true),
];
