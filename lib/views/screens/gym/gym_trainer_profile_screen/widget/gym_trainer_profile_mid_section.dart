import 'package:flutter/material.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/data/models/gym_trainer_core_specialties_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/gym/gym_trainer_profile_screen/widget/core_specialties_widget.dart';

class GYMTrainerProfileMidSection extends StatelessWidget {
  final StaffModel? staff;
  const GYMTrainerProfileMidSection({
    super.key,
    this.staff,
  });

  @override
  Widget build(BuildContext context) {
    final shifts = staff?.shifts ?? [];
    final gym = staff?.gym;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. About / Philosophy ─────────────────────────────────────
        _buildSectionTitle(context, "About Trainer"),
        sizedBoxHeight(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            (staff?.description != null &&
                    staff!.description!.trim().isNotEmpty)
                ? staff!.description!
                : "Certified fitness trainer focused on personalized guidance, body transformation, strength training, and metabolic conditioning.",
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
        ),

        // ── 2. Working Shifts & Timings (From API) ───────────────────
        if (shifts.isNotEmpty) ...[
          sizedBoxHeight(height: 26),
          _buildSectionTitle(context, "Working Shifts & Timings"),
          sizedBoxHeight(height: 10),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shifts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final shift = shifts[index] is Map ? shifts[index] as Map : {};
              final name = shift['shift_name']?.toString() ?? "Shift";
              final time = shift['time_label']?.toString() ?? "";
              final isMorning = name.toLowerCase().contains("morning");

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (isMorning ? Colors.amber : const Color(0xFF002060))
                                .withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isMorning
                            ? Icons.wb_sunny_rounded
                            : Icons.nights_stay_rounded,
                        size: 18,
                        color: isMorning
                            ? Colors.amber.shade800
                            : const Color(0xFF002060),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          if (time.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: greyText2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Available",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],

        // ── 3. Gym Information ───────────────────────────────────────
        if (gym != null && gym['title'] != null) ...[
          sizedBoxHeight(height: 26),
          _buildSectionTitle(context, "Gym Branch"),
          sizedBoxHeight(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF002060).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF002060),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym['title']?.toString() ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [gym['address'], gym['city']]
                            .where((e) => e != null && e.toString().isNotEmpty)
                            .join(", "),
                        style: TextStyle(
                          fontSize: 12,
                          color: greyText2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // ── 4. Core Specialties ──────────────────────────────────────
        sizedBoxHeight(height: 26),
        _buildSectionTitle(context, "Core Specialties"),
        sizedBoxHeight(height: 12),
        GridView.builder(
          shrinkWrap: true,
          itemCount: gymTrainerCoreSpecialtiesModelList.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (_, index) {
            final specialty = gymTrainerCoreSpecialtiesModelList[index];
            return CoreSpecialtiesWidget(
              gymTrainerCoreSpecialtiesModel: specialty,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Helper(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: blackText1,
            letterSpacing: 0.5,
          ),
    );
  }
}
