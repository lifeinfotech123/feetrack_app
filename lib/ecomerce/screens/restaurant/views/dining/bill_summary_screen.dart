import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/ecomerce/constants.dart';
import 'package:vlr/ecomerce/controllers/dining_controller.dart';
import 'package:vlr/ecomerce/controllers/profile_controller.dart';
import 'package:vlr/ecomerce/models/restaurant_model.dart';
import 'package:vlr/ecomerce/services/dining_service.dart';
import 'my_table_bookings_screen.dart';

class BillSummaryScreen extends StatefulWidget {
  const BillSummaryScreen({
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

  @override
  State<BillSummaryScreen> createState() => _BillSummaryScreenState();
}

class _BillSummaryScreenState extends State<BillSummaryScreen> {
  final DiningService _service = DiningService();
  final TextEditingController _requestController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  late final DiningController _diningController;
  final Map<int, int> _cart = {};
  late Razorpay _razorpay;
  List<Map<String, dynamic>> _pendingPreorderItems = [];

  @override
  void initState() {
    super.initState();
    _diningController = Get.isRegistered<DiningController>() ? Get.find<DiningController>() : Get.put(DiningController());
    _loadGuestInfo();
    _loadMenu();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _loadGuestInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String name = prefs.getString('user_name') ?? prefs.getString('name') ?? '';
    String phone = prefs.getString('user_phone') ?? prefs.getString('phone') ?? '';
    String email = prefs.getString('user_email') ?? prefs.getString('email') ?? '';

    if (name.isEmpty && Get.isRegistered<ProfileController>()) {
      final profile = Get.find<ProfileController>().profile.value;
      if (profile != null) {
        name = profile.name;
        phone = profile.phone;
        email = profile.email;
      }
    }

    if (mounted) {
      setState(() {
        _nameController.text = name;
        _phoneController.text = phone;
        _emailController.text = email;
      });
    }
  }

  Future<void> _loadMenu() async {
    await _diningController.fetchDiningMenu(domain: widget.domain, shopId: widget.shopId);
  }

  @override
  void dispose() {
    _requestController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _confirmBookingAfterPayment();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed or cancelled: ${response.message ?? ''}')),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  double get _preorderTotal {
    double total = 0;
    final menu = (_diningController.menuData['data']?['menu'] as List?) ?? [];
    for (final item in menu) {
      final id = item['id'];
      final qty = _cart[id] ?? 0;
      if (qty > 0) {
        final price = (item['final_price'] ?? item['unit_price'] ?? 0).toDouble();
        total += price * qty;
      }
    }
    return total;
  }

  Future<void> _directConfirmBooking() async {
    setState(() => _isLoading = true);
    try {
      final menu = (_diningController.menuData['data']?['menu'] as List?) ?? [];
      _pendingPreorderItems.clear();
      for (final item in menu) {
        final id = item['id'];
        final qty = _cart[id] ?? 0;
        if (qty > 0) {
          _pendingPreorderItems.add({
            'product_id': id,
            'item_id': id,
            'menu_item_id': id,
            'quantity': qty,
            'qty': qty,
            'name': item['name'],
            'price': item['final_price'] ?? item['unit_price'],
          });
        }
      }

      final res = await _service.bookTable(
        domain: widget.domain,
        shopId: widget.shopId,
        bookingDate: widget.date,
        bookingTimeSlot: widget.timeSlot,
        mealType: widget.mealType,
        guestsCount: widget.guestsCount,
        tableId: widget.tableId,
        specialRequest: _requestController.text.trim().isNotEmpty ? _requestController.text.trim() : null,
        preorderItems: _pendingPreorderItems,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

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
                const Center(
                  child: Text('Table Booked Successfully!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(res['data']?['booking_number'] != null ? 'Booking ID: ${res['data']['booking_number']}' : 'Your table reservation is confirmed', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                ),
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
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _startPayment() {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name and phone number')));
      return;
    }

    if (_preorderTotal <= 0) {
      _directConfirmBooking();
      return;
    }

    setState(() => _isLoading = true);

    final menu = (_diningController.menuData['data']?['menu'] as List?) ?? [];
    _pendingPreorderItems.clear();
    for (final item in menu) {
      final id = item['id'];
      final qty = _cart[id] ?? 0;
      if (qty > 0) {
        _pendingPreorderItems.add({
          'product_id': id,
          'item_id': id,
          'menu_item_id': id,
          'quantity': qty,
          'qty': qty,
          'name': item['name'],
          'price': item['final_price'] ?? item['unit_price'],
        });
      }
    }

    final amount = _preorderTotal > 0 ? _preorderTotal : 100.0;
    final amountInPaise = (amount * 100).toInt();

    final options = {
      'key': 'rzp_test_TWIAoYszpcVthe',
      'amount': amountInPaise > 0 ? amountInPaise : 100,
      'name': widget.restaurant.name,
      'description': 'Table Booking Payment',
      'prefill': {
        'name': _nameController.text.trim(),
        'contact': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      },
      'theme': {'color': '#7F00FF'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _confirmBookingAfterPayment() async {
    try {
      final res = await _service.bookTable(
        domain: widget.domain,
        shopId: widget.shopId,
        bookingDate: widget.date,
        bookingTimeSlot: widget.timeSlot,
        mealType: widget.mealType,
        guestsCount: widget.guestsCount,
        tableId: widget.tableId,
        specialRequest: _requestController.text.trim().isNotEmpty ? _requestController.text.trim() : null,
        preorderItems: _pendingPreorderItems,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

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
                const Center(
                  child: Text('Table Booked Successfully!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(res['data']?['booking_number'] != null ? 'Booking ID: ${res['data']['booking_number']}' : 'Your table reservation is confirmed', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                ),
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
          SnackBar(content: Text(res?['message']?.toString() ?? 'Booking failed after payment.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
        title: const Text('Bill Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
            _buildInfoCards(cardBg, isDark),
            const SizedBox(height: 16),
            _buildGuestDetails(cardBg, isDark),
            const SizedBox(height: 16),
            _buildPreorderMenu(cardBg, isDark),
            const SizedBox(height: 16),
            _buildSpecialRequest(cardBg, isDark),
            const SizedBox(height: 120),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Pre-order Total', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('₹${_preorderTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_preorderTotal > 0 ? 'Pay & Confirm Booking' : 'Confirm Booking', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards(Color cardBg, bool isDark) {
    final tableName = widget.tableData?['display_name'] ?? widget.tableData?['table_number'] ?? 'Table';
    return Row(
      children: [
        _infoCard(Icons.calendar_today_rounded, 'Date', DateFormat('dd MMM yyyy').format(DateTime.parse(widget.date)), cardBg, isDark),
        const SizedBox(width: 8),
        _infoCard(Icons.access_time_rounded, 'Time', widget.timeSlot, cardBg, isDark),
        const SizedBox(width: 8),
        _infoCard(Icons.table_restaurant_rounded, 'Table', tableName, cardBg, isDark),
      ],
    );
  }

  Widget _infoCard(IconData icon, String label, String value, Color cardBg, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFEAEAEA)),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 18),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54)),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestDetails(Color cardBg, bool isDark) {
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
          const Text('Guest Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              filled: true,
              fillColor: isDark ? const Color(0xFF262634) : const Color(0xFFF7F7FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              prefixIcon: const Icon(Icons.phone_outlined),
              filled: true,
              fillColor: isDark ? const Color(0xFF262634) : const Color(0xFFF7F7FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email (Optional)',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: isDark ? const Color(0xFF262634) : const Color(0xFFF7F7FA),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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

  Widget _buildPreorderMenu(Color cardBg, bool isDark) {
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
          const Text('Pre-order Food (Optional)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Obx(() {
            if (_diningController.isLoadingMenu.value && _diningController.menuData.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: primaryColor)));
            }
            final menu = (_diningController.menuData['data']?['menu'] as List?) ?? [];
            if (menu.isEmpty) {
              return Text('No pre-order menu available', style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54));
            }
            return Column(
              children: menu.map((item) {
                final id = item['id'];
                final qty = _cart[id] ?? 0;
                final price = (item['final_price'] ?? item['unit_price'] ?? 0).toDouble();
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262634) : const Color(0xFFF7F7FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: item['thumbnail'] != null
                              ? CachedNetworkImage(imageUrl: item['thumbnail'], fit: BoxFit.cover)
                              : const Icon(Icons.fastfood_rounded, color: primaryColor),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if ((qty - 1) <= 0) {
                                  _cart.remove(id);
                                } else {
                                  _cart[id] = qty - 1;
                                }
                              });
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _cart[id] = qty + 1;
                              });
                            },
                            icon: const Icon(Icons.add_circle_outline, color: primaryColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
