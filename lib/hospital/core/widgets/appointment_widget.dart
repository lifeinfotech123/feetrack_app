import 'package:flutter/material.dart';

import '../constants/colors.dart';

class AppointmentWidget extends StatelessWidget {
  final String doctorName;
  final String date;
  final String time;
  final String status;
  final String designation;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final bool showButtons;

  const AppointmentWidget({
    super.key,
    required this.doctorName,
    required this.date,
    required this.time,
    required this.status,
    required this.designation,
    this.imageUrl,
    this.onTap,
    this.onCancel,
    this.onReschedule,
    this.showButtons = false,
  });

  Color _getStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains('cancel')) {
      return const Color(0xFFDC2626);
    } else if (lower.contains('finished') || lower.contains('completed')) {
      return const Color(0xFF059669);
    } else {
      return const Color(0xFF6366F1);
    }
  }

  String _formatDate(String rawDate) {
    if (rawDate.trim().isEmpty) return '';
    final cleaned = rawDate.trim();
    try {
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(cleaned)) {
        return cleaned;
      }
      final dt = DateTime.tryParse(cleaned);
      if (dt != null) {
        final d = dt.day.toString().padLeft(2, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final y = dt.year.toString().padLeft(4, '0');
        return '$d-$m-$y';
      }
      final parts = cleaned.split(RegExp(r'[-/]'));
      if (parts.length >= 3) {
        if (parts[0].length == 4) {
          final y = parts[0];
          final m = parts[1].padLeft(2, '0');
          final d = parts[2].split(' ').first.padLeft(2, '0');
          return '$d-$m-$y';
        } else if (parts[2].length >= 4) {
          final d = parts[0].padLeft(2, '0');
          final m = parts[1].padLeft(2, '0');
          final y = parts[2].split(' ').first.substring(0, 4);
          return '$d-$m-$y';
        }
      }
    } catch (_) {}
    return cleaned;
  }


  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);

    final imgUrl = imageUrl ?? 'https://i.pravatar.cc/150?u=$doctorName';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Doctor Avatar
                ClipOval(
                  child: Image.network(
                    imgUrl,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 68,
                      height: 68,
                      color: fillColor,
                      child: const Icon(Icons.person, color: primaryColor, size: 36),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Doctor Info & Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        designation,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatDate(date)} - $time',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: status.toLowerCase().contains('finished')
                              ? TextDecoration.underline
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron Right Icon
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF0F172A),
                  size: 22,
                ),
              ],
            ),

            if (showButtons) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: borderGrey),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onReschedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Reschedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
