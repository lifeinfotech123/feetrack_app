import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';

class PgPaymentHistoryScreen extends StatefulWidget {
  const PgPaymentHistoryScreen({super.key});

  @override
  State<PgPaymentHistoryScreen> createState() => _PgPaymentHistoryScreenState();
}

class _PgPaymentHistoryScreenState extends State<PgPaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<RoomController>().fetchPgCustomerPayments();
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
          "Payment History",
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
          if (controller.isCustomerPaymentsLoading &&
              controller.customerPaymentsList.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF002060),
              ),
            );
          }

          final payments = controller.customerPaymentsList;

          if (payments.isEmpty) {
            return RefreshIndicator(
              color: const Color(0xFF002060),
              onRefresh: () async {
                await controller.fetchPgCustomerPayments();
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
                            color:
                                const Color(0xFF002060).withValues(alpha: 0.08),
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
                          "No Payment Transactions",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            "Online payments for your bookings, deposits and rent will appear here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
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
              await controller.fetchPgCustomerPayments();
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final payment = payments[index];
                return _buildPaymentCard(payment);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(PgPaymentItem payment) {
    final isPaid = (payment.status ?? "").toLowerCase() == 'paid';
    final dateStr = payment.formattedDate ?? payment.paidAt ?? "";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                          : const Color(0xFFEA580C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: isPaid
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFEA580C),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.formattedAmount ?? "₹${payment.amount ?? 0}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      if (payment.gateway != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          "via ${payment.gateway!.toUpperCase()}",
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaid ? "PAID" : (payment.status ?? "PENDING").toUpperCase(),
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

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // Gateway Reference & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (payment.gatewayRef != null && payment.gatewayRef!.isNotEmpty)
                Expanded(
                  child: Text(
                    "Ref: ${payment.gatewayRef}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              if (dateStr.isNotEmpty)
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
