import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class RoomVisitSelectTimeSection extends StatelessWidget {
  const RoomVisitSelectTimeSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Time Slots",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                color: blackText3,
              ),
        ),
        sizedBoxHeight(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: white,
              border: Border.all(width: 1, color: greyLight3)),
          child: GetBuilder<BookAppointController>(
            id: "time_slot",
            builder: (bookAppointController) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bookAppointController.timeSlotList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.4,
                ),
                itemBuilder: (context, index) {
                  final time = bookAppointController.timeSlotList[index];
                  final isEnabled = bookAppointController.canSelectTime(time);

                  return GestureDetector(
                    onTap: isEnabled
                        ? () {
                            bookAppointController.selectTime(time);
                          }
                        : null,
                    child: _RoomTimeSlotContainer(
                      key: ValueKey(time),
                      isSelected: bookAppointController.isTimeSelected(time),
                      isEnabled: isEnabled,
                      time: time,
                    ),
                  );
                },
              );
            },
          ),
        )
      ],
    );
  }
}

class _RoomTimeSlotContainer extends StatelessWidget {
  const _RoomTimeSlotContainer({
    super.key,
    required this.isSelected,
    required this.isEnabled,
    required this.time,
  });

  final bool isSelected;
  final bool isEnabled;
  final String time;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? primaryColor
            : isEnabled
                ? white
                : greyLight4.withValues(alpha: 0.15),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : isEnabled
                  ? greyLight2.withValues(alpha: 0.6)
                  : greyLight4.withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ]
            : [],
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 12.5,
          letterSpacing: -0.2,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected
              ? white
              : isEnabled
                  ? blackText1
                  : greyDart.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
