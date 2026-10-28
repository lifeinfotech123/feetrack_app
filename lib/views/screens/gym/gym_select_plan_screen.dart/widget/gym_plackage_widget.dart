import 'package:flutter/material.dart';
import 'package:vlr/data/models/category_model/plan_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/theme.dart';

class GYMPackageWidget extends StatelessWidget {
  final PlanModel planModel;

  const GYMPackageWidget({
    super.key,
    required this.planModel,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = planModel.isSelected;

    return GetBuilder<SubscriptionController>(builder: (subController) {
      // Find security deposit from the plan or the associated room
      int? securityDeposit = planModel.securityDeposit;
      if (securityDeposit == null || securityDeposit == 0) {
        final room = subController.roomDetailList
            .firstWhereOrNull((r) => r.id == planModel.roomId);
        securityDeposit = room?.securityDeposit;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: isSelected ? 1.2 : 1,
            color: isSelected
                ? const Color(0xFF002060)
                : Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planModel.name ?? "",
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF002060),
                            ),
                      ),
                      if (planModel.roomType != null)
                        Text(
                          planModel.roomType!,
                          style: Helper(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: greyDart2,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                    ],
                  ),
                ),
                if (planModel.occupancyType != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      planModel.occupancyType
                              ?.replaceAll('_', ' ')
                              .toUpperCase() ??
                          "",
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                sizedBoxWidth(width: 8),
                if (isSelected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002060),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Selected",
                      style: Helper(context).textTheme.bodySmall?.copyWith(
                            color: white,
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "₹${planModel.price ?? 0}",
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF002060),
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  "/ ${planModel.durationLabel ?? ""}",
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: greyText2,
                      ),
                ),
              ],
            ),
            if (securityDeposit != null && securityDeposit > 0)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  "Security Deposit: ₹$securityDeposit",
                  style: Helper(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              "Benefits",
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: blackText1,
                  ),
            ),
            const SizedBox(height: 4),
            ...(planModel.features ?? []).map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 12,
                      color: Color(0xFF002060),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        feature,
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: greyText2,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (planModel.mealPlans != null) ...[
              const SizedBox(height: 8),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (planModel.mealPlans!.hasBreakfast ?? false)
                    const _MealTag(label: "Breakfast"),
                  if (planModel.mealPlans!.hasLunch ?? false)
                    const _MealTag(label: "Lunch"),
                  if (planModel.mealPlans!.hasDinner ?? false)
                    const _MealTag(label: "Dinner"),
                ],
              ),
            ],
            if (isSelected && planModel.occupancyType == 'per_bed') ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 12),
              Text(
                "Select Number of Beds",
                style: Helper(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: (subController.selectedRoomDetail != null)
                      ? (int.tryParse(subController
                              .selectedRoomDetail!.availableBeds ??
                          '1') ?? 1)
                      : (subController.roomDetailList.isNotEmpty
                          ? (int.tryParse(subController
                                  .roomDetailList.first.availableBeds ??
                              '1') ?? 1)
                          : 1),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final bedCount = index + 1;
                    final isBedSelected =
                        subController.selectedBedsCount == bedCount;

                    return GestureDetector(
                      onTap: () {
                        subController.updateSelectBedsCount(bedCount);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isBedSelected
                              ? const Color(0xFF002060)
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isBedSelected
                                ? const Color(0xFF002060)
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "$bedCount",
                          style: TextStyle(
                            color: isBedSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _MealTag extends StatelessWidget {
  final String label;
  const _MealTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF2E7D32),
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
