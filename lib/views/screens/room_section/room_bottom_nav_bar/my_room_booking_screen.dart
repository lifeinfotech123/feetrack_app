import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/room_home/room_home_screen.dart';

class MyRoomBookingScreen extends StatefulWidget {
  final VoidCallback? onExploreTap;
  const MyRoomBookingScreen({super.key, this.onExploreTap});

  @override
  State<MyRoomBookingScreen> createState() => _MyRoomBookingScreenState();
}

class _MyRoomBookingScreenState extends State<MyRoomBookingScreen> {
  late final Razorpay _razorpay;
  PgCustomerBookingItem? _pendingPaymentBooking;
  String _selectedTab = 'all';

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorpayExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<RoomController>()) {
        Get.find<RoomController>()
            .fetchPgCustomerBookings(status: _selectedTab);
      }
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openRazorpayForBooking(PgCustomerBookingItem booking) {
    _pendingPaymentBooking = booking;

    final double amount = (booking.finalAmount is num)
        ? (booking.finalAmount as num).toDouble()
        : (double.tryParse(booking.finalAmount.toString()) ?? 1000);
    final int amountInPaise = (amount * 100).toInt();

    final propertyTitle = booking.property?.title ?? "PG Room Booking";

    final options = {
      'key': 'rzp_test_TWIAoYszpcVthe',
      'amount': amountInPaise > 0 ? amountInPaise : 100000,
      'name': propertyTitle,
      'description':
          'Booking ${booking.shortId ?? booking.bookingNumber ?? ""}',
      'prefill': {
        'contact': booking.property?.phone ?? '9876543210',
      },
      'theme': {
        'color': '#002060',
      },
    };

    try {
      debugPrint('Opening Razorpay options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay native open failed (desktop/emulator): $e');
      _showRazorpaySimulatedDialog(booking, amount);
    }
  }

  void _handleRazorpayPaymentSuccess(PaymentSuccessResponse response) {
    if (_pendingPaymentBooking?.id != null) {
      showToast(
        message:
            "🎉 Payment via Razorpay successful (ID: ${response.paymentId})! Confirming booking...",
        toastType: ToastType.success,
      );
      if (Get.isRegistered<RoomController>()) {
        Get.find<RoomController>()
            .payPgCustomerBooking(_pendingPaymentBooking!.id!);
      }
    }
  }

  void _handleRazorpayPaymentError(PaymentFailureResponse response) {
    showToast(
      message: "❌ Payment Cancelled or Failed. Booking was not paid.",
      toastType: ToastType.error,
    );
  }

  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    showToast(
      message: "External wallet selected: ${response.walletName}",
      toastType: ToastType.success,
    );
  }

  void _showRazorpaySimulatedDialog(
      PgCustomerBookingItem booking, double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF002060).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.payment_rounded,
                  color: Color(0xFF002060), size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Razorpay Gateway',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.property?.title ?? "PG Room",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Booking: ${booking.shortId ?? booking.bookingNumber ?? ""}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Payable:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '₹${amount.toInt()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Simulate Razorpay payment on this platform / test environment:',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleRazorpayPaymentError(
                PaymentFailureResponse(Razorpay.PAYMENT_CANCELLED,
                    'Payment cancelled by user', null),
              );
            },
            child: const Text('Cancel Payment',
                style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002060),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final simPayId = 'pay_${DateTime.now().millisecondsSinceEpoch}';
              final simOrderId =
                  'order_${DateTime.now().millisecondsSinceEpoch}';
              _handleRazorpayPaymentSuccess(
                PaymentSuccessResponse(
                    simPayId, simOrderId, 'sig_simulated', null),
              );
            },
            child: const Text('Pay Success',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onTabChanged(String tabKey) {
    if (_selectedTab == tabKey) return;
    setState(() {
      _selectedTab = tabKey;
    });
    if (Get.isRegistered<RoomController>()) {
      Get.find<RoomController>().fetchPgCustomerBookings(status: tabKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "My Room Bookings",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
        ),
      ),
      body: GetBuilder<RoomController>(
        builder: (controller) {
          final tabs = controller.customerBookingsTabs;

          final tabItems = [
            {'label': 'All', 'value': 'all', 'count': tabs['all']},
            {
              'label': 'Confirmed',
              'value': 'confirmed',
              'count': tabs['confirmed']
            },
            {
              'label': 'Pending OTP',
              'value': 'pending_otp',
              'count': tabs['pending_otp']
            },
            {
              'label': 'Pending Payment',
              'value': 'pending_payment',
              'count': tabs['pending_payment']
            },
            {
              'label': 'Completed',
              'value': 'completed',
              'count': tabs['completed']
            },
            {
              'label': 'Cancelled',
              'value': 'cancelled',
              'count': tabs['cancelled']
            },
          ];

          return Column(
            children: [
              // Tab Chips
              Container(
                height: 52,
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: tabItems.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = tabItems[index];
                    final isSelected = _selectedTab == item['value'];
                    final count = item['count'];

                    String labelText = item['label'] as String;
                    if (count is int && count > 0) {
                      labelText += " ($count)";
                    }

                    return Center(
                      child: ChoiceChip(
                        label: Text(labelText),
                        selected: isSelected,
                        selectedColor: const Color(0xFF002060),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF002060)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        onSelected: (val) {
                          if (val) {
                            _onTabChanged(item['value'] as String);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              // Content List or Loading
              Expanded(
                child: controller.isCustomerBookingsLoading &&
                        controller.customerBookingsList.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF002060),
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF002060),
                        onRefresh: () async {
                          await controller.fetchPgCustomerBookings(
                              status: _selectedTab);
                        },
                        child: controller.customerBookingsList.isEmpty
                            ? _buildEmptyState()
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 100),
                                itemCount:
                                    controller.customerBookingsList.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final booking =
                                      controller.customerBookingsList[index];
                                  return _CustomerBookingCard(
                                    booking: booking,
                                    controller: controller,
                                    onPayTap: _openRazorpayForBooking,
                                  );
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF002060).withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bed_rounded,
                size: 56,
                color: Color(0xFF002060),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "No Room Bookings Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You don't have any room bookings under this category. Explore verified PG rooms and secure your spot today!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002060),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: widget.onExploreTap ??
                  () {
                    navigate(
                      context: context,
                      page: const RoomHomeScreen(),
                    );
                  },
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text(
                "Explore Rooms & PGs",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerBookingCard extends StatelessWidget {
  final PgCustomerBookingItem booking;
  final RoomController controller;
  final Function(PgCustomerBookingItem) onPayTap;

  const _CustomerBookingCard({
    required this.booking,
    required this.controller,
    required this.onPayTap,
  });

  Color _getStatusColor(String? status) {
    final s = (status ?? "").toLowerCase();
    if (s == 'confirmed' || s == 'completed' || s == 'paid') {
      return const Color(0xFF16A34A);
    }
    if (s.contains('pending')) {
      return const Color(0xFFD97706);
    }
    if (s == 'cancelled' || s == 'rejected') {
      return const Color(0xFFDC2626);
    }
    return const Color(0xFF2563EB);
  }

  @override
  Widget build(BuildContext context) {
    final property = booking.property;
    final package = booking.package;
    final title = property?.title ?? "PG Room";
    final address = property?.address ?? property?.city ?? "";
    final image = property?.image ?? "";

    final statusLabel =
        booking.statusLabel ?? (booking.status ?? "").toUpperCase();
    final statusColor = _getStatusColor(booking.status);

    final amountStr = booking.formattedAmount ?? "₹${booking.finalAmount ?? 0}";
    final bedsStr = booking.bedsDisplay ?? "${booking.bedsBooked ?? 1} Bed";
    final occupancyStr = booking.occupancyTypeDisplay ??
        package?['name']?.toString() ??
        "PG Stay";

    final actions = booking.actions ?? {};
    final canPay = actions['can_pay'] == true;
    final canView = actions['can_view'] != false;
    final canInvoice = actions['can_invoice'] == true;
    final canCancel = actions['can_cancel'] == true;
    final canVerifyOtp = actions['can_verify_otp'] == true ||
        (booking.status ?? "").toLowerCase() == 'pending_otp';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: image.isNotEmpty
                      ? Image.network(
                          image,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 64,
                            height: 64,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.home_work_rounded,
                                color: Color(0xFF94A3B8)),
                          ),
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.home_work_rounded,
                              color: Color(0xFF94A3B8)),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (address.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 13, color: Color(0xFF64748B)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              booking.shortId ?? booking.bookingNumber ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          if (booking.paymentStatusBadge != null &&
                              booking.paymentStatusBadge!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                booking.paymentStatusBadge!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  constraints: const BoxConstraints(maxWidth: 95),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Details Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child:
                      _buildMiniInfo("Plan / Room", "$bedsStr • $occupancyStr"),
                ),
                const SizedBox(width: 8),
                if (booking.formattedDate != null) ...[
                  Expanded(
                    flex: 4,
                    child: _buildMiniInfo("Date", booking.formattedDate!),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  flex: 3,
                  child: _buildMiniInfo("Rent", amountStr, isEnd: true),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Action row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (property?.phone != null && property!.phone!.isNotEmpty)
                      InkWell(
                        onTap: () {
                          LaunchHelper.callUs(number: property.phone!);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF002060).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.call_rounded,
                                  size: 13, color: Color(0xFF002060)),
                              const SizedBox(width: 4),
                              Text(
                                "Call: ${property.phone}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF002060),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(),
                    Flexible(
                      child: Text(
                        booking.bookingNumber ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (canInvoice && booking.invoice != null) ...[
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF002060),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            _showInvoiceDialog(context, booking);
                          },
                          child: const Text(
                            "Invoice",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (canVerifyOtp) ...[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            _showVerifyOtpDialog(context, booking);
                          },
                          child: const Text(
                            "Verify OTP",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (canPay) ...[
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            onPayTap(booking);
                          },
                          child: const Text(
                            "Pay Now",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (canView)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002060),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            _showDetailsDialog(context, booking);
                          },
                          child: const Text(
                            "View Details",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    if (canCancel) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        tooltip: "Cancel Booking",
                        icon: const Icon(Icons.cancel_outlined,
                            color: Color(0xFFDC2626), size: 22),
                        onPressed: () =>
                            _showCancelBookingDialog(context, booking),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value, {bool isEnd = false}) {
    return Column(
      crossAxisAlignment:
          isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  void _showVerifyOtpDialog(
      BuildContext context, PgCustomerBookingItem booking) {
    final otpController = TextEditingController(text: booking.otp ?? "");

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read_rounded,
                  color: Color(0xFFD97706), size: 22),
              SizedBox(width: 8),
              Text(
                "Verify Check-in OTP",
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter the 6-digit OTP to confirm your check-in for ${booking.property?.title ?? 'this property'}.",
                style:
                    const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              if (booking.otp != null && booking.otp!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Your assigned OTP is ${booking.otp}",
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF002060),
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "••••••",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF002060), width: 1.8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text(
                "Cancel",
                style: TextStyle(
                    color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ),
            GetBuilder<RoomController>(
              builder: (ctrl) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002060),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: ctrl.isVerifyingOtp
                      ? null
                      : () async {
                          final otp = otpController.text.trim();
                          if (otp.isEmpty) {
                            showToast(
                              message: "Please enter the OTP",
                              toastType: ToastType.error,
                            );
                            return;
                          }
                          final res = await ctrl.verifyPgBookingOtp(
                            bookingId: booking.id ?? "",
                            otp: otp,
                          );
                          if (res.isSuccess) {
                            if (dialogCtx.mounted) {
                              Navigator.pop(dialogCtx);
                            }
                          }
                        },
                  child: ctrl.isVerifyingOtp
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Verify OTP",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showCancelBookingDialog(
      BuildContext context, PgCustomerBookingItem booking) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 8),
            Text(
              "Cancel Booking?",
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to cancel booking ${booking.shortId ?? booking.bookingNumber ?? ''}? This action cannot be undone.",
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text(
              "Keep Booking",
              style: TextStyle(
                  color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          GetBuilder<RoomController>(
            builder: (ctrl) {
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: ctrl.isCancellingBooking
                    ? null
                    : () async {
                        final res =
                            await ctrl.cancelPgBooking(booking.id ?? "");
                        if (res.isSuccess) {
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                        }
                      },
                child: ctrl.isCancellingBooking
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Yes, Cancel",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInvoiceDialog(BuildContext context, PgCustomerBookingItem booking) {
    final invoice = booking.invoice;
    if (invoice == null) return;
    final invoiceId = invoice['id']?.toString() ?? booking.id ?? "";
    final invoiceNumber = invoice['invoice_number']?.toString() ?? "N/A";

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: Color(0xFF002060)),
            SizedBox(width: 8),
            Text(
              "Invoice Details",
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow("Invoice No", invoiceNumber),
            const SizedBox(height: 8),
            _buildDialogRow("Total Amount",
                "₹${invoice['total'] ?? invoice['amount'] ?? 0}"),
            const SizedBox(height: 8),
            _buildDialogRow("Status",
                (invoice['status']?.toString() ?? "PAID").toUpperCase()),
            if (invoice['due_date'] != null) ...[
              const SizedBox(height: 8),
              _buildDialogRow("Due Date", invoice['due_date'].toString()),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Close",
                style: TextStyle(
                    color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          GetBuilder<RoomController>(
            builder: (rCtrl) {
              final isDownloading = rCtrl.isInvoiceDownloading &&
                  rCtrl.downloadingInvoiceId == invoiceId;
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002060),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                ),
                onPressed: isDownloading
                    ? null
                    : () async {
                        await rCtrl.downloadOrOpenInvoicePdf(
                          invoiceId: invoiceId,
                          invoiceNumber: invoiceNumber,
                        );
                      },
                icon: isDownloading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded, size: 16),
                label: Text(
                  isDownloading ? "Opening..." : "Download PDF",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(BuildContext context, PgCustomerBookingItem booking) {
    final property = booking.property;
    final isConfirmed = (booking.status ?? "").toLowerCase() == 'confirmed';
    final isCancelled = (booking.status ?? "").toLowerCase() == 'cancelled';
    final statusBgColor = isConfirmed
        ? const Color(0xFFDCFCE7)
        : isCancelled
            ? const Color(0xFFFEE2E2)
            : const Color(0xFFFEF3C7);
    final statusTextColor = isConfirmed
        ? const Color(0xFF16A34A)
        : isCancelled
            ? const Color(0xFFDC2626)
            : const Color(0xFFD97706);

    final isPaid = (booking.paymentStatus ?? "").toLowerCase() == 'paid';
    final invoice = booking.invoice;
    final invoiceId = invoice?['id']?.toString() ?? booking.id ?? "";
    final invoiceNumber = invoice?['invoice_number']?.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        height: MediaQuery.of(sheetCtx).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF002060).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.hotel_rounded,
                      size: 20,
                      color: Color(0xFF002060),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Booking Details",
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          booking.bookingNumber ??
                              booking.shortId ??
                              "Reservation",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF64748B)),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF1F5F9)),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                children: [
                  // 1. Property Card with Image & Call
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: (property?.image != null &&
                                  property!.image!.isNotEmpty)
                              ? Image.network(
                                  property.image!,
                                  width: 65,
                                  height: 65,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildPropertyImagePlaceholder(),
                                )
                              : _buildPropertyImagePlaceholder(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property?.title ?? "PG Accommodation",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      property?.address ??
                                          property?.city ??
                                          "India",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (property?.phone != null &&
                                  property!.phone!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => LaunchHelper.callUs(
                                      number: property.phone!),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone_outlined,
                                          size: 13, color: Color(0xFF002060)),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          "Call PG: ${property.phone}",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF002060),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. Reference & Status Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Booking Reference",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    booking.bookingNumber ??
                                        booking.shortId ??
                                        "N/A",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF002060),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusBgColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    booking.statusLabel ??
                                        (isConfirmed ? "Confirmed" : "Pending"),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: statusTextColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () {
                                    final text = booking.bookingNumber ??
                                        booking.shortId ??
                                        "";
                                    if (text.isNotEmpty) {
                                      Clipboard.setData(
                                          ClipboardData(text: text));
                                      showToast(
                                          message: "Booking reference copied!");
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: const Color(0xFFCBD5E1)),
                                    ),
                                    child: const Icon(Icons.copy_rounded,
                                        size: 14, color: Color(0xFF475569)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (booking.formattedDate != null ||
                            booking.createdAt != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            "Booked on: ${booking.formattedDate ?? booking.createdAt ?? ''}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3. Stay & Accommodation Info Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.king_bed_outlined,
                                size: 18, color: Color(0xFF002060)),
                            SizedBox(width: 8),
                            Text(
                              "Accommodation Details",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18, color: Color(0xFFF1F5F9)),
                        _buildDialogRow(
                          "Occupancy Type",
                          booking.occupancyTypeDisplay ??
                              (booking.occupancyType == 'per_bed'
                                  ? "Per Bed"
                                  : (booking.occupancyType ?? "Standard")),
                        ),
                        const Divider(height: 14, color: Color(0xFFF8FAFC)),
                        _buildDialogRow(
                          "Beds Booked",
                          booking.bedsDisplay ??
                              "${booking.bedsBooked ?? 1} Bed",
                        ),
                        if (booking.room != null) ...[
                          const Divider(height: 14, color: Color(0xFFF8FAFC)),
                          _buildDialogRow(
                            "Room Number",
                            booking.room?['room_number']?.toString() ??
                                booking.room?['name']?.toString() ??
                                "Assigned on check-in",
                          ),
                          if (booking.room?['floor_name'] != null) ...[
                            const Divider(height: 14, color: Color(0xFFF8FAFC)),
                            _buildDialogRow(
                              "Floor",
                              booking.room!['floor_name'].toString(),
                            ),
                          ],
                        ],
                        if (booking.package != null) ...[
                          const Divider(height: 14, color: Color(0xFFF8FAFC)),
                          _buildDialogRow(
                            "Plan / Package",
                            booking.package?['name']
                                    ?.toString()
                                    .toUpperCase() ??
                                "Standard Stay",
                          ),
                        ],
                        if (booking.website != null) ...[
                          const Divider(height: 14, color: Color(0xFFF8FAFC)),
                          _buildDialogRow(
                            "Host / Portal",
                            booking.website?['name']?.toString() ??
                                booking.website?['domain']?.toString() ??
                                "Team One",
                          ),
                        ],
                        if (booking.otp != null ||
                            booking.otpVerifiedAt != null) ...[
                          const Divider(height: 14, color: Color(0xFFF8FAFC)),
                          _buildDialogRow(
                            "Check-in OTP",
                            booking.otpVerifiedAt != null
                                ? "Verified"
                                : (booking.otp ?? "Pending verification"),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 4. Payment Breakdown Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.payments_outlined,
                                size: 18, color: Color(0xFF002060)),
                            SizedBox(width: 8),
                            Text(
                              "Payment Breakdown",
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 18, color: Color(0xFFF1F5F9)),
                        _buildDialogRow(
                          "Rent Amount",
                          booking.formattedAmount ??
                              "₹${booking.finalAmount ?? 0}",
                        ),
                        const Divider(height: 14, color: Color(0xFFF8FAFC)),
                        _buildDialogRow(
                          "Payment Status",
                          booking.paymentStatusBadge?.isNotEmpty == true
                              ? booking.paymentStatusBadge!
                              : (isPaid ? "PAID" : "UNPAID"),
                        ),
                        if (property?.securityDeposit != null) ...[
                          const Divider(height: 14, color: Color(0xFFF8FAFC)),
                          _buildDialogRow(
                            "Security Deposit",
                            "₹${property!.securityDeposit}",
                          ),
                        ],
                        const Divider(height: 18, color: Color(0xFFE2E8F0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "Total Payable",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              booking.formattedAmount ??
                                  "₹${booking.finalAmount ?? 0}",
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF002060),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 5. Official Invoice PDF Card (if invoice or can_invoice)
                  if (invoice != null ||
                      booking.actions?['can_invoice'] == true) ...[
                    const SizedBox(height: 14),
                    GetBuilder<RoomController>(
                      builder: (rCtrl) {
                        final isDownloading = rCtrl.isInvoiceDownloading &&
                            rCtrl.downloadingInvoiceId == invoiceId;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF002060).withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFF002060)
                                    .withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF002060),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.picture_as_pdf_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      invoiceNumber != null
                                          ? "Invoice $invoiceNumber"
                                          : "Official Tax Invoice",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "Download official GST receipt in PDF",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF002060),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: isDownloading
                                    ? null
                                    : () {
                                        rCtrl.downloadOrOpenInvoicePdf(
                                          invoiceId: invoiceId,
                                          invoiceNumber: invoiceNumber,
                                        );
                                      },
                                icon: isDownloading
                                    ? const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.download_rounded,
                                        size: 14),
                                label: Text(
                                  isDownloading ? "Opening..." : "Download",
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // 6. Action Buttons
                  if (booking.actions?['can_pay'] == true) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 1,
                      ),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        onPayTap(booking);
                      },
                      child: Text(
                        "Pay Now to Confirm (${booking.formattedAmount ?? '₹${booking.finalAmount ?? 0}'})",
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (booking.actions?['can_verify_otp'] == true ||
                      (booking.status ?? "").toLowerCase() == 'pending_otp') ...[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 1,
                      ),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _showVerifyOtpDialog(context, booking);
                      },
                      icon: const Icon(Icons.verified_user_rounded, size: 18),
                      label: const Text(
                        "Verify Check-in OTP",
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  if (booking.actions?['can_cancel'] == true) ...[
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        _showCancelBookingDialog(context, booking);
                      },
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text(
                        "Cancel This Booking",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF002060),
                      side: const BorderSide(color: Color(0xFF002060)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(sheetCtx),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyImagePlaceholder() {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF002060).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.apartment_rounded,
        size: 30,
        color: Color(0xFF002060),
      ),
    );
  }

  Widget _buildDialogRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}
