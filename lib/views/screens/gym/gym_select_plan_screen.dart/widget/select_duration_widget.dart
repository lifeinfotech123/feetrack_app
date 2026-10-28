import 'package:flutter/material.dart';
import 'package:vlr/data/models/category_model/plan_during_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class SelectDurationWidget extends StatelessWidget {
  final PlanDurationModel planDurationModel;
  const SelectDurationWidget({
    super.key,
    required this.planDurationModel,
  });

  @override
  Widget build(BuildContext context) {
    final duration = planDurationModel.durationDays ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: planDurationModel.isSelected ? primaryText1 : greyLight,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        duration > 0
            ? "${planDurationModel.label} ($duration days)"
            : "${planDurationModel.label}",
        style: Helper(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: planDurationModel.isSelected ? white : greyText2,
        ),
      ),
    );
  }
}
