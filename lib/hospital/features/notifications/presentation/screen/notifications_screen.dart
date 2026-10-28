import 'package:flutter/material.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/widgets/animated_widgets.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/core/widgets/animated_widgets.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifs = [
    {
      'title': 'Upcoming Appointment Reminder',
      'body': 'You have an appointment with Dr. Mohamed Saeed today at 11:00 AM.',
      'time': '10 mins ago',
      'icon': Icons.calendar_month,
      'color': primaryColor,
      'isRead': false,
    },
    {
      'title': 'Diagnostic Lab Report is Ready!',
      'body': 'Your Complete Blood Count (CBC) test report is now available to download.',
      'time': '1 hour ago',
      'icon': Icons.science,
      'color': diagnosticViolet,
      'isRead': false,
    },
    {
      'title': 'Medicine Time: Amoxicillin 500mg',
      'body': 'Please take your scheduled morning capsule after food.',
      'time': '3 hours ago',
      'icon': Icons.medication,
      'color': pharmacyTeal,
      'isRead': true,
    },
    {
      'title': 'Payment Invoice Generated',
      'body': 'Invoice #INV-2026-4401 of \$45.00 has been paid successfully.',
      'time': 'Yesterday',
      'icon': Icons.receipt,
      'color': wellnessGreen,
      'isRead': true,
    },
    {
      'title': 'Special 50% Health Package Offer',
      'body': 'Use code HEALTH50 for full body checkup discounts this week.',
      'time': '2 days ago',
      'icon': Icons.local_offer,
      'color': offerOrange,
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                for (var n in _notifs) {
                  n['isRead'] = true;
                }
              });
            },
            child: const Text('Mark all read', style: TextStyle(color: colorWhite, fontSize: 12)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifs.length,
        itemBuilder: (context, index) {
          final n = _notifs[index];
          final Color color = n['color'] as Color;
          final bool isRead = n['isRead'] as bool;

          return FadeSlideTransitionWidget(
            index: index,
            child: ModernCard(
              margin: const EdgeInsets.only(bottom: 10),
              color: isRead ? colorWhite : fillColor.withOpacity(0.4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(n['icon'], color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(n['title'], style: TextStyle(fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, fontSize: 13, color: textDark)),
                            ),
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(n['body'], style: const TextStyle(fontSize: 11, color: textMuted)),
                        const SizedBox(height: 6),
                        Text(n['time'], style: const TextStyle(fontSize: 10, color: textMuted)),
                      ],
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
