import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/book_appoint_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class GYMBookVisiSelectDateSection extends StatefulWidget {
  const GYMBookVisiSelectDateSection({
    super.key,
  });

  @override
  State<GYMBookVisiSelectDateSection> createState() =>
      _GYMBookVisiSelectDateSectionState();
}

class _GYMBookVisiSelectDateSectionState
    extends State<GYMBookVisiSelectDateSection> {
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
                      "1",
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
                        "Select Visit Date",
                        style: Helper(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: blackText1,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Choose your preferred day",
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
              GetBuilder<BookAppointController>(
                id: "selected_date",
                builder: (bookAppointController) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            size: 13, color: primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM yyyy')
                              .format(bookAppointController.selectedDate),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Calendar Horizontal List
          GetBuilder<BookAppointController>(
            id: "selected_date",
            builder: (bookAppointController) {
              return SizedBox(
                height: 88,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 60,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final date = DateTime.now().add(Duration(days: index));
                    final isSelected = DateUtils.isSameDay(
                        date, bookAppointController.selectedDate);
                    final isToday = DateUtils.isSameDay(date, DateTime.now());

                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => bookAppointController.selectDate(date),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 62,
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : isToday
                                      ? primaryColor.withValues(alpha: 0.4)
                                      : greyLight2.withValues(alpha: 0.5),
                              width: 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          primaryColor.withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isToday
                                    ? "TODAY"
                                    : DateFormat('EEE')
                                        .format(date)
                                        .toUpperCase(),
                                style: TextStyle(
                                  color: isSelected
                                      ? white.withValues(alpha: 0.9)
                                      : (isToday ? primaryColor : greyDart),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                date.day.toString(),
                                style: TextStyle(
                                  color: isSelected ? white : blackText1,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              if (isToday && !isSelected)
                                Container(
                                  margin: const EdgeInsets.only(top: 3),
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
