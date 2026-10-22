import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/attendance_controller.dart';
import 'package:vlr/data/models/gym_invoice_model.dart';

class GymInvoiceDetailScreen extends StatefulWidget {
  final String invoiceId;
  final GymInvoiceItem? initialInvoice;

  const GymInvoiceDetailScreen({
    super.key,
    required this.invoiceId,
    this.initialInvoice,
  });

  @override
  State<GymInvoiceDetailScreen> createState() => _GymInvoiceDetailScreenState();
}

class _GymInvoiceDetailScreenState extends State<GymInvoiceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.invoiceId.isNotEmpty) {
        Get.find<AttendanceController>().fetchGymInvoiceDetails(widget.invoiceId);
      }
    });
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF002060),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Invoice Receipt",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
      ),
      body: GetBuilder<AttendanceController>(
        builder: (controller) {
          final isLoading = controller.isInvoiceDetailLoading;
          final invoice = controller.selectedInvoiceDetail ?? widget.initialInvoice;

          if (isLoading && invoice == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF002060),
              ),
            );
          }

          if (invoice == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Invoice Not Found",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF002060),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (widget.invoiceId.isNotEmpty) {
                        controller.fetchGymInvoiceDetails(widget.invoiceId);
                      }
                    },
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final isPaid = (invoice.status ?? "").toLowerCase() == 'paid';
          final isDownloading = controller.isInvoiceDownloading &&
              controller.downloadingInvoiceId == invoice.id;

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: () async {
              if (widget.invoiceId.isNotEmpty) {
                await controller.fetchGymInvoiceDetails(widget.invoiceId);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  // Receipt Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gym Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFF002060).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                color: Color(0xFF002060),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    invoice.gym?.title ?? "Gym Membership",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (invoice.gym?.address != null || invoice.gym?.city != null) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      [invoice.gym?.address, invoice.gym?.city]
                                          .where((e) => e != null && e.isNotEmpty)
                                          .join(", "),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                  if (invoice.gym?.phone != null && invoice.gym!.phone!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      "Ph: ${invoice.gym!.phone}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPaid
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (invoice.status ?? "PAID").toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isPaid
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFD97706),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        _buildDottedDivider(),
                        const SizedBox(height: 16),

                        // Invoice Details Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailField(
                                "INVOICE NUMBER",
                                invoice.invoiceNumber ?? "-",
                              ),
                            ),
                            Expanded(
                              child: _buildDetailField(
                                "DATE CREATED",
                                invoice.createdAt ?? "-",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailField(
                                "DUE DATE",
                                invoice.dueDate ?? "-",
                              ),
                            ),
                            Expanded(
                              child: _buildDetailField(
                                "PAYMENT STATUS",
                                isPaid ? "Paid in Full" : "Pending",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        _buildDottedDivider(),
                        const SizedBox(height: 16),

                        // Billed To Section
                        const Text(
                          "BILLED TO",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice.customer?.name ?? "Member",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (invoice.customer?.email != null && invoice.customer!.email!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 13, color: Color(0xFF64748B)),
                                    const SizedBox(width: 6),
                                    Text(
                                      invoice.customer!.email!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (invoice.customer?.phone != null && invoice.customer!.phone!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 13, color: Color(0xFF64748B)),
                                    const SizedBox(width: 6),
                                    Text(
                                      invoice.customer!.phone!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                        _buildDottedDivider(),
                        const SizedBox(height: 16),

                        // Membership Item Breakdown
                        const Text(
                          "PLAN / PACKAGE",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  invoice.package?.name ?? "Gym Membership",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                if (invoice.package?.validityDays != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    "Validity: ${invoice.package!.validityDays} Days",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              invoice.package?.price != null
                                  ? "₹${invoice.package!.price}"
                                  : (invoice.amount != null ? "₹${invoice.amount}" : "-"),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 16),

                        // Price summary rows
                        _buildSummaryRow("Base Amount", "₹${invoice.amount ?? 0}"),
                        const SizedBox(height: 8),
                        _buildSummaryRow("Taxes & GST", "₹${invoice.tax ?? 0}"),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Paid",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF002060),
                              ),
                            ),
                            Text(
                              invoice.totalFormatted ?? "₹${invoice.total ?? invoice.amount ?? 0}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF002060),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002060),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isDownloading
                          ? null
                          : () {
                              controller.downloadOrOpenInvoicePdf(invoice);
                            },
                      icon: isDownloading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download_rounded, size: 20),
                      label: Text(
                        isDownloading ? "Opening Receipt..." : "Download Official Receipt PDF",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildDottedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 4.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFCBD5E1)),
              ),
            );
          }),
        );
      },
    );
  }
}
