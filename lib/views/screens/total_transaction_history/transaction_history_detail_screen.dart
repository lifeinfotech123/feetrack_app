import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/transaction_history_controller.dart';
import 'package:vlr/services/constants.dart';

class TransactionHistoryDetailScreen extends StatefulWidget {
  final String transactionId;
  const TransactionHistoryDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionHistoryDetailScreen> createState() =>
      _TransactionHistoryDetailScreenState();
}

class _TransactionHistoryDetailScreenState
    extends State<TransactionHistoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<TransactionHistoryController>()) {
        Get.find<TransactionHistoryController>().fetchTransactionDetail(widget.transactionId);
      } else {
        Get.put(TransactionHistoryController(apiClient: Get.find()));
        Get.find<TransactionHistoryController>().fetchTransactionDetail(widget.transactionId);
      }
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final dt = DateTime.parse(dateStr.replaceAll(' ', 'T'));
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      try {
        final dt = DateTime.parse(dateStr);
        return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      } catch (_) {
        return dateStr;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Transaction Details",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
      ),
      body: GetBuilder<TransactionHistoryController>(
        builder: (controller) {
          if (controller.isDetailLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF002060)));
          }
          final item = controller.selectedTransaction;
          if (item == null) {
            return const Center(child: Text("Transaction not found"));
          }
          final isCredit = item.isCredit;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: (isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626)).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                          color: isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${isCredit ? '+' : '-'} ${item.formattedAmount ?? '₹${item.amount ?? 0}'}",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title ?? "",
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (item.paymentStatus ?? item.bookingStatus ?? "").toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Transaction Information", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      const SizedBox(height: 14),
                      _row("Reference No.", item.reference ?? "-"),
                      _divider(),
                      _row("Transaction ID", item.id ?? "-"),
                      _divider(),
                      _row("Date & Time", _formatDate(item.date)),
                      _divider(),
                      _row("Module", item.module?.toUpperCase() ?? "-"),
                      _divider(),
                      _row("Category", item.category ?? "-"),
                      _divider(),
                      _row("Business Name", item.businessName ?? "-"),
                      _divider(),
                      _row("Payment Mode", item.paymentMode ?? "-"),
                      if (item.details != null && item.details!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text("Additional Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const SizedBox(height: 10),
                        ...item.details!.entries.map((e) => Column(
                              children: [
                                _row(e.key.replaceAll('_', ' ').toUpperCase(), e.value?.toString() ?? "-"),
                                const Divider(height: 18, color: Color(0xFFF1F5F9)),
                              ],
                            )),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600))),
        const SizedBox(width: 12),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w700))),
      ],
    );
  }

  Widget _divider() => const Divider(height: 18, color: Color(0xFFF1F5F9));
}
