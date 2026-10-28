import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/transaction_history_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/total_transaction_history/transaction_history_detail_screen.dart';

class TotalTransactionHistoryScreen extends StatefulWidget {
  const TotalTransactionHistoryScreen({super.key});

  @override
  State<TotalTransactionHistoryScreen> createState() =>
      _TotalTransactionHistoryScreenState();
}

class _TotalTransactionHistoryScreenState
    extends State<TotalTransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<TransactionHistoryController>()) {
        Get.find<TransactionHistoryController>().fetchTransactions();
      } else {
        Get.put(TransactionHistoryController(apiClient: Get.find()));
        Get.find<TransactionHistoryController>().fetchTransactions();
      }
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
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

  IconData _getIcon(String? module) {
    switch (module?.toLowerCase()) {
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'room':
        return Icons.home_work_rounded;
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color _getIconColor(String? module) {
    switch (module?.toLowerCase()) {
      case 'hospital':
        return const Color(0xFF2563EB);
      case 'room':
        return const Color(0xFF7C3AED);
      case 'gym':
        return const Color(0xFF16A34A);
      case 'wallet':
        return const Color(0xFFEA580C);
      default:
        return const Color(0xFF002060);
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Total Transaction History",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: GetBuilder<TransactionHistoryController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchTransactions(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (controller.summary != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF002060), Color(0xFF1E3A8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF002060).withValues(alpha: 0.25),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Spent Amount",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.summary?.formattedSpent ?? "₹0.00",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _miniStat("Total Transactions",
                                    "${controller.summary?.totalTransactions ?? 0}"),
                              ),
                              Expanded(
                                child: _miniStat(
                                    "Total Credited",
                                    controller.summary?.formattedCredited ??
                                        "₹0.00"),
                              ),
                              Expanded(
                                child: _miniStat("Wallet Balance",
                                    "₹${controller.summary?.walletBalance?.toString() ?? '0'}"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  const Text(
                    "All Transactions",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  if (controller.isLoading && controller.transactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child:
                            CircularProgressIndicator(color: Color(0xFF002060)),
                      ),
                    )
                  else if (controller.transactions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 42, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 10),
                          Text("No transactions found",
                              style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.transactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = controller.transactions[index];
                        final isCredit = item.isCredit;
                        return InkWell(
                          onTap: () {
                            if (item.id != null) {
                              navigate(
                                context: context,
                                page: TransactionHistoryDetailScreen(
                                    transactionId: item.id!),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: _getIconColor(item.module)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(_getIcon(item.module),
                                      color: _getIconColor(item.module),
                                      size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title ??
                                            item.category ??
                                            "Transaction",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(item.date),
                                        style: const TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${isCredit ? '+' : '-'} ${item.formattedAmount ?? '₹${item.amount ?? 0}'}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: isCredit
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFDC2626),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      (item.paymentStatus ??
                                              item.bookingStatus ??
                                              "")
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF475569)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800)),
      ],
    );
  }
}
