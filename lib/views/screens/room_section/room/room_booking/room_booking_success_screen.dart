import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_booking_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/room_bottom_nav_bar_screen.dart';

class RoomBookingSuccessScreen extends StatelessWidget {
  final String bookingNumber;
  final String propertyName;
  final String propertyAddress;
  final String roomNumber;
  final String floorName;
  final String roomType;
  final String moveInDate;
  final int durationMonths;
  final double totalAmount;
  final String paymentMethod;
  final String tenantName;
  final String tenantPhone;
  final Map<String, dynamic>? bookingResponse;

  const RoomBookingSuccessScreen({
    super.key,
    required this.bookingNumber,
    required this.propertyName,
    required this.propertyAddress,
    required this.roomNumber,
    required this.floorName,
    required this.roomType,
    required this.moveInDate,
    required this.durationMonths,
    required this.totalAmount,
    required this.paymentMethod,
    required this.tenantName,
    required this.tenantPhone,
    this.bookingResponse,
  });

  Map<String, dynamic> _nestedMap(String key) {
    final value = bookingResponse?[key];
    return value is Map ? Map<String, dynamic>.from(value) : const {};
  }

  String _responseString(String? value, String fallback) =>
      value == null || value.isEmpty ? fallback : value;

  String get _bookingReference => _responseString(
        bookingResponse?['booking_number']?.toString(),
        bookingNumber,
      );

  String get _status => _responseString(
        bookingResponse?['status']?.toString(),
        'confirmed',
      );

  String get _statusLabel =>
      _status.replaceAll('_', ' ').split(' ').map((word) {
        if (word.isEmpty) return word;
        return '${word[0].toUpperCase()}${word.substring(1)}';
      }).join(' ');

  String get _apiPropertyName =>
      _responseString(_nestedMap('listing')['title']?.toString(), propertyName);

  String get _apiPropertyAddress {
    final listing = _nestedMap('listing');
    final address = listing['address']?.toString() ?? '';
    final city = listing['city']?.toString() ?? '';
    final combined =
        [address, city].where((part) => part.isNotEmpty).join(', ');
    return combined.isEmpty ? propertyAddress : combined;
  }

  String get _apiCustomerName =>
      _responseString(_nestedMap('customer')['name']?.toString(), tenantName);

  String get _apiCustomerPhone => _responseString(
      _nestedMap('customer')['mobile']?.toString(), tenantPhone);

  String get _apiPaymentMethod => _responseString(
        bookingResponse?['payment_method']?.toString(),
        paymentMethod,
      );

  String get _apiMoveInDate => _responseString(
        bookingResponse?['move_in_date']?.toString(),
        moveInDate,
      );

  String get _apiPackageName => _nestedMap('package')['name']?.toString() ?? '';

  String get _apiInvoiceNumber =>
      _nestedMap('invoice')['invoice_number']?.toString() ?? '';

  String get _apiOtp => bookingResponse?['otp']?.toString() ?? '';

  String get _apiBookingId => bookingResponse?['booking_id']?.toString() ?? '';

  String get _apiWebsiteName => _nestedMap('website')['name']?.toString() ?? '';

  String get _apiAmount {
    final pricing = _nestedMap('pricing');
    final invoice = _nestedMap('invoice');
    final amount =
        num.tryParse('${pricing['final_amount'] ?? invoice['total'] ?? ''}');
    final currencySymbol = pricing['currency_symbol']?.toString() ?? '₹';
    return amount == null
        ? '₹${totalAmount.toInt()}'
        : '$currencySymbol${amount.toStringAsFixed(0)}';
  }

  void _shareBookingReceipt() {
    final buffer = StringBuffer("🎉 Room Booking Details\n\n");
    buffer.writeln("Booking Ref: $_bookingReference");
    buffer.writeln("Status: $_statusLabel");
    buffer.writeln("Property: $_apiPropertyName");
    buffer.writeln("Address: $_apiPropertyAddress");
    buffer.writeln("Room: $roomNumber ($floorName)");
    buffer.writeln("Sharing: $roomType");
    buffer.writeln("Move-in Date: $_apiMoveInDate");
    buffer.writeln("Duration: $durationMonths Months");
    buffer.writeln("Tenant: $_apiCustomerName ($_apiCustomerPhone)");
    buffer.writeln("Total Payable: $_apiAmount");
    buffer.writeln(
        "Payment: ${_apiPaymentMethod == 'cash' ? 'Pay at Property' : 'Paid Online'}");
    if (_apiOtp.isNotEmpty) buffer.writeln("Booking OTP: $_apiOtp");
    if (_apiInvoiceNumber.isNotEmpty) {
      buffer.writeln("Invoice: $_apiInvoiceNumber");
    }
    buffer.writeln("\nThank you for choosing $_apiPropertyName via Feetrack!");

    Share.share(buffer.toString());
  }

  Future<void> _handleDownloadInvoice(BuildContext context) async {
    final invoice = _nestedMap('invoice');
    final invoiceId = invoice['id']?.toString();
    if (invoiceId != null &&
        invoiceId.isNotEmpty &&
        Get.isRegistered<RoomController>()) {
      await Get.find<RoomController>().downloadOrOpenInvoicePdf(
        invoiceId: invoiceId,
        invoiceNumber:
            _apiInvoiceNumber.isEmpty ? _bookingReference : _apiInvoiceNumber,
      );
      return;
    }

    if (!Get.isRegistered<RoomController>()) return;
    final rCtrl = Get.find<RoomController>();

    if (rCtrl.customerInvoicesList.isEmpty) {
      await rCtrl.fetchPgCustomerInvoices();
    }

    final match = rCtrl.customerInvoicesList.firstWhereOrNull(
          (inv) => inv.bookingNumber == _bookingReference,
        ) ??
        (rCtrl.customerInvoicesList.isNotEmpty
            ? rCtrl.customerInvoicesList.first
            : null);

    if (match != null && match.id != null) {
      await rCtrl.downloadOrOpenInvoicePdf(
        invoiceId: match.id!,
        invoiceNumber: match.invoiceNumber ?? _bookingReference,
      );
    } else {
      await rCtrl.fetchPgCustomerInvoices();
      final retryMatch = rCtrl.customerInvoicesList.firstWhereOrNull(
            (inv) => inv.bookingNumber == _bookingReference,
          ) ??
          (rCtrl.customerInvoicesList.isNotEmpty
              ? rCtrl.customerInvoicesList.first
              : null);

      if (retryMatch != null && retryMatch.id != null) {
        await rCtrl.downloadOrOpenInvoicePdf(
          invoiceId: retryMatch.id!,
          invoiceNumber: retryMatch.invoiceNumber ?? _bookingReference,
        );
      } else {
        showToast(
            message:
                "Generating invoice PDF, please check My Bookings shortly.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Get.offAll(() => const RoomBottomNavBarScreen(initialIndex: 1));
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            "Booking Confirmation",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE2E8F0), height: 1),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002060),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Get.offAll(
                        () => const MyRoomBookingScreen());
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_outline, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "View My Room Bookings",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF002060),
                    side:
                        const BorderSide(color: Color(0xFF002060), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.offAll(
                        () => const RoomBottomNavBarScreen(initialIndex: 0));
                  },
                  child: const Text(
                    "Back to Explore PGs",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
          child: Column(
            children: [
              // 1. Success Animation / Badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  border:
                      Border.all(color: const Color(0xFF10B981), width: 2.5),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF10B981),
                  size: 44,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _status == 'pending_otp'
                    ? "Booking Request Received"
                    : "Room Booked Successfully!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _status == 'pending_otp'
                    ? "Your booking request for $_apiPropertyName is awaiting OTP verification."
                    : "Your reservation at $_apiPropertyName is confirmed.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Reference & Share Bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Booking Reference",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _bookingReference,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF002060),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: "Copy Reference",
                          icon: const Icon(Icons.copy,
                              size: 18, color: Color(0xFF002060)),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _bookingReference),
                            );
                            showToast(message: "Booking reference copied!");
                          },
                        ),
                        IconButton(
                          tooltip: "Share Details",
                          icon: const Icon(Icons.share_outlined,
                              size: 18, color: Color(0xFF002060)),
                          onPressed: _shareBookingReceipt,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2.1 Dedicated Invoice Download Card
              GetBuilder<RoomController>(
                builder: (rCtrl) {
                  final isDownloading = rCtrl.isInvoiceDownloading;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              const Color(0xFF002060).withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF002060).withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF002060).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Color(0xFF002060),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tax Invoice & Receipt",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Official GST invoice & payment receipt",
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002060),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: isDownloading
                              ? null
                              : () => _handleDownloadInvoice(context),
                          icon: isDownloading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download_rounded, size: 16),
                          label: Text(
                            isDownloading ? "Opening..." : "Invoice PDF",
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 3. Complete Booking Summary Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.domain_verification,
                            size: 20, color: Color(0xFF002060)),
                        SizedBox(width: 8),
                        Text(
                          "Reservation Summary",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildSummaryItem("Booking Status", _statusLabel,
                        highlight: true),
                    if (_apiBookingId.isNotEmpty)
                      _buildSummaryItem("Booking ID", _apiBookingId),
                    _buildSummaryItem("PG / Property", _apiPropertyName,
                        isBold: true),
                    if (_apiWebsiteName.isNotEmpty)
                      _buildSummaryItem("Website", _apiWebsiteName),
                    _buildSummaryItem("Address", _apiPropertyAddress),
                    _buildSummaryItem(
                        "Room & Floor", "$roomNumber • $floorName"),
                    if (_apiPackageName.isNotEmpty)
                      _buildSummaryItem("Package", _apiPackageName),
                    _buildSummaryItem(
                      "Sharing Type",
                      _responseString(
                        _nestedMap('package')['occupancy_type']?.toString(),
                        roomType,
                      ),
                    ),
                    _buildSummaryItem("Move-in Date", _apiMoveInDate,
                        highlight: true),
                    _buildSummaryItem(
                        "Duration", "$durationMonths Months Agreement"),
                    _buildSummaryItem("Resident", _apiCustomerName),
                    _buildSummaryItem("Contact", _apiCustomerPhone),
                    if (_apiOtp.isNotEmpty)
                      _buildSummaryItem("Booking OTP", _apiOtp,
                          isBold: true, highlight: true),
                    if (_apiInvoiceNumber.isNotEmpty)
                      _buildSummaryItem("Invoice Number", _apiInvoiceNumber),
                    _buildSummaryItem(
                      "Payment Status",
                      _apiPaymentMethod == 'cash'
                          ? "Pay at Property on Check-in"
                          : "Paid Online",
                      color: _apiPaymentMethod == 'cash'
                          ? const Color(0xFFD97706)
                          : const Color(0xFF10B981),
                    ),
                    const Divider(color: Color(0xFFE2E8F0), height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          _apiAmount,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF002060),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Instructions Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFF1D4ED8), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Please arrive on your scheduled move-in date with your government photo ID for identity verification and key handover.",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1E40AF),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value, {
    bool isBold = false,
    bool highlight = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isBold || highlight ? FontWeight.w800 : FontWeight.w600,
                color: color ??
                    (highlight
                        ? const Color(0xFF002060)
                        : const Color(0xFF1E293B)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
