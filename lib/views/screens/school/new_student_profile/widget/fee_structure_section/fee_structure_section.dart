import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/school/new_student_profile/widget/fee_structure_section/row_of_fee_widget.dart';

class FeeStructureSection extends StatelessWidget {
  const FeeStructureSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: white,
        border: Border.all(
          width: 1,
          color: greyLight5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Fee Structure (2023-24)",
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 20,
                  color: blackText1,
                ),
          ),
          sizedBoxHeight(height: 24),
          FeeRowOfWidget(),
        ],
      ),
    );
  }
}
