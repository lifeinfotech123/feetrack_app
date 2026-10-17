import 'package:flutter/material.dart';
import 'package:vlr/services/theme.dart';

class TimeSlotContainer extends StatelessWidget {
  const TimeSlotContainer({
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
