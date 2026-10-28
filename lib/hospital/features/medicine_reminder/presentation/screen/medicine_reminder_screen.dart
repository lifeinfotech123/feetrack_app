import 'package:flutter/material.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/widgets/animated_widgets.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/core/widgets/animated_widgets.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({Key? key}) : super(key: key);

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final List<Map<String, dynamic>> _reminders = [
    {
      'id': '1',
      'medicine': 'Amoxicillin 500mg',
      'dosage': '1 Capsule',
      'slot': 'Morning (08:30 AM)',
      'timing': 'After Breakfast',
      'taken': true,
      'color': primaryColor,
    },
    {
      'id': '2',
      'medicine': 'Vitamin C + Zinc',
      'dosage': '1 Tablet',
      'slot': 'Afternoon (01:30 PM)',
      'timing': 'After Lunch',
      'taken': false,
      'color': pharmacyTeal,
    },
    {
      'id': '3',
      'medicine': 'Pantoprazole 40mg',
      'dosage': '1 Tablet',
      'slot': 'Night (09:00 PM)',
      'timing': 'Before Dinner (Empty stomach)',
      'taken': false,
      'color': diagnosticViolet,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final takenCount = _reminders.where((r) => r['taken'] == true).length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Medicine Pill Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Adherence Progress Card
            ModernCard(
              color: primaryColor,
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 58,
                        height: 58,
                        child: CircularProgressIndicator(
                          value: _reminders.isEmpty ? 0 : takenCount / _reminders.length,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                          strokeWidth: 6,
                        ),
                      ),
                      Text(
                        '${((takenCount / _reminders.length) * 100).toInt()}%',
                        style: const TextStyle(color: colorWhite, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Today’s Medication Progress', style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('$takenCount of ${_reminders.length} doses taken today', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Today’s Schedule'),
            ...List.generate(_reminders.length, (index) {
              final r = _reminders[index];
              final bool isTaken = r['taken'] as bool;
              final Color color = r['color'] as Color;

              return FadeSlideTransitionWidget(
                index: index,
                child: ModernCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                        child: Icon(Icons.medication_liquid, color: color, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['medicine'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                            const SizedBox(height: 2),
                            Text('${r['dosage']} • ${r['timing']}', style: const TextStyle(fontSize: 11, color: textMuted)),
                            const SizedBox(height: 4),
                            StatusBadgeWidget(label: r['slot'], textColor: color, bgColor: color.withOpacity(0.12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isTaken ? wellnessGreen : colorGrey,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            r['taken'] = !isTaken;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: !isTaken ? wellnessGreen : primaryColor,
                              content: Text(!isTaken ? 'Marked ${r['medicine']} as taken!' : 'Pill dose reset.'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _showAddReminderDialog(context),
                icon: const Icon(Icons.alarm_add, color: colorWhite),
                label: const Text('Add New Pill Alarm', style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    final medCtrl = TextEditingController();
    String timeSlot = 'Morning (08:00 AM)';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Set Medication Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: medCtrl,
              decoration: const InputDecoration(labelText: 'Medicine Name', prefixIcon: Icon(Icons.medication)),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: timeSlot,
              decoration: const InputDecoration(labelText: 'Dose Time'),
              items: ['Morning (08:00 AM)', 'Afternoon (01:30 PM)', 'Evening (06:00 PM)', 'Night (09:00 PM)'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => timeSlot = val ?? 'Morning (08:00 AM)',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              if (medCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _reminders.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'medicine': medCtrl.text.trim(),
                    'dosage': '1 Dose',
                    'slot': timeSlot,
                    'timing': 'After Meals',
                    'taken': false,
                    'color': primaryColor,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: wellnessGreen, content: Text('Pill reminder set with notification sound!')),
                );
              }
            },
            child: const Text('Set Alarm', style: TextStyle(color: colorWhite)),
          ),
        ],
      ),
    );
  }
}
