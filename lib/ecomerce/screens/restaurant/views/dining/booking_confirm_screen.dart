import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/controllers/dining_controller.dart';
import 'package:vlr/ecomerce/models/restaurant_model.dart';
import 'package:vlr/ecomerce/services/dining_service.dart';
import 'my_table_bookings_screen.dart';

class BookingConfirmScreen extends StatefulWidget {
  const BookingConfirmScreen({
    super.key,
    required this.restaurant,
    required this.domain,
    required this.shopId,
    required this.date,
    required this.timeSlot,
    required this.mealType,
    required this.guestsCount,
    this.tableId,
    this.tableData,
    this.autoAssign = false,
  });

  final RestaurantModel restaurant;
  final String domain;
  final int shopId;
  final String date;
  final String timeSlot;
  final String mealType;
  final int guestsCount;
  final int? tableId;
  final Map<String, dynamic>? tableData;
  final bool autoAssign;

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  final DiningService _service = DiningService();
  final TextEditingController _requestController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);
    try {
      final res = await _service.bookTable(
        domain: widget.domain,
        shopId: widget.shopId,
        bookingDate: widget.date,
        bookingTimeSlot: widget.timeSlot,
        mealType: widget.mealType,
        guestsCount: widget.guestsCount,
        tableId: widget.autoAssign ? null : widget.tableId,
        specialRequest: _requestController.text.trim().isNotEmpty ? _requestController.text.trim() : null,
      );

      if (!mounted) return;

      if (res != null && res['status'] == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF00C853).withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 48),
                ),
                const SizedBox(height: 16),
                const Text('Table Booked Successfully!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(res['data']?['booking_number'] != null ? 'Booking ID: ${res['data']['booking_number']}' : 'Your table reservation is confirmed', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => MyTableBookingsScreen(domain: widget.domain)),
                        (route) => route.isFirst,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('View My Bookings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res?['message']?.toString() ?? 'Booking failed. Please try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRestaurantCard(cardBg, isDark),
            const SizedBox(height: 16),
            _buildBookingDetails(cardBg, isDark),
            const SizedBox(height: 16),
            _buildTableInfo(cardBg, isDark),
            const SizedBox(height: 16),
            _buildSpecialRequest(cardBg, isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirm & Book Table', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0))),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: widget.restaurant.logo != null && widget.restaurant.logo!.isNotEmpty
                  ? CachedNetworkImage(imageUrl: widget.restaurant.logo!, fit: BoxFit.cover)
                  : const Icon(Icons.restaurant_menu, color: primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(widget.restaurant.address ?? '', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetails(Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          _row(Icons.calendar_today_rounded, 'Date', DateFormat('EEE, dd MMM yyyy').format(DateTime.parse(widget.date))),
          _row(Icons.access_time_rounded, 'Time', widget.timeSlot),
          _row(Icons.restaurant_rounded, 'Meal Type', widget.mealType.toUpperCase()),
          _row(Icons.people_rounded, 'Guests', '${widget.guestsCount} People'),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTableInfo(Color cardBg, bool isDark) {
    String tableText = widget.autoAssign ? 'Auto Assign Best Table' : (widget.tableData?['display_name'] ?? 'Table Selected');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.table_restaurant_rounded, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selected Table', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(tableText, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialRequest(Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Special Request (Optional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _requestController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g. Window seat, anniversary celebration',
              hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
              filled: true,
              fillColor: isDark ? const Color(0xFF262634) : const Color(0xFFF7F7FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}
