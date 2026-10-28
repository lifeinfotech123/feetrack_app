import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/transaction_history_controller.dart';
import 'package:vlr/services/constants.dart';

class TransactionSummaryScreen extends StatefulWidget {
  const TransactionSummaryScreen({super.key});

  @override
  State<TransactionSummaryScreen> createState() => _TransactionSummaryScreenState();
}

class _TransactionSummaryScreenState extends State<TransactionSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<TransactionHistoryController>()) {
        Get.find<TransactionHistoryController>().fetchTransactionSummary();
      } else {
        Get.put(TransactionHistoryController(apiClient: Get.find()));
        Get.find<TransactionHistoryController>().fetchTransactionSummary();
      }
    });
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
          "Transaction Summary",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
        ),
      ),
      body: GetBuilder<TransactionHistoryController>(
        builder: (controller) {
          final data = controller.summaryData;
          if (controller.isSummaryLoading && data.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF002060)));
          }
          final user = data['user'] is Map ? Map<String, dynamic>.from(data['user']) : {};
          final breakdown = data['module_breakdown'] is Map ? Map<String, dynamic>.from(data['module_breakdown']) : {};
          return RefreshIndicator(
            onRefresh: () => controller.fetchTransactionSummary(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF002060).withValues(alpha: 0.1),
                          child: Text(
                            (user['name']?.toString().isNotEmpty == true) ? user['name'].toString().substring(0, 1).toUpperCase() : 'U',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF002060), fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['name']?.toString() ?? "-", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                              const SizedBox(height: 4),
                              Text("${user['email'] ?? ''} • ${user['phone'] ?? ''}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                              const SizedBox(height: 4),
                              Text("Wallet Balance: ₹${user['wallet_balance'] ?? 0}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF16A34A))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _card("Total Transactions", "${data['total_transactions'] ?? 0}")),
                      const SizedBox(width: 10),
                      Expanded(child: _card("Total Spent", data['formatted_spent']?.toString() ?? "₹0.00")),
                      const SizedBox(width: 10),
                      Expanded(child: _card("Total Credited", data['formatted_credited']?.toString() ?? "₹0.00")),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text("Module Breakdown", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  _moduleTile("Hospital & Healthcare", Icons.local_hospital_rounded, const Color(0xFF2563EB), breakdown['hospital']),
                  const SizedBox(height: 10),
                  _moduleTile("Room / PG", Icons.home_work_rounded, const Color(0xFF7C3AED), breakdown['room']),
                  const SizedBox(height: 10),
                  _moduleTile("Gym", Icons.fitness_center_rounded, const Color(0xFF16A34A), breakdown['gym']),
                  const SizedBox(height: 10),
                  _moduleTile("Wallet", Icons.account_balance_wallet_rounded, const Color(0xFFEA580C), breakdown['wallet']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _card(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        ],
      ),
    );
  }

  Widget _moduleTile(String title, IconData icon, Color color, dynamic data) {
    final map = data is Map ? Map<String, dynamic>.from(data) : {};
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text("Count: ${map['count'] ?? 0} • Spent: ₹${map['spent'] ?? 0}${map['topups'] != null ? ' • Topups: ₹${map['topups']}' : ''}", style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
