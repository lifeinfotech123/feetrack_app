import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

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
                  final dynamicSlots = AppConstants.gymBookingTimeSlots
                      .map(
                        (slot) => <String, dynamic>{
                          "label": slot["label"]!,
                          "title": slot["title"]!,
                          "time": slot["time"]!,
                          "icon": slot["title"] == "Morning"
                              ? Icons.wb_sunny_rounded
                              : Icons.nights_stay_rounded,
                        },
                      )
                      .toList();

                  return GetBuilder<BookAppointController>(
                    id: "time_slot",
                    builder: (bookAppointController) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dynamicSlots.isNotEmpty) ...[
                            const Text(
                              "Available Visit Times",
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
                                        slot["label"] as String,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? primaryColor.withValues(
                                                alpha: 0.08)
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
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: isSelected
                                                            ? primaryColor
                                                                .withValues(
                                                                    alpha: 0.8)
                                                            : greyText3,
                                                      ),
                                                    ),
                                                    if (slot["fee"] != null)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 6,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.green
                                                              .withValues(
                                                                  alpha: 0.12),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Text(
                                                          "${slot["fee"]}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 9.5,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.green,
                                                          ),
                                                        ),
                                                      ),
                                                    if (slot["max_members"] !=
                                                        null)
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
