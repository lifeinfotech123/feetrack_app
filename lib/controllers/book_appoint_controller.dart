import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:vlr/data/repositories/book_appoint_repo.dart';

class BookAppointController extends GetxController implements GetxService {
  final BookAppointRepo bookAppointRepo;
  static const Duration slotInterval = Duration(minutes: 30);

  BookAppointController({required this.bookAppointRepo});

  DateTime selectedDate = DateTime.now();

  String selectedTime = "";
  final Duration appointmentDuration = const Duration(hours: 1);

  DateTime get _today => DateTime.now();

  bool get isSelectedDateToday {
    final today = _today;
    return selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;
  }

  void selectTime(String time) {
    if (!canSelectTime(time)) {
      return;
    }

    selectedTime = time;
    update(["time_slot"]);
  }

  void selectPreferredSlot(String slot) {
    selectedTime = slot;
    update(["time_slot"]);
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    selectedTime = "";
    generateTimeSlots();
    update(["selected_date", "time_slot"]);
  }

  void reset() {
    selectedDate = DateTime.now();
    selectedTime = "";
    openTime = "08:00";
    closeTime = "20:00";
    timeSlotList.clear();
    generateTimeSlots();
    update(["selected_date", "time_slot"]);
    update();
  }

  String openTime = "08:00";
  String closeTime = "20:00";

  List<String> timeSlotList = [];

  int get durationSlotCount {
    final durationInMinutes = appointmentDuration.inMinutes;
    final slotMinutes = slotInterval.inMinutes;
    return ((durationInMinutes + slotMinutes - 1) ~/ slotMinutes).clamp(1, 24);
  }

  DateTime _parseSlotTime(String time) {
    try {
      final match = RegExp(r'(\d{1,2}):(\d{2})\s*(AM|PM)?', caseSensitive: false).firstMatch(time);
      if (match != null) {
        var hour = int.parse(match.group(1)!);
        final minute = int.parse(match.group(2)!);
        final period = match.group(3)?.toUpperCase();

        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;

        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          hour,
          minute,
        );
      }
    } catch (_) {}
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      9,
      0,
    );
  }

  TimeOfDay _parseTimeString(String? rawTime, TimeOfDay fallback) {
    if (rawTime == null || rawTime.trim().isEmpty) return fallback;
    try {
      final clean = rawTime.trim();
      final isPm = clean.toUpperCase().contains('PM');
      final isAm = clean.toUpperCase().contains('AM');
      final digitsOnly = clean.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = digitsOnly.split(':');
      if (parts.isNotEmpty) {
        int hour = int.parse(parts[0]);
        int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
        if (isPm && hour != 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
        return TimeOfDay(hour: hour.clamp(0, 23), minute: minute.clamp(0, 59));
      }
    } catch (_) {}
    return fallback;
  }

  void setBusinessHours({String? open, String? close}) {
    if (open != null && open.trim().isNotEmpty) {
      final tod = _parseTimeString(open, const TimeOfDay(hour: 6, minute: 0));
      openTime =
          "${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}";
    }
    if (close != null && close.trim().isNotEmpty) {
      final tod = _parseTimeString(close, const TimeOfDay(hour: 22, minute: 0));
      closeTime =
          "${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}";
    }
    generateTimeSlots();
  }

  bool canSelectTime(String time) {
    final slotStart = _parseSlotTime(time);
    final slotEnd = slotStart.add(appointmentDuration);

    final closeTod =
        _parseTimeString(closeTime, const TimeOfDay(hour: 22, minute: 0));
    final closingDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      closeTod.hour,
      closeTod.minute,
    );

    if (slotEnd.isAfter(closingDateTime)) {
      return false;
    }

    if (isSelectedDateToday && !slotStart.isAfter(_today)) {
      return false;
    }

    return true;
  }

  bool isTimeSelected(String time) {
    if (selectedTime.isEmpty) {
      return false;
    }

    final selectedStart = _parseSlotTime(selectedTime);
    final selectedEnd = selectedStart.add(appointmentDuration);
    final slotStart = _parseSlotTime(time);

    return !slotStart.isBefore(selectedStart) && slotStart.isBefore(selectedEnd);
  }

  void generateTimeSlots() {
    timeSlotList.clear();

    final openTod =
        _parseTimeString(openTime, const TimeOfDay(hour: 6, minute: 0));
    final closeTod =
        _parseTimeString(closeTime, const TimeOfDay(hour: 22, minute: 0));

    DateTime start = DateTime(
      2025,
      1,
      1,
      openTod.hour,
      openTod.minute,
    );

    DateTime end = DateTime(
      2025,
      1,
      1,
      closeTod.hour,
      closeTod.minute,
    );

    final now = _today;

    while (start.isBefore(end) || start == end) {
      final slotDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        start.hour,
        start.minute,
      );

      if (!isSelectedDateToday || slotDateTime.isAfter(now)) {
        timeSlotList.add(formatTime(start));
      }

      start = start.add(slotInterval);
    }

    if (!timeSlotList.contains(selectedTime) ||
        (selectedTime.isNotEmpty && !canSelectTime(selectedTime))) {
      selectedTime = "";
    }

    update(["time_slot"]);
  }

  String formatTime(DateTime time) {
    int hour = time.hour;
    String period = hour >= 12 ? "PM" : "AM";

    hour = hour % 12;
    if (hour == 0) hour = 12;

    return "${hour.toString().padLeft(2, '0')}:"
        "${time.minute.toString().padLeft(2, '0')} $period";
  }
}
