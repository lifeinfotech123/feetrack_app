import 'package:flutter/material.dart';
import 'package:vlr/data/models/category_model/facilities_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class GYMProfileFacilitesWidget extends StatelessWidget {
  final FacilityModel facilitiesModel;

  const GYMProfileFacilitesWidget({
    super.key,
    required this.facilitiesModel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCheckbox = facilitiesModel.fieldType == "checkbox";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: greyLight6.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCheckbox ? Colors.green : primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  facilitiesModel.label ?? "",
                  style: Helper(context).textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: blackText1,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Checkbox Type
          if (isCheckbox)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: facilitiesModel.isChecked
                    ? Colors.green.withValues(alpha: 0.12)
                    : Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                facilitiesModel.isChecked ? "Available" : "Not Available",
                style: TextStyle(
                  color: facilitiesModel.isChecked ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )

          /// Text Type
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (facilitiesModel.value ?? "")
                  .split(',')
                  .where((e) => e.trim().isNotEmpty)
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        item.trim(),
                        style: Helper(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
