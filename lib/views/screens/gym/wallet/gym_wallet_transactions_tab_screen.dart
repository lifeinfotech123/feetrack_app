import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/wallet_controller.dart';

class GymWalletTransactionsTabScreen extends StatelessWidget {
  const GymWalletTransactionsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Transaction History",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A3B5D),
              ),
            ),
            const SizedBox(height: 12),
            if (walletController.isTransactionsLoading &&
                walletController.myTransactions.isEmpty)
              const Center(
                  child: CircularProgressIndicator(color: Color(0xFF002060)))
            else if (walletController.myTransactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history_rounded,
                        size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text(
                      "No records found",
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: walletController.myTransactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = walletController.myTransactions[index];
                  return _buildItem(item);
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildItem(dynamic item) {
    final String title = item['title'] ??
        item['description'] ??
        item['category'] ??
        "Transaction";
    final String business =
        item['business_name'] ?? item['reference_type'] ?? "FeeTrack";
    final String reference = item['reference'] ?? item['reference_id'] ?? "";
    final num amountNum = item['amount'] ?? 0;
    final String type = (item['type'] ?? 'debit').toString();
    final bool isCredit = type == 'credit';
    final String dateStr =
        item['date']?.toString() ?? item['created_at']?.toString() ?? '';
    String dateLabel = dateStr;
    try {
      final dt = DateTime.parse(dateStr);
      dateLabel = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color:
                  (isCredit ? Colors.green : Colors.red).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  business,
                  style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                (isCredit ? "+ " : "- ") + "₹${amountNum.toString()}",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              if (reference.isNotEmpty)
                Text(
                  reference,
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 9),
                ),
            ],
          )
        ],
      ),
    );
  }
}
