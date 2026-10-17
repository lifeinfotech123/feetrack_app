import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/data/models/gym_shift_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/gym/gym_select_plan_screen.dart/gym_select_plan_screen.dart';

class GymShiftDetailSheet extends StatefulWidget {
  final GymShiftModel shift;

  const GymShiftDetailSheet({
    super.key,
    required this.shift,
  });

  static Future<void> show(BuildContext context, GymShiftModel shift) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GymShiftDetailSheet(shift: shift),
    );
  }

  @override
  State<GymShiftDetailSheet> createState() => _GymShiftDetailSheetState();
}

class _GymShiftDetailSheetState extends State<GymShiftDetailSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.shift.id != null && widget.shift.id!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.find<GymController>()
            .fetchGymShiftDetails(shiftId: widget.shift.id!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: GetBuilder<GymController>(
        builder: (gymController) {
          final shift = gymController.gymShiftDetails ?? widget.shift;
          final gym = shift.gym;
          final website = shift.website;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF022C7F).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            shift.icon,
                            color: const Color(0xFF022C7F),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shift.shiftName ?? "Gym Shift",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            Text(
                              "Shift #${shift.id ?? ''}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              Flexible(
                child: gymController.isGymShiftDetailsLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Shift timing card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF022C7F), Color(0xFF1E5BB8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF022C7F)
                                        .withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        shift.shiftLabel ?? shift.displayTiming,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          shift.formattedFee,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _shiftMetricPill(
                                        icon: Icons.access_time_rounded,
                                        label: "Start",
                                        value: shift.startTime ?? "06:00 AM",
                                      ),
                                      const SizedBox(width: 12),
                                      _shiftMetricPill(
                                        icon: Icons.timelapse_rounded,
                                        label: "End",
                                        value: shift.endTime ?? "08:00 AM",
                                      ),
                                      const SizedBox(width: 12),
                                      _shiftMetricPill(
                                        icon: Icons.people_alt_rounded,
                                        label: "Capacity",
                                        value:
                                            "${shift.maxMembers ?? 30} Max",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Gym Information section
                            if (gym != null) ...[
                              const Text(
                                "Gym Details",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: [
                                    _infoRow(
                                      icon: Icons.fitness_center_rounded,
                                      title: "Gym Name",
                                      value: gym.title ?? "GoGym",
                                    ),
                                    if (gym.city != null &&
                                        gym.city!.isNotEmpty) ...[
                                      const Divider(height: 16),
                                      _infoRow(
                                        icon: Icons.location_city_rounded,
                                        title: "City",
                                        value: gym.city!,
                                      ),
                                    ],
                                    if (gym.address != null &&
                                        gym.address!.isNotEmpty) ...[
                                      const Divider(height: 16),
                                      _infoRow(
                                        icon: Icons.place_rounded,
                                        title: "Address",
                                        value: gym.address!,
                                      ),
                                    ],
                                    if (gym.phone != null &&
                                        gym.phone!.isNotEmpty) ...[
                                      const Divider(height: 16),
                                      _infoRow(
                                        icon: Icons.phone_rounded,
                                        title: "Phone",
                                        value: gym.phone!,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Website / Portal section
                            if (website != null) ...[
                              const Text(
                                "Partner / Portal",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  children: [
                                    _infoRow(
                                      icon: Icons.business_rounded,
                                      title: "Organization",
                                      value: website.name ?? "Team one ptl",
                                    ),
                                    if (website.domain != null &&
                                        website.domain!.isNotEmpty) ...[
                                      const Divider(height: 16),
                                      _infoRow(
                                        icon: Icons.domain_rounded,
                                        title: "Domain",
                                        value: website.domain!,
                                      ),
                                    ],
                                    if (website.portalUrl != null &&
                                        website.portalUrl!.isNotEmpty) ...[
                                      const Divider(height: 16),
                                      _infoRow(
                                        icon: Icons.link_rounded,
                                        title: "Portal URL",
                                        value: website.portalUrl!,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ],
                        ),
                      ),
              ),

              // Bottom action button
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom: MediaQuery.of(context).padding.bottom + 12,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      gymController.selectGymShift(shift);
                      Navigator.pop(context);
                      navigate(
                        context: context,
                        page: const GymSelectPlanScreen(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF022C7F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Select & Book Membership",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _shiftMetricPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF022C7F)),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }
}
