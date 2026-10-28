import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_invoice_detail_pdf_screen.dart';

class PgInvoiceListScreen extends StatefulWidget {
  const PgInvoiceListScreen({super.key});

  @override
  State<PgInvoiceListScreen> createState() => _PgInvoiceListScreenState();
}

class _PgInvoiceListScreenState extends State<PgInvoiceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RoomController>().fetchPgCustomerInvoices();
    });
  }

  void _openInvoiceDetail(PgCustomerInvoiceItem invoice) {
    final invId = (invoice.id != null && invoice.id!.isNotEmpty)
        ? invoice.id!
        : (invoice.invoiceNumber ?? "");

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PgInvoiceDetailPdfScreen(
          invoiceId: invId,
          initialInvoice: invoice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF002060)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Invoices & Tax Receipts",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<RoomController>(
        builder: (controller) {
          if (controller.isCustomerInvoicesLoading &&
              controller.customerInvoicesList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF002060),
              ),
            );
          }

          final invoices = controller.customerInvoicesList;

          if (invoices.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFF002060),
              onRefresh: () async {
                await controller.fetchPgCustomerInvoices();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF002060).withValues(alpha: 0.06),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: Color(0xFF002060),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "No Invoices Found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Invoices and payment receipts for your stays will show here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: () async {
              await controller.fetchPgCustomerInvoices();
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              itemCount: invoices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return _buildListItem(invoice, controller);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildListItem(
      PgCustomerInvoiceItem invoice, RoomController controller) {
    final isPaid = (invoice.status ?? "").toLowerCase() == 'paid';
    final isDownloading = controller.isInvoiceDownloading &&
        controller.downloadingInvoiceId == invoice.id;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openInvoiceDetail(invoice),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Invoice No and Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF002060).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 16,
                          color: Color(0xFF002060),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        invoice.invoiceNumber ?? "Invoice",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF002060),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPaid
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          invoice.statusLabel ?? (isPaid ? "Paid" : "Pending"),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isPaid
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Property title
              if (invoice.property?.title != null) ...[
                Text(
                  invoice.property!.title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Booking number & Date
              Row(
                children: [
                  if (invoice.bookingNumber != null) ...[
                    Text(
                      "Ref: ${invoice.bookingNumber}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(" • ",
                        style: TextStyle(color: Color(0xFFCBD5E1))),
                  ],
                  Text(
                    invoice.formattedDate ?? invoice.dueDate ?? "",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              const Divider(height: 18, color: Color(0xFFF1F5F9)),

              // Amount and Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        invoice.formattedTotal ??
                            "₹${invoice.total ?? invoice.amount ?? 0}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF002060),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                        ),
                        onPressed: () => _openInvoiceDetail(invoice),
                        icon: const Icon(Icons.remove_red_eye_outlined,
                            size: 15),
                        label: const Text(
                          "View PDF",
                          style: TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 4),
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
                                controller.downloadOrOpenInvoicePdf(
                                  invoiceId: invoice.id ?? "",
                                  invoiceNumber: invoice.invoiceNumber,
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
                            : const Icon(Icons.picture_as_pdf_rounded,
                                size: 15),
                        label: Text(
                          isDownloading ? "Opening..." : "Download",
                          style: const TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
