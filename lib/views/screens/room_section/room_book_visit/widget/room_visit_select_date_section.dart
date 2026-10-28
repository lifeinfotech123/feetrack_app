import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class RoomVisitSelectDateSection extends StatelessWidget {
  const RoomVisitSelectDateSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Date",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                color: blackText3,
              ),
        ),
        sizedBoxHeight(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: greyLight,
          ),
          child: GetBuilder<BookAppointController>(
            id: "selected_date",
            builder: (bookAppointController) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: white,
                    border: Border.all(width: 1, color: greyLight3)),
                child: TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime(
                    DateTime.now().year,
                    DateTime.now().month + 2,
                    DateTime.now().day,
                  ),
                  focusedDay: bookAppointController.selectedDate,
                  selectedDayPredicate: (day) {
                    return isSameDay(
                      bookAppointController.selectedDate,
                      day,
                    );
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    bookAppointController.selectDate(selectedDay);
                  },

                  // Remove month/year picker tap
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,

                    // Remove left/right chevrons if needed
                    leftChevronVisible: false,
                    rightChevronVisible: false,

                    // Current month text
                    titleTextStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textBlue,
                    ),
                  ),

                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: textBlue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: textBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
