import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/school/new_student_profile/widget/student_column_widget.dart';

class TopSectionStudentScreen extends StatelessWidget {
  const TopSectionStudentScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 4,
                  color: greyLight6,
                )),
            child: const CustomImage(
              path: Assets.imagesReview1,
              height: 120,
              width: 120,
              fit: BoxFit.cover,
              radius: 999,
            ),
          ),
          sizedBoxHeight(height: 24),
          Text(
            "Vinod Johnson",
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 24,
                  color: blackText1,
                ),
          ),
          sizedBoxHeight(height: 4),
          Text(
            "ST. XAVIER'S HIGH SCHOOL",
            style: Helper(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: greyDart2,
                ),
          ),
          sizedBoxHeight(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: greyLight6,
                  width: 1,
                ),
                bottom: BorderSide(
                  color: greyLight6,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
                height: 40,
                child: Row(
                  children: [
                    const Expanded(child: StudentColumnWidget()),
                    Container(
                      width: 1,
                      height: 40,
                      color: greyLight6.withValues(alpha: 0.30),
                    ),
                    const Expanded(child: StudentColumnWidget()),
                    Container(
                      width: 1,
                      height: 40,
                      color: greyLight6.withValues(alpha: 0.30),
                    ),
                    const Expanded(child: StudentColumnWidget()),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
