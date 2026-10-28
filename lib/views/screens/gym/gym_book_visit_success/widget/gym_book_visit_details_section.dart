import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class GYMVisitDetailsSection extends StatelessWidget {
  const GYMVisitDetailsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          width: 1,
          color: greyText2.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: blueLight3.withValues(alpha: 0.05),
                child: Icon(
                  Icons.calendar_today_outlined,
                  color: primaryText1,
                ),
              ),
              sizedBoxWidth(width: 16),
              Expanded(
                child: Text(
                  "VISIT DETAILS",
                  style: Helper(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        color: primaryText1,
                      ),
                ),
              ),
            ],
          ),
          sizedBoxHeight(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "DATE",
                      style: Helper(context).textTheme.titleLarge?.copyWith(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: greyDart,
                          ),
                    ),
                    sizedBoxHeight(height: 2),
                    Text(
                      "Friday, Oct 6, 2023",
                      style: Helper(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            color: primaryText1,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.calendar_month_outlined,
                color: grey,
              )
            ],
          ),
          sizedBoxHeight(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ARRIVAL TIME",
                      style: Helper(context).textTheme.titleLarge?.copyWith(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: greyDart,
                          ),
                    ),
                    sizedBoxHeight(height: 2),
                    Text(
                      "02:00 PM",
                      style: Helper(context).textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            color: primaryText1,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.watch_later_outlined,
                color: grey,
              )
            ],
          ),
          sizedBoxHeight(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: greyLight,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                width: 1,
                color: greyLight3,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info,
                  color: greenDark,
                ),
                sizedBoxWidth(width: 12),
                Expanded(
                  child: Text(
                    "Please arrive 10 minutes early for check-in and to secure your locker. Bring your digital membership card for entry.",
                    style: Helper(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: greyText2,
                        ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
