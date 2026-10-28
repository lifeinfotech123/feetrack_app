import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/controllers/dining_controller.dart';
import 'package:vlr/ecomerce/services/dining_service.dart';

class MyTableBookingsScreen extends StatefulWidget {
  const MyTableBookingsScreen({super.key, required this.domain});

  final String domain;

  @override
  State<MyTableBookingsScreen> createState() => _MyTableBookingsScreenState();
}

class _MyTableBookingsScreenState extends State<MyTableBookingsScreen> {
  late final DiningController _controller;
  final DiningService _service = DiningService();

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<DiningController>() ? Get.find<DiningController>() : Get.put(DiningController());
    _load();
  }

  Future<void> _load() async {
    await _controller.fetchMyBookings(domain: widget.domain);
  }

  Future<void> _cancelBooking(int bookingId) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for cancellation'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'e.g. Change of schedule',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.trim().isNotEmpty) {
      final res = await _service.cancelBooking(domain: widget.domain, bookingId: bookingId, reason: reasonController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res?['message']?.toString() ?? 'Updated')));
        _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final bg = isDark ? const Color(0xFF12121A) : const Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E28) : Colors.white,
        title: const Text('My Table Bookings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingBookings.value && _controller.myBookings.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        if (_controller.myBookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.table_restaurant_outlined, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('No table bookings yet', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Book a table from dining restaurants', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: primaryColor,
          onRefresh: _load,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: _controller.myBookings.length,
            itemBuilder: (context, index) {
              final booking = _controller.myBookings[index];
              return _buildBookingCard(booking, cardBg, isDark);
            },
          ),
        );
      }),
    );
  }

  Widget _buildBookingCard(Map booking, Color cardBg, bool isDark) {
    final status = (booking['booking_status'] ?? '').toString();
    final isConfirmed = status.toLowerCase() == 'confirmed';
    final isCancellable = booking['is_cancellable'] == true && isConfirmed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEAEAEA)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: booking['restaurant_logo'] != null
                        ? CachedNetworkImage(imageUrl: booking['restaurant_logo'], fit: BoxFit.cover)
                        : const Icon(Icons.restaurant_menu, color: primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking['vendor'] ?? booking['restaurant_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(booking['booking_number'] ?? '', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (isConfirmed ? const Color(0xFF00C853) : Colors.orange).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isConfirmed ? const Color(0xFF00C853) : Colors.orange)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white12 : const Color(0xFFF0F0F0)),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _row(Icons.calendar_today_rounded, 'Date', booking['booking_date_formatted'] ?? booking['booking_date'] ?? ''),
                _row(Icons.access_time_rounded, 'Time', booking['booking_time_formatted'] ?? booking['booking_time_slot'] ?? ''),
                _row(Icons.people_rounded, 'Guests', '${booking['guests_count']} Pax'),
                _row(Icons.table_restaurant_rounded, 'Table', booking['table_name'] ?? booking['assigned_table_name'] ?? 'Auto Assigned'),
                _row(Icons.location_on_rounded, 'Address', booking['restaurant_address'] ?? ''),
              ],
            ),
          ),
          if (isCancellable)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelBooking(booking['id']),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: primaryColor),
          const SizedBox(width: 10),
          SizedBox(width: 70, child: Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
