import 'package:flutter/material.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/widgets/animated_widgets.dart';

class DoctorFollowupScreen extends StatefulWidget {
  const DoctorFollowupScreen({Key? key}) : super(key: key);

  @override
  State<DoctorFollowupScreen> createState() => _DoctorFollowupScreenState();
}

class _DoctorFollowupScreenState extends State<DoctorFollowupScreen> {
  final List<Map<String, dynamic>> _followups = [
    {
      'doctor': 'Dr. Mohamed Saeed',
      'specialty': 'Neurology Follow-up',
      'hospital': 'City Care Hospital',
      'lastVisit': '14 Sep 2026',
      'recommendedDate': '21 Sep 2026',
      'fee': 'FREE (Within 7 days policy)',
      'status': 'Eligible for Free Follow-up',
    },
    {
      'doctor': 'Dr. Sarah Jenkins',
      'specialty': 'Cardiology Review',
      'hospital': 'Apollo Medical Center',
      'lastVisit': '02 Aug 2026',
      'recommendedDate': '02 Nov 2026',
      'fee': '\$30 (Discounted)',
      'status': 'Quarterly Routine Review',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Doctor Follow-up Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _followups.length,
        itemBuilder: (context, index) {
          final f = _followups[index];

          return FadeSlideTransitionWidget(
            index: index,
            child: ModernCard(
              margin: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadgeWidget(label: f['status'], textColor: wellnessGreen, bgColor: wellnessGreenBg),
                      Text(f['fee'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(f['doctor'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                  Text('${f['specialty']} • ${f['hospital']}', style: const TextStyle(color: textMuted, fontSize: 12)),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Previous Visit: ${f['lastVisit']}', style: const TextStyle(fontSize: 11, color: textMuted)),
                      Text('Due: ${f['recommendedDate']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: primaryColor,
                            content: Text('Follow-up scheduled with ${f['doctor']} on ${f['recommendedDate']}!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.calendar_today, size: 16, color: colorWhite),
                      label: const Text('Confirm Follow-up Slot', style: TextStyle(color: colorWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
