import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class RoomVisitDetailsWidget extends StatelessWidget {
  const RoomVisitDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookAppointController>(
      builder: (bookAppointController) {
        final formattedDate = DateFormat("EEEE, MMM d, yyyy")
            .format(bookAppointController.selectedDate);
        final formattedTime = bookAppointController.selectedTime.isNotEmpty
            ? bookAppointController.selectedTime
            : "11:30 AM";

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 1, color: greyLight6),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: primaryColor,
                  ),
                  sizedBoxWidth(width: 8),
                  Text(
                    "Visit Appointment Detail",
                    style: Helper(context).textTheme.titleMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: blackText3,
                        ),
                  ),
                ],
              ),
              sizedBoxHeight(height: 20),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Visit Date",
                        style: Helper(context).textTheme.labelLarge?.copyWith(
                              fontSize: 14,
                              color: greyDart2,
                            ),
                      ),
                      Text(
                        formattedDate,
                        style: Helper(context).textTheme.titleSmall?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: blackText3,
                            ),
                      ),
                    ],
                  ),
                  sizedBoxHeight(height: 10),
                  Divider(
                    color: greyLight6.withValues(alpha: 0.50),
                  )
                ],
              ),
              sizedBoxHeight(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Preferred Slot",
                    style: Helper(context).textTheme.labelLarge?.copyWith(
                          fontSize: 14,
                          color: greyDart2,
                        ),
                  ),
                  Text(
                    formattedTime,
                    style: Helper(context).textTheme.titleSmall?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
