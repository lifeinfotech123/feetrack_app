import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/services/constants.dart';
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
  });

  void _shareBookingReceipt() {
    final buffer = StringBuffer("🎉 Room Booking Confirmed!\n\n");
    buffer.writeln("Booking Ref: $bookingNumber");
    buffer.writeln("Property: $propertyName");
    buffer.writeln("Address: $propertyAddress");
    buffer.writeln("Room: $roomNumber ($floorName)");
    buffer.writeln("Sharing: $roomType");
    buffer.writeln("Move-in Date: $moveInDate");
    buffer.writeln("Duration: $durationMonths Months");
    buffer.writeln("Tenant: $tenantName ($tenantPhone)");
    buffer.writeln("Total Payable: ₹${totalAmount.toInt()}");
    buffer.writeln("Payment: ${paymentMethod == 'online' ? 'Paid Online' : 'Pay at Property'}");
    buffer.writeln("\nThank you for choosing $propertyName via Feetrack!");

    Share.share(buffer.toString());
  }

  Future<void> _handleDownloadInvoice(BuildContext context) async {
    if (!Get.isRegistered<RoomController>()) return;
    final rCtrl = Get.find<RoomController>();

    if (rCtrl.customerInvoicesList.isEmpty) {
      await rCtrl.fetchPgCustomerInvoices();
    }

    final match = rCtrl.customerInvoicesList.firstWhereOrNull(
      (inv) => inv.bookingNumber == bookingNumber,
    ) ?? (rCtrl.customerInvoicesList.isNotEmpty ? rCtrl.customerInvoicesList.first : null);

    if (match != null && match.id != null) {
      await rCtrl.downloadOrOpenInvoicePdf(
        invoiceId: match.id!,
        invoiceNumber: match.invoiceNumber ?? bookingNumber,
      );
    } else {
      await rCtrl.fetchPgCustomerInvoices();
      final retryMatch = rCtrl.customerInvoicesList.firstWhereOrNull(
        (inv) => inv.bookingNumber == bookingNumber,
      ) ?? (rCtrl.customerInvoicesList.isNotEmpty ? rCtrl.customerInvoicesList.first : null);

      if (retryMatch != null && retryMatch.id != null) {
        await rCtrl.downloadOrOpenInvoicePdf(
          invoiceId: retryMatch.id!,
          invoiceNumber: retryMatch.invoiceNumber ?? bookingNumber,
        );
      } else {
        showToast(message: "Generating invoice PDF, please check My Bookings shortly.");
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
                    Get.offAll(() => const RoomBottomNavBarScreen(initialIndex: 1));
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
                    side: const BorderSide(color: Color(0xFF002060), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.offAll(() => const RoomBottomNavBarScreen(initialIndex: 0));
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
                  border: Border.all(color: const Color(0xFF10B981), width: 2.5),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF10B981),
                  size: 44,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Room Booked Successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Your reservation at $propertyName is confirmed.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Reference & Share Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          bookingNumber,
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
                          icon: const Icon(Icons.copy, size: 18, color: Color(0xFF002060)),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: bookingNumber));
                            showToast(message: "Booking reference copied!");
                          },
                        ),
                        IconButton(
                          tooltip: "Share Details",
                          icon: const Icon(Icons.share_outlined, size: 18, color: Color(0xFF002060)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF002060).withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF002060).withValues(alpha: 0.04),
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
                            color: const Color(0xFF002060).withValues(alpha: 0.08),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
                        Icon(Icons.domain_verification, size: 20, color: Color(0xFF002060)),
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
                    _buildSummaryItem("PG / Property", propertyName, isBold: true),
                    _buildSummaryItem("Address", propertyAddress),
                    _buildSummaryItem("Room & Floor", "$roomNumber • $floorName"),
                    _buildSummaryItem("Sharing Type", roomType),
                    _buildSummaryItem("Move-in Date", moveInDate, highlight: true),
                    _buildSummaryItem("Duration", "$durationMonths Months Agreement"),
                    _buildSummaryItem("Resident", tenantName),
                    _buildSummaryItem("Contact", tenantPhone),
                    _buildSummaryItem(
                      "Payment Status",
                      paymentMethod == 'online'
                          ? "Paid Online (Confirmed)"
                          : "Pay at Property on Check-in",
                      color: paymentMethod == 'online'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFD97706),
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
                          "₹${totalAmount.toInt()}",
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
                    Icon(Icons.info_outline, color: Color(0xFF1D4ED8), size: 20),
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
                fontWeight: isBold || highlight ? FontWeight.w800 : FontWeight.w600,
                color: color ??
                    (highlight ? const Color(0xFF002060) : const Color(0xFF1E293B)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
