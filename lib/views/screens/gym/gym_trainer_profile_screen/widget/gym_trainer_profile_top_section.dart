import 'package:flutter/material.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';

class GYMTrainerProfileTopSection extends StatelessWidget {
  final StaffModel? staff;
  const GYMTrainerProfileTopSection({
    super.key,
    this.staff,
  });

  @override
  Widget build(BuildContext context) {
    final gymName = staff?.gymTitle ?? staff?.gym?['title']?.toString() ?? "";
    final gymCity = staff?.gym?['city']?.toString() ?? "";

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8E8FF),
            Color(0xFFF3F3FF),
          ],
        ),
      ),
      child: Column(
        children: [
          sizedBoxHeight(height: 20),
          // Trainer Image
          Container(
            height: 280,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CustomImage(
                path: staff?.photoUrl ?? "",
                fit: BoxFit.cover,
                width: double.infinity,
                radius: 24,
              ),
            ),
          ),
          sizedBoxHeight(height: 16),
          // White Card Section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                children: [
                  Text(
                    staff?.name ?? "Trainer",
                    textAlign: TextAlign.center,
                    style: Helper(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: blackText1,
                        ),
                  ),
                  if (staff?.specialization != null &&
                      staff!.specialization!.isNotEmpty) ...[
                    sizedBoxHeight(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF002060).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        staff!.specialization!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF002060),
                        ),
                      ),
                    ),
                  ],
                  if (gymName.isNotEmpty) ...[
                    sizedBoxHeight(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fitness_center_rounded,
                            size: 14, color: primaryColor),
                        const SizedBox(width: 5),
                        Text(
                          gymCity.isNotEmpty ? "$gymName, $gymCity" : gymName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: greyText2,
                          ),
                        ),
                      ],
                    ),
                  ],
                  sizedBoxHeight(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        context,
                        staff?.experienceYears?.isNotEmpty == true
                            ? staff!.experienceYears!
                            : "5+ Yrs",
                        "Experience",
                      ),
                      _buildStatItem(
                        context,
                        staff?.shifts != null && staff!.shifts!.isNotEmpty
                            ? "${staff!.shifts!.length} Shifts"
                            : "Daily",
                        "Available",
                      ),
                      _buildStatItem(
                        context,
                        "Certified",
                        "Fitness Pro",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Container(
      width: (MediaQuery.of(context).size.width - 80) / 3,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Helper(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: blackText1,
                ),
          ),
          sizedBoxHeight(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Helper(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                  color: greyText3,
                  height: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}
