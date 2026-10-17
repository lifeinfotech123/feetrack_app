import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/gym/gym_book_visit/widget/gym_book_container.dart';

class GYMBookVisiSelectTimeSection extends StatelessWidget {
  const GYMBookVisiSelectTimeSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 18,
            spreadRadius: 0,
            color: black.withValues(alpha: 0.05),
          )
        ],
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "2",
                      style: Helper(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: primaryColor,
                          ),
                    ),
                  ),
                  sizedBoxWidth(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Time Slot",
                        style: Helper(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: blackText1,
                            ),
                      ),
                      const SizedBox(height: 2),
                      GetBuilder<HomeController>(builder: (homeController) {
                        final listing = homeController.selectListingModel;
                        final open = listing?.openingTime;
                        final close = listing?.closingTime;
                        if (open == null || close == null || open.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time_rounded,
                                  size: 11, color: Colors.green),
                              const SizedBox(width: 3),
                              Text(
                                "$open - $close",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 2),
                      Text(
                        "Choose your preferred visit time",
                        style: TextStyle(
                          fontSize: 11,
                          color: greyText3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GetBuilder<BookAppointController>(
            id: "time_slot",
            builder: (bookAppointController) {
              if (bookAppointController.selectedTime.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 14, color: primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        "Selected: ${bookAppointController.selectedTime}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          sizedBoxHeight(height: 12),
          GetBuilder<GymController>(
            builder: (gymController) {
              return GetBuilder<HomeController>(
                builder: (homeController) {
                  final listing = homeController.selectListingModel;
                  final List<Map<String, dynamic>> dynamicSlots = [];

                  if (gymController.gymShiftsList.isNotEmpty) {
                    for (var s in gymController.gymShiftsList) {
                      final label = s.shiftLabel ??
                          (s.startTime != null && s.endTime != null
                              ? "${s.shiftName} (${s.startTime} - ${s.endTime})"
                              : (s.shiftName ?? "Shift"));
                      dynamicSlots.add({
                        "label": label,
                        "title": s.shiftName ?? "Shift",
                        "time": "${s.startTime ?? ''} - ${s.endTime ?? ''}",
                        "icon": s.icon,
                        "fee": s.formattedFee,
                        "max_members": s.maxMembers,
                      });
                    }
                  } else {
                    final gymShifts = listing?.shifts;
                    if (gymShifts != null && gymShifts.isNotEmpty) {
                      for (var s in gymShifts) {
                        final map = s is Map
                            ? Map<String, dynamic>.from(s)
                            : <String, dynamic>{};
                        final shiftName =
                            (map['shift_label'] ?? map['shift_name'] ?? 'Shift')
                                .toString();
                        final startTime = map['start_time']?.toString() ?? '';
                        final endTime = map['end_time']?.toString() ?? '';
                        final timeLabel = (map['time_label'] != null &&
                                map['time_label'].toString().isNotEmpty)
                            ? map['time_label'].toString()
                            : (startTime.isNotEmpty && endTime.isNotEmpty
                                ? "$startTime - $endTime"
                                : '');

                        final lower = shiftName.toLowerCase();
                        IconData icon = Icons.access_time_filled_rounded;
                        if (lower.contains('morning')) {
                          icon = Icons.wb_sunny_rounded;
                        } else if (lower.contains('afternoon')) {
                          icon = Icons.wb_twilight_rounded;
                        } else if (lower.contains('evening') ||
                            lower.contains('night')) {
                          icon = Icons.nights_stay_rounded;
                        }

                        final fullLabel = timeLabel.isNotEmpty
                            ? "$shiftName ($timeLabel)"
                            : shiftName;

                        dynamicSlots.add({
                          "label": fullLabel,
                          "title": shiftName,
                          "time": timeLabel,
                          "icon": icon,
                          "fee": map['formatted_fee'] ??
                              (map['fee'] == 0 ? 'Included in Plan' : null),
                          "max_members": map['max_members'],
                        });
                      }
                    }
                  }

              return GetBuilder<BookAppointController>(
                id: "time_slot",
                builder: (bookAppointController) {
                  final hasHourlySlots =
                      bookAppointController.timeSlotList.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Dynamic Shifts from API ───────────────────────
                      if (dynamicSlots.isNotEmpty) ...[
                        const Text(
                          "Available Shifts (From Gym)",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF555555),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: dynamicSlots.map((slot) {
                            final isSelected =
                                bookAppointController.selectedTime ==
                                    slot["label"];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                onTap: () {
                                  bookAppointController.selectPreferredSlot(
                                      slot["label"] as String);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primaryColor.withValues(alpha: 0.08)
                                        : const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.grey.shade200,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? primaryColor
                                              : Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          slot["icon"] as IconData,
                                          size: 16,
                                          color: isSelected
                                              ? Colors.white
                                              : greyText3,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              slot["title"] as String,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? primaryColor
                                                    : blackText1,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Wrap(
                                              spacing: 6,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Text(
                                                  slot["time"] as String,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: isSelected
                                                        ? primaryColor
                                                            .withValues(
                                                                alpha: 0.8)
                                                        : greyText3,
                                                  ),
                                                ),
                                                if (slot["fee"] != null)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green
                                                          .withValues(
                                                              alpha: 0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      "${slot["fee"]}",
                                                      style: const TextStyle(
                                                        fontSize: 9.5,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ),
                                                if (slot["max_members"] != null)
                                                  Text(
                                                    "• Cap: ${slot["max_members"]} members",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: greyText3,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                .radio_button_unchecked_rounded,
                                        color: isSelected
                                            ? primaryColor
                                            : Colors.grey.shade300,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (hasHourlySlots) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                      color: Colors.grey.shade200, height: 1)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "or choose specific hour",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: greyText3,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Divider(
                                      color: Colors.grey.shade200, height: 1)),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],

                      // ── Dynamic Hourly Slots (From Gym Operating Hours) ─
                      if (!hasHourlySlots && dynamicSlots.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          decoration: BoxDecoration(
                            color: greyLight.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: greyLight2.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.event_busy_rounded,
                                  color: greyDart.withValues(alpha: 0.6),
                                  size: 24),
                              const SizedBox(height: 6),
                              Text(
                                "No visit slots configured for this gym",
                                style: TextStyle(
                                  color: blackText1,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (hasHourlySlots) ...[
                        if (dynamicSlots.isEmpty) ...[
                          const Text(
                            "Choose Preferred Hour",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF555555),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bookAppointController.timeSlotList.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 2.35,
                          ),
                          itemBuilder: (context, index) {
                            final time =
                                bookAppointController.timeSlotList[index];
                            final isEnabled =
                                bookAppointController.canSelectTime(time);

                            return GestureDetector(
                              onTap: isEnabled
                                  ? () {
                                      bookAppointController.selectTime(time);
                                    }
                                  : null,
                              child: TimeSlotContainer(
                                key: ValueKey(time),
                                isSelected:
                                    bookAppointController.isTimeSelected(time),
                                isEnabled: isEnabled,
                                time: time,
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          );
        },
      ),
        ],
      ),
    );
  }
}
