import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/controllers/dining_controller.dart';
import 'package:vlr/ecomerce/models/restaurant_model.dart';
import 'package:vlr/ecomerce/services/dining_service.dart';
import 'table_selection_screen.dart';

class TableBookingScreen extends StatefulWidget {
  const TableBookingScreen({
    super.key,
    required this.restaurant,
    required this.domain,
    required this.shopId,
  });

  final RestaurantModel restaurant;
  final String domain;
  final int shopId;

  @override
  State<TableBookingScreen> createState() => _TableBookingScreenState();
}

class _TableBookingScreenState extends State<TableBookingScreen> {
  late final DiningController _controller;
  final DiningService _service = DiningService();

  DateTime selectedDate = DateTime.now();
  String mealType = 'dinner';
  int guestsCount = 2;
  String? selectedSlot;

  final List<int> guestOptions = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<DiningController>() ? Get.find<DiningController>() : Get.put(DiningController());
    _loadSlots();
  }

  String get _dateStr => DateFormat('yyyy-MM-dd').format(selectedDate);

  Future<void> _loadSlots() async {
    await _controller.fetchDiningSlots(domain: widget.domain, date: _dateStr, guests: guestsCount);
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
        title: Text(widget.restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(cardBg, isDark),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Select Date'),
                  const SizedBox(height: 10),
                  _buildDateSelector(isDark, cardBg),
                  const SizedBox(height: 18),
                  _buildSectionTitle('Meal Type'),
                  const SizedBox(height: 10),
                  _buildMealTypeSelector(isDark, cardBg),
                  const SizedBox(height: 18),
                  _buildSectionTitle('Number of Guests'),
                  const SizedBox(height: 10),
                  _buildGuestsSelector(isDark, cardBg),
                  const SizedBox(height: 18),
                  _buildSectionTitle('Available Time Slots'),
                  const SizedBox(height: 10),
                  _buildSlotsGrid(isDark, cardBg),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: selectedSlot == null
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
                    onPressed: _proceedToTables,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text('Select Table', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(Color cardBg, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
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
                Text(widget.restaurant.address ?? '', style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text('${widget.restaurant.rating}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87));
  }

  Widget _buildDateSelector(bool isDark, Color cardBg) {
    final dates = List.generate(7, (index) => DateTime.now().add(Duration(days: index)));
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = DateFormat('yyyy-MM-dd').format(date) == _dateStr;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDate = date;
                selectedSlot = null;
              });
              _loadSlots();
            },
            child: Container(
              width: 58,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.white12 : const Color(0xFFEAEAEA))),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(date), style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : Colors.grey)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd').format(date), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
                  const SizedBox(height: 2),
                  Text(DateFormat('MMM').format(date), style: TextStyle(fontSize: 10, color: isSelected ? Colors.white70 : Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealTypeSelector(bool isDark, Color cardBg) {
    return Row(
      children: [
        _mealChip('Lunch', 'lunch', isDark, cardBg),
        const SizedBox(width: 10),
        _mealChip('Dinner', 'dinner', isDark, cardBg),
      ],
    );
  }

  Widget _mealChip(String label, String value, bool isDark, Color cardBg) {
    final isSelected = mealType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => mealType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.white12 : const Color(0xFFEAEAEA))),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87))),
        ),
      ),
    );
  }

  Widget _buildGuestsSelector(bool isDark, Color cardBg) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: guestOptions.length,
        itemBuilder: (context, index) {
          final count = guestOptions[index];
          final isSelected = guestsCount == count;
          return GestureDetector(
            onTap: () {
              setState(() {
                guestsCount = count;
                selectedSlot = null;
              });
              _loadSlots();
            },
            child: Container(
              width: 44,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.white12 : const Color(0xFFEAEAEA))),
              ),
              child: Center(
                child: Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87))),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotsGrid(bool isDark, Color cardBg) {
    return Obx(() {
      if (_controller.isLoadingSlots.value) {
        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: primaryColor)));
      }

      final allSlots = _controller.slotsData['data']?['slots'] as List? ?? [];
      final now = DateTime.now();
      final isToday = DateFormat('yyyy-MM-dd').format(selectedDate) == DateFormat('yyyy-MM-dd').format(now);

      final slots = allSlots.where((slot) {
        final time24 = slot['time_24']?.toString() ?? '';
        if (time24.isEmpty) return false;
        final available = slot['is_available'] == true && slot['is_past'] != true;
        if (!available) return false;
        if (isToday) {
          try {
            final parts = time24.split(':');
            final slotTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), parts.length > 1 ? int.parse(parts[1]) : 0);
            if (slotTime.isBefore(now.add(const Duration(minutes: 0)))) {
              return false;
            }
          } catch (_) {}
        }
        return true;
      }).toList();

      if (slots.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEAEAEA))),
          child: const Text('No slots available for selected date/time', textAlign: TextAlign.center),
        );
      }

      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: slots.map((slot) {
          final time = slot['time_formatted'] ?? slot['time_24'] ?? '';
          final available = slot['is_available'] == true && slot['is_past'] != true;
          final isSelected = selectedSlot == slot['time_24'];
          return GestureDetector(
            onTap: available
                ? () => setState(() => selectedSlot = slot['time_24'])
                : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? primaryColor : (isDark ? Colors.white12 : const Color(0xFFEAEAEA))),
              ),
              child: Text(
                time,
                style: TextStyle(fontWeight: FontWeight.w600, color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87)),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  void _proceedToTables() {
    if (selectedSlot == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TableSelectionScreen(
          restaurant: widget.restaurant,
          domain: widget.domain,
          shopId: widget.shopId,
          date: _dateStr,
          timeSlot: selectedSlot!,
          mealType: mealType,
          guestsCount: guestsCount,
        ),
      ),
    );
  }
}
