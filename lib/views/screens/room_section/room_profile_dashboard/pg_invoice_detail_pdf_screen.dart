import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';
import 'package:vlr/data/models/rooom/pg_customer_invoice_detail_model.dart';
import 'package:vlr/views/base/dotted_line.dart';

class PgInvoiceDetailPdfScreen extends StatefulWidget {
  final String invoiceId;
  final PgCustomerInvoiceItem? initialInvoice;

  const PgInvoiceDetailPdfScreen({
    super.key,
    required this.invoiceId,
    this.initialInvoice,
  });

  @override
  State<PgInvoiceDetailPdfScreen> createState() =>
      _PgInvoiceDetailPdfScreenState();
}

class _PgInvoiceDetailPdfScreenState extends State<PgInvoiceDetailPdfScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RoomController>().fetchPgCustomerInvoiceDetail(widget.invoiceId);
    });
  }

  void _shareInvoiceText(PgCustomerInvoiceDetailData? detail) {
    final invNo = detail?.invoiceNumber ??
        widget.initialInvoice?.invoiceNumber ??
        widget.invoiceId;
    final propName = detail?.property?.title ??
        widget.initialInvoice?.property?.title ??
        "PG Accommodation";
    final address = detail?.property?.address ?? "";
    final city = detail?.property?.city ?? "";
    final custName = detail?.customer?.name ?? "Customer";
    final custPhone = detail?.customer?.mobile ?? "";
    final bookingRef = detail?.bookingNumber ??
        widget.initialInvoice?.bookingNumber ??
        "-";
    final pkgName = detail?.package?.name ?? "Room Accommodation";
    final total = detail?.formattedTotal ??
        widget.initialInvoice?.formattedTotal ??
        "₹${detail?.total ?? widget.initialInvoice?.total ?? 0}";
    final status = detail?.statusLabel ??
        widget.initialInvoice?.statusLabel ??
        "Paid";
    final date = detail?.formattedDate ??
        widget.initialInvoice?.formattedDate ??
        "-";

    final text = StringBuffer()
      ..writeln("🧾 TAX INVOICE & RECEIPT")
      ..writeln("═══════════════════════════")
      ..writeln("Invoice No: $invNo")
      ..writeln("Date: $date")
      ..writeln("Property: $propName")
      ..writeln("Address: $address, $city")
      ..writeln("Customer: $custName ($custPhone)")
      ..writeln("Booking Ref: $bookingRef")
      ..writeln("Package: $pkgName")
      ..writeln("Total Paid: $total")
      ..writeln("Status: $status")
      ..writeln("═══════════════════════════")
      ..writeln("Generated via FeeTrack PG Portal");

    // ignore: deprecated_member_use
    Share.share(text.toString(), subject: "Invoice $invNo");
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoomController>(
      builder: (controller) {
        final detail = controller.selectedCustomerInvoiceDetail;
        final isLoading = controller.isCustomerInvoiceDetailLoading && detail == null;

        final invoiceNo = detail?.invoiceNumber ??
            widget.initialInvoice?.invoiceNumber ??
            widget.invoiceId;
        final isPaid = ((detail?.status ?? widget.initialInvoice?.status ?? 'paid')
                .toLowerCase() ==
            'paid');
        final isDownloading = controller.isInvoiceDownloading &&
            controller.downloadingInvoiceId == widget.invoiceId;

        return Scaffold(
          backgroundColor: const Color(0xFFE2E8F0),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Color(0xFF002060)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tax Invoice & Receipt",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  invoiceNo,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: "Share Invoice",
                icon: const Icon(Icons.share_outlined,
                    color: Color(0xFF002060), size: 20),
                onPressed: () => _shareInvoiceText(detail),
              ),
              IconButton(
                tooltip: "Download PDF",
                icon: isDownloading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF002060),
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded,
                        color: Color(0xFF002060), size: 20),
                onPressed: isDownloading
                    ? null
                    : () {
                        controller.downloadOrOpenInvoicePdf(
                          invoiceId: widget.invoiceId,
                          invoiceNumber: invoiceNo,
                        );
                      },
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: () async {
              await controller.fetchPgCustomerInvoiceDetail(widget.invoiceId);
            },
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF002060),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
                    child: Column(
                      children: [
                        // PDF Paper Document Container
                        _buildPdfPaperDocument(
                          context,
                          detail,
                          invoiceNo,
                          isPaid,
                        ),

                        const SizedBox(height: 18),

                        // Bottom Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF002060),
                                  side: const BorderSide(
                                      color: Color(0xFF002060), width: 1.4),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => _shareInvoiceText(detail),
                                icon: const Icon(Icons.share_rounded, size: 17),
                                label: const Text(
                                  "Share Invoice",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF002060),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: isDownloading
                                    ? null
                                    : () {
                                        controller.downloadOrOpenInvoicePdf(
                                          invoiceId: widget.invoiceId,
                                          invoiceNumber: invoiceNo,
                                        );
                                      },
                                icon: isDownloading
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.download_rounded,
                                        size: 18),
                                label: Text(
                                  isDownloading
                                      ? "Opening..."
                                      : "Download PDF",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  /// Authentic PDF Invoice Paper Sheet
  Widget _buildPdfPaperDocument(
    BuildContext context,
    PgCustomerInvoiceDetailData? detail,
    String invoiceNo,
    bool isPaid,
  ) {
    final propertyTitle = detail?.property?.title ??
        widget.initialInvoice?.property?.title ??
        "PG Accommodation";
    final address = detail?.property?.address ?? "";
    final city = detail?.property?.city ?? "";
    final phone = detail?.property?.phone;
    final websiteName = detail?.website?.name;
    final websiteDomain = detail?.website?.domain;

    final customerName = detail?.customer?.name ?? "Valued Guest";
    final customerEmail = detail?.customer?.email;
    final customerMobile = detail?.customer?.mobile;

    final bookingRef = detail?.bookingNumber ??
        widget.initialInvoice?.bookingNumber ??
        "-";
    final occupancy = detail?.booking?.occupancyType != null
        ? detail!.booking!.occupancyType!.replaceAll('_', ' ').capitalizeFirst
        : "Per Bed";
    final bedsBooked = detail?.booking?.bedsBooked ?? 1;

    final packageName = detail?.package?.name ??
        "Double Sharing (Meals Included)";
    final durationDays = detail?.package?.durationDays ?? 30;
    final baseAmount = detail?.amount ??
        detail?.package?.price ??
        widget.initialInvoice?.amount ??
        0;
    final taxAmount = detail?.tax ?? widget.initialInvoice?.tax ?? 0;
    final totalDisplay = detail?.formattedTotal ??
        widget.initialInvoice?.formattedTotal ??
        "₹${detail?.total ?? widget.initialInvoice?.total ?? baseAmount}";

    final invoiceDate = detail?.formattedDate ??
        widget.initialInvoice?.formattedDate ??
        detail?.createdAt ??
        "-";
    final dueDate = detail?.dueDate ?? widget.initialInvoice?.dueDate ?? "-";

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Top Paper Header (Property info + Paid Stamp) ──
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF002060)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.apartment_rounded,
                              size: 18,
                              color: Color(0xFF002060),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              propertyTitle,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (address.isNotEmpty || city.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          [address, city]
                              .where((s) => s.isNotEmpty)
                              .join(", "),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      if (phone != null && phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          "Phone: +91 $phone",
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                      if (websiteName != null || websiteDomain != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          [websiteName, websiteDomain]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(" • "),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF002060),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Official Paid / Pending Stamp
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                        : const Color(0xFFEA580C).withValues(alpha: 0.1),
                    border: Border.all(
                      color: isPaid
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFEA580C),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaid
                            ? Icons.check_circle_rounded
                            : Icons.access_time_filled_rounded,
                        size: 13,
                        color: isPaid
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFEA580C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPaid ? "PAID" : "PENDING",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: isPaid
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Perforated Divider
          const DottedLine(
            color: Color(0xFFE2E8F0),
            dashWidth: 6,
            dashHeight: 1.2,
          ),

          // ── 2. Tax Invoice Title & Metadata Grid ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            color: const Color(0xFFF8FAFC),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TAX INVOICE / RECEIPT",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: Color(0xFF002060),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Text(
                        "ORIGINAL",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetaItem("Invoice Number", invoiceNo),
                    ),
                    Expanded(
                      child: _buildMetaItem("Date & Time", invoiceDate),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetaItem("Booking Ref", bookingRef),
                    ),
                    Expanded(
                      child: _buildMetaItem("Due Date", dueDate),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const DottedLine(
            color: Color(0xFFE2E8F0),
            dashWidth: 6,
            dashHeight: 1.2,
          ),

          // ── 3. Billed To (Customer) & Stay Info ──
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Billed to
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "BILLED TO (CUSTOMER)",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (customerMobile != null &&
                          customerMobile.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          "Mob: $customerMobile",
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                      if (customerEmail != null &&
                          customerEmail.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          customerEmail,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Accommodation info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "STAY & BOOKING",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Occupancy: $occupancy",
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Bed(s) Booked: $bedsBooked",
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        "Status: ${detail?.booking?.status?.capitalizeFirst ?? 'Confirmed'}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const DottedLine(
            color: Color(0xFFE2E8F0),
            dashWidth: 6,
            dashHeight: 1.2,
          ),

          // ── 4. Line Items Table (PDF Table) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "BILLING PARTICULARS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Table Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          "DESCRIPTION",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "DURATION",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "AMOUNT",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Item Row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              packageName,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Bed Booking & Facilities ($occupancy)",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "$durationDays Days",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "₹$baseAmount",
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const DottedLine(
            color: Color(0xFFE2E8F0),
            dashWidth: 6,
            dashHeight: 1.2,
          ),

          // ── 5. Financial Summary / Calculation Breakdown ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              children: [
                _buildAmountRow("Subtotal", "₹$baseAmount"),
                const SizedBox(height: 6),
                _buildAmountRow("Taxes & GST", "₹$taxAmount"),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Invoice Amount",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF002060),
                      ),
                    ),
                    Text(
                      totalDisplay,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF002060),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Amount Paid",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    Text(
                      isPaid ? totalDisplay : "₹0.00",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
                if (!isPaid) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Balance Due",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      Text(
                        totalDisplay,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── 6. Bottom Notice / Computer Generated Stamp ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: isPaid
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isPaid
                          ? "Verified Computer-Generated Tax Invoice"
                          : "Computer-Generated Digital Proforma Invoice",
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  "This receipt is digitally issued and does not require physical signature or stamp.",
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
