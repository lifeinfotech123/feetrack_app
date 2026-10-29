import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/controllers/dining_controller.dart';
import 'package:vlr/ecomerce/models/restaurant_model.dart';
import 'bill_summary_screen.dart';

class TableSelectionScreen extends StatefulWidget {
  const TableSelectionScreen({
    super.key,
    required this.restaurant,
    required this.domain,
    required this.shopId,
    required this.date,
    required this.timeSlot,
    required this.mealType,
    required this.guestsCount,
  });

  final RestaurantModel restaurant;
  final String domain;
  final int shopId;
  final String date;
  final String timeSlot;
  final String mealType;
  final int guestsCount;

  @override
  State<TableSelectionScreen> createState() => _TableSelectionScreenState();
}

class _TableSelectionScreenState extends State<TableSelectionScreen> {
  late final DiningController _controller;
  dynamic selectedTableId;
  Map<String, dynamic>? selectedTableData;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<DiningController>() ? Get.find<DiningController>() : Get.put(DiningController());
    _loadTables();
  }

  Future<void> _loadTables() async {
    await _controller.fetchAvailableTables(
      domain: widget.domain,
      shopId: widget.shopId,
      date: widget.date,
      timeSlot: widget.timeSlot,
      guests: widget.guestsCount,
    );
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
        title: const Text('Select Table', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingTables.value) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        final data = _controller.tablesData['data'] ?? {};
        final allTables = data['tables'] as List? ?? [];
        final tables = allTables.where((t) => t['is_booked'] != true).toList();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookingInfo(data, cardBg, isDark),
              const SizedBox(height: 18),
              const Text('Choose Your Table', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (tables.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEAEAEA)),
                  ),
                  child: const Text('No tables available for this slot', textAlign: TextAlign.center),
                )
              else
                ...tables.map((table) => _buildTableCard(table, cardBg, isDark)),
              const SizedBox(height: 90),
            ],
          ),
        );
      }),
      bottomNavigationBar: selectedTableId == null
          ? const SizedBox.shrink()
          : Container(
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
                    onPressed: _proceedToBill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Proceed to Bill', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBookingInfo(Map data, Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEAEAEA)),
      ),
      child: Row(
        children: [
          _infoItem(Icons.calendar_today_rounded, 'Date', DateFormat('EEE, dd MMM yyyy').format(DateTime.parse(widget.date))),
          _infoItem(Icons.access_time_rounded, 'Time', widget.timeSlot),
          _infoItem(Icons.people_rounded, 'Guests', '${widget.guestsCount} Pax'),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 18),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTableCard(Map table, Color cardBg, bool isDark) {
    final isBooked = table['is_booked'] == true;
    if (isBooked) return const SizedBox.shrink();
    final tableId = table['id'];
    final isSelected = selectedTableId == tableId;
    return GestureDetector(
      onTap: () => setState(() {
        selectedTableId = tableId;
        selectedTableData = Map<String, dynamic>.from(table);
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.08) : cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.white12 : const Color(0xFFEAEAEA)), width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (table['is_exact_match'] == true ? const Color(0xFF00C853) : primaryColor).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.table_restaurant_rounded, color: table['is_exact_match'] == true ? const Color(0xFF00C853) : primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(table['display_name'] ?? table['table_number'] ?? 'Table', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('${table['area_zone'] ?? ''} • Capacity: ${table['capacity']} Pax', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
                  if (table['status_label'] != null) ...[
                    const SizedBox(height: 4),
                    Text(table['status_label'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: table['is_exact_match'] == true ? const Color(0xFF00C853) : Colors.orange)),
                  ],
                ],
              ),
            ),
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? primaryColor : Colors.grey),
          ],
        ),
      ),
    );
  }

  void _proceedToBill() {
    if (selectedTableId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BillSummaryScreen(
          restaurant: widget.restaurant,
          domain: widget.domain,
          shopId: widget.shopId,
          date: widget.date,
          timeSlot: widget.timeSlot,
          mealType: widget.mealType,
          guestsCount: widget.guestsCount,
          tableId: selectedTableId,
          tableData: selectedTableData,
        ),
      ),
    );
  }
}
