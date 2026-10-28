import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({Key? key}) : super(key: key);

  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'TKT-8902',
      'subject': 'Delay in pathology test report delivery',
      'category': 'Lab Tests',
      'date': '13 Sep 2026',
      'status': 'Resolved',
      'response': 'Report was uploaded and dispatched to your email.',
    },
    {
      'id': 'TKT-9144',
      'subject': 'Refund status for rescheduled consultation',
      'category': 'Billing / Payments',
      'date': '15 Sep 2026',
      'status': 'In-Progress',
      'response': 'Bank reference #RF-2910 has been generated, refund expected in 24h.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Helpdesk & Support Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
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
            // Quick 24/7 Chat Card
            ModernCard(
              color: fillColor,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.support_agent, color: colorWhite, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('24/7 AI Healthcare Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryDark)),
                        Text('Instant resolution for appointments, reports & billing queries.', style: TextStyle(fontSize: 11, color: textDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Support Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: () => _showRaiseTicketDialog(context),
                  icon: const Icon(Icons.add, size: 16, color: colorWhite),
                  label: const Text('New Ticket', style: TextStyle(color: colorWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._tickets.map((t) {
              final isResolved = t['status'] == 'Resolved';
              return ModernCard(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryColor)),
                        StatusBadgeWidget(
                          label: t['status'],
                          textColor: isResolved ? wellnessGreen : warningColor,
                          bgColor: isResolved ? wellnessGreenBg : Colors.amber.withOpacity(0.18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(t['subject'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                    const SizedBox(height: 2),
                    Text('${t['category']} • ${t['date']}', style: const TextStyle(fontSize: 11, color: textMuted)),
                    const Divider(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
                      child: Text('Support Team: ${t['response']}', style: const TextStyle(fontSize: 11, color: textDark)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showRaiseTicketDialog(BuildContext context) {
    final subCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Appointments';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Raise Support Ticket', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Issue Category'),
              items: ['Appointments', 'Lab Tests', 'Billing / Payments', 'Medicine Delivery', 'Doctor Consultation'].map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (val) => category = val ?? 'Appointments',
            ),
            const SizedBox(height: 8),
            TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'Subject / Title')),
            const SizedBox(height: 8),
            TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Describe the issue')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              if (subCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _tickets.insert(0, {
                    'id': 'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                    'subject': subCtrl.text.trim(),
                    'category': category,
                    'date': 'Today',
                    'status': 'Open',
                    'response': 'Our support specialist will review and respond within 2 hours.',
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: primaryColor, content: Text('Support ticket raised successfully!')),
                );
              }
            },
            child: const Text('Submit Ticket', style: TextStyle(color: colorWhite)),
          ),
        ],
      ),
    );
  }
}
