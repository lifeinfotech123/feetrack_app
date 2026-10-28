import 'package:flutter/material.dart';
import 'package:vlr/data/models/category_model/staff_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/gym/gym_trainer_profile_screen/gym_trainer_profile_screen.dart';

class GYmProfileTrainerProfileWidget extends StatelessWidget {
  final StaffModel staffModel;
  const GYmProfileTrainerProfileWidget({
    super.key,
    required this.staffModel,
  });

  void _onOpenTrainerDetails(BuildContext context) {
    final trainerId = staffModel.stringId ?? staffModel.id?.toString() ?? "";
    navigate(
      context: context,
      page: GymTrainerProfileScreen(
        staffId: trainerId,
        initialStaff: staffModel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _onOpenTrainerDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Trainer Image ──────────────────────────────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CustomImage(
                    path: staffModel.photoUrl ?? "",
                    width: double.infinity,
                    height: 135,
                    radius: 14,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Trainer Name ───────────────────────────────────
                Text(
                  staffModel.name ?? "Trainer",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 3),

                // ── Specialization & Experience ─────────────────────
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        staffModel.specialization?.isNotEmpty == true
                            ? staffModel.specialization!
                            : "Fitness Coach",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: greyText2,
                        ),
                      ),
                    ),
                    if (staffModel.experienceYears != null &&
                        staffModel.experienceYears!.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.circle,
                        size: 3.5,
                        color: greyText2,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          staffModel.experienceYears!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const Spacer(),

                // ── View Details Button ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => _onOpenTrainerDetails(context),
                    icon: const Icon(
                      Icons.person_outline_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "View Details",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002060),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
