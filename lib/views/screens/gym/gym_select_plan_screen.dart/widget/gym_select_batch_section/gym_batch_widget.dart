import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/category_model/batch_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';


class GYMBatchWidget extends StatelessWidget {
  final BatchModel batchModel;

  const GYMBatchWidget({
    super.key,
    required this.batchModel,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SubscriptionController>(
      builder: (subscriptionController) {
        final isSelected = batchModel.isSelected;

        return GestureDetector(
          onTap: () {
            final index = subscriptionController.batchModelList.indexWhere(
                  (e) => e.id == batchModel.id,
            );

            if (index != -1) {
              subscriptionController.selectBatch(index);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primaryText1.withValues(alpha: 0.06) : greyLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                width: isSelected ? 1.5 : 1,
                color: isSelected ? primaryText1 : greyLight6,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  batchModel.name ?? "",
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: greyText3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${batchModel.startTime ?? ""} - ${batchModel.endTime ?? ""}",
                  textAlign: TextAlign.center,
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: primaryText1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_alt_outlined,
                      size: 12,
                      color: greenDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${batchModel.maxMembers ?? 0}",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: greenDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "₹${batchModel.fee ?? 0}",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryText1,
                      ),
                    ),
                  ],
                ),
                if (isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.check_circle,
                    color: primaryText1,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

