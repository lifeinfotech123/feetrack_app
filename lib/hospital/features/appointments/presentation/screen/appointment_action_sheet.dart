import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';


class AppointmentActionSheet {
  static void showManageAppointment(BuildContext context, {
    required String doctorName,
    required String specialty,
    required String date,
    required String time,
    required VoidCallback onUpdate,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: fillColor,
                  child: Icon(Icons.person, color: primaryColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                      Text(specialty, style: const TextStyle(color: primaryColor, fontSize: 12)),
                      Text('$date • $time', style: const TextStyle(color: textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            const Text('Manage Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            _buildActionItem(
              icon: Icons.calendar_month_outlined,
              title: 'Reschedule Appointment',
              subtitle: 'Pick a new date and convenient time slot',
              color: primaryColor,
              onTap: () {
                Navigator.pop(ctx);
                _showRescheduleDialog(context, doctorName, onUpdate);
              },
            ),
            const SizedBox(height: 10),
            _buildActionItem(
              icon: Icons.notifications_active_outlined,
              title: 'Reminder Settings',
              subtitle: 'SMS, Push notification & WhatsApp reminders',
              color: ambulanceAmber,
              onTap: () {
                Navigator.pop(ctx);
                _showReminderPreferences(context);
              },
            ),
            const SizedBox(height: 10),
            _buildActionItem(
              icon: Icons.cancel_outlined,
              title: 'Cancel Appointment',
              subtitle: 'Free cancellation up to 2 hours before slot',
              color: errorColor,
              onTap: () {
                Navigator.pop(ctx);
                _showCancelConfirmation(context, onUpdate);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: textMuted)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: colorGrey),
        ],
      ),
    );
  }

  static void _showRescheduleDialog(BuildContext context, String doctorName, VoidCallback onUpdate) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Reschedule: $doctorName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select New Date:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Tomorrow, 10 AM', 'Tomorrow, 04 PM', 'Friday, 11 AM'].map((slot) {
                return ActionChip(
                  label: Text(slot, style: const TextStyle(fontSize: 11)),
                  backgroundColor: fillColor,
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: primaryColor,
                        content: Text('Appointment rescheduled to $slot!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    onUpdate();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  static void _showCancelConfirmation(BuildContext context, VoidCallback onUpdate) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Cancel Appointment?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: const Text(
          'Are you sure you want to cancel this booking? Refund (if paid) will be initiated instantly.',
          style: TextStyle(fontSize: 13, color: textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: errorColor),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: errorColor,
                  content: Text('Appointment cancelled successfully.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              onUpdate();
            },
            child: const Text('Confirm Cancel', style: TextStyle(color: colorWhite)),
          ),
        ],
      ),
    );
  }

  static void _showReminderPreferences(BuildContext context) {
    bool pushEnabled = true;
    bool whatsappEnabled = true;
    bool smsEnabled = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: colorWhite,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Appointment Reminder Channels', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              const Text('Get timely alerts 24h and 2h before consultation.', style: TextStyle(color: textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              SwitchListTile(
                value: pushEnabled,
                title: const Text('Push Notification', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Alert on your mobile device', style: TextStyle(fontSize: 11)),
                activeColor: primaryColor,
                onChanged: (val) => setState(() => pushEnabled = val),
              ),
              SwitchListTile(
                value: whatsappEnabled,
                title: const Text('WhatsApp Reminder', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Includes doctor link & directions', style: TextStyle(fontSize: 11)),
                activeColor: wellnessGreen,
                onChanged: (val) => setState(() => whatsappEnabled = val),
              ),
              SwitchListTile(
                value: smsEnabled,
                title: const Text('SMS Text Message', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: const Text('Standard SMS alert', style: TextStyle(fontSize: 11)),
                activeColor: primaryColor,
                onChanged: (val) => setState(() => smsEnabled = val),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: wellnessGreen,
                        content: Text('Reminder preferences saved!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Save Preferences', style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
