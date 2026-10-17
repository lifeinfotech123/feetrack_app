import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/data/models/gym_shift_model.dart';
import 'package:vlr/views/screens/gym/gym_profile/widget/gym_shift_section/gym_shift_detail_sheet.dart';

class GYMProfileShiftSection extends StatelessWidget {
  final String? gymId;

  const GYMProfileShiftSection({
    super.key,
    this.gymId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GymController>(
      builder: (gymController) {
        if (gymController.isGymShiftsLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, count: 0, isLoading: true),
                const SizedBox(height: 12),
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          );
        }

        final shifts = gymController.gymShiftsList;
        if (shifts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, count: shifts.length),
            const SizedBox(height: 14),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shifts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shift = shifts[index];
                final isSelected = gymController.selectedGymShift?.id == shift.id;

                return _ShiftCard(
                  shift: shift,
                  isSelected: isSelected,
                  onTap: () {
                    gymController.selectGymShift(shift);
                  },
                  onDetailsTap: () {
                    GymShiftDetailSheet.show(context, shift);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context,
      {required int count, bool isLoading = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Gym Shifts & Timings",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                    letterSpacing: -0.2,
                  ),
                ),
                if (!isLoading && count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF022C7F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$count Slots",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF022C7F),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              "Available workout shifts for this gym",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final GymShiftModel shift;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDetailsTap;

  const _ShiftCard({
    required this.shift,
    required this.isSelected,
    required this.onTap,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final shiftName = shift.shiftName ?? "Shift";
    final isMorning = shiftName.toLowerCase().contains("morning");

    final Color badgeBg = isMorning
        ? const Color(0xFFFFF7ED)
        : const Color(0xFFEFF6FF);
    final Color badgeText = isMorning
        ? const Color(0xFFC2410C)
        : const Color(0xFF1D4ED8);
    final Color iconColor = isMorning
        ? const Color(0xFFEA580C)
        : const Color(0xFF2563EB);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF022C7F).withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF022C7F)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.06 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Top Row: Shift Name Pill, Free/Fee Badge, Details Button
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: badgeText.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(shift.icon, size: 14, color: iconColor),
                      const SizedBox(width: 6),
                      Text(
                        shiftName,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: badgeText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    shift.formattedFee,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onDetailsTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 13, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        Text(
                          "Details",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? const Color(0xFF022C7F)
                      : Colors.grey.shade300,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Time Row
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Color(0xFF022C7F),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    shift.shiftLabel ??
                        "${shift.startTime ?? ''} - ${shift.endTime ?? ''}",
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Bottom info: Cap members + Gym Title & City
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.people_outline_rounded,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "Capacity: ${shift.maxMembers ?? 30} Members",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (shift.gym?.title != null) ...[
                  Row(
                    children: [
                      Icon(Icons.storefront_outlined,
                          size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        "${shift.gym!.title!}${shift.gym?.city != null ? ' (${shift.gym!.city!})' : ''}",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
