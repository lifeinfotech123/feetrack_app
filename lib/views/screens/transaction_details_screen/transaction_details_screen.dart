import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/dashboard_controller.dart';
import 'package:vlr/controllers/transaction_controller.dart';
import 'package:vlr/data/models/transaction_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/dashboard_screen.dart';
import 'package:vlr/views/screens/transaction_details_screen/widget/transaction_detail_card.dart';
import 'package:vlr/views/screens/transaction_details_screen/widget/transaction_detail_info_row.dart';

class TransactionDetailsScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<TransactionController>().fetchTransactionDetails(widget.transaction.transactionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey receiptBoundaryKey = GlobalKey();

    return GetBuilder<TransactionController>(
      builder: (transactionController) {
        final transaction = transactionController.selectedTransaction ?? widget.transaction;
        final bool isSuccess = transaction.status.toLowerCase() == 'paid' || transaction.status.toLowerCase() == 'success';

        return RepaintBoundary(
          key: receiptBoundaryKey,
          child: Scaffold(
            backgroundColor: transactionDetailsBackground,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Transaction Details",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: transactionDetailsPrimary,
                    ),
              ),
              actions: [
                IconButton(
                  onPressed: () async {
                    await transactionController.downloadPDF(
                      type: "payment",
                      id: transaction.transactionId,
                      fileName: "Receipt_${transaction.transactionId}",
                    );
                  },
                  icon: Icon(
                    Icons.file_download_outlined,
                    color: transactionDetailsPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await transactionController.shareTransactionScreenshot(
                      boundaryKey: receiptBoundaryKey,
                      transaction: transaction,
                    );
                  },
                  icon: Icon(
                    Icons.ios_share_rounded,
                    color: transactionDetailsPrimary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: transactionController.isDetailLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12001A3F),
                                blurRadius: 30,
                                offset: Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSuccess 
                                      ? transactionDetailsAccent.withValues(alpha: 0.22)
                                      : Colors.red.withValues(alpha: 0.1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSuccess ? const Color(0x454DFFD3) : Colors.red.withValues(alpha: 0.1),
                                      blurRadius: 28,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isSuccess ? Icons.check_rounded : Icons.close_rounded,
                                  size: 44,
                                  color: isSuccess ? transactionSuccessText : Colors.red,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                isSuccess ? "PAYMENT SUCCESSFUL" : "PAYMENT ${transaction.status.toUpperCase()}",
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: transactionDetailsPrimary,
                                          letterSpacing: 0.8,
                                        ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                PriceConverter.convertToNumberFormat(
                                    transaction.amount),
                                style:
                                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 34,
                                          fontWeight: FontWeight.w800,
                                          color: transactionDetailsPrimary,
                                        ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                transaction.title,
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF7B8798),
                                        ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        TransactionDetailCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: TransactionDetailInfoRow(
                                  label: "DATE & TIME",
                                  value: DateFormat("dd MMM yyyy, hh:mm a")
                                      .format(transaction.dateTime),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: TransactionDetailInfoRow(
                                  label: "TRANSACTION ID",
                                  value: transaction.transactionId,
                                  trailing: InkWell(
                                    onTap: () {
                                      transactionController.copyTransactionId(
                                        transaction.transactionId,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: transactionDetailsPrimary.withValues(
                                          alpha: 0.06,
                                        ),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.copy_rounded,
                                        size: 18,
                                        color: transactionDetailsPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (transaction.invoice != null) ...[
                          TransactionDetailCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "INVOICE DETAILS",
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF7B8798),
                                          ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        if (transaction.invoice?.id != null) {
                                          transactionController.downloadPDF(
                                            type: "invoice",
                                            id: transaction.invoice!.id!,
                                            fileName: "Invoice_${transaction.invoice!.invoiceNumber ?? "No"}",
                                          );
                                        } else {
                                          showToast(message: "Invoice ID not available");
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: transactionDetailsPrimary.withValues(alpha: 0.06),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.file_download_outlined,
                                          size: 20,
                                          color: transactionDetailsPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TransactionDetailInfoRow(
                                  label: "INVOICE NO",
                                  value: transaction.invoice?.invoiceNumber ?? "N/A",
                                ),
                                const SizedBox(height: 12),
                                TransactionDetailInfoRow(
                                  label: "SUBTOTAL",
                                  value: PriceConverter.convertToNumberFormat(
                                      transaction.invoice?.amount ?? 0.0),
                                ),
                                const SizedBox(height: 12),
                                TransactionDetailInfoRow(
                                  label: "TAX",
                                  value: PriceConverter.convertToNumberFormat(
                                      transaction.invoice?.tax ?? 0.0),
                                ),
                                const SizedBox(height: 12),
                                TransactionDetailInfoRow(
                                  label: "TOTAL AMOUNT",
                                  value: PriceConverter.convertToNumberFormat(
                                      transaction.invoice?.total ?? 0.0),
                                  valueColor: transactionDetailsPrimary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        if (transaction.listing != null) ...[
                          TransactionDetailCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "LISTING INFORMATION",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF7B8798),
                                      ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  transaction.listing?.title ?? "N/A",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: transactionDetailsPrimary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_on_outlined,
                                        size: 16, color: greyText3),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${transaction.listing?.address ?? ""}, ${transaction.listing?.landmark ?? ""}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: greyText3,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                        TransactionDetailCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: transactionDetailsPrimary.withValues(
                                        alpha: 0.06,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      transaction.paymentMode.toLowerCase() == "card"
                                          ? Icons.credit_card_rounded
                                          : transaction.paymentMode.toLowerCase() == "cash"
                                              ? Icons.payments_rounded
                                              : Icons.account_balance_rounded,
                                      color: transactionDetailsPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Payment Gateway",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF7B8798),
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          transaction.paymentMode.toUpperCase(),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: transactionDetailsPrimary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSuccess 
                                          ? transactionDetailsAccent.withValues(alpha: 0.2)
                                          : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      transaction.status.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isSuccess ? transactionSuccessText : Colors.red,
                                            letterSpacing: 0.6,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      transaction.recipient,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: transactionDetailsPrimary,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (isSuccess)
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE9FFF7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.verified_rounded,
                                        color: transactionSuccessText,
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TransactionDetailInfoRow(
                                label: "GATEWAY REF",
                                value: transaction.gatewayId,
                              ),
                              if (transaction.plan != null) ...[
                                const SizedBox(height: 18),
                                const Divider(height: 32, thickness: 1, color: Color(0xFFF1F5F9)),
                                Text(
                                  "PLAN DETAILS",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF7B8798),
                                      ),
                                ),
                                const SizedBox(height: 16),
                                TransactionDetailInfoRow(
                                  label: "PLAN NAME",
                                  value: transaction.plan?.name ?? "N/A",
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TransactionDetailInfoRow(
                                        label: "DURATION",
                                        value: "${transaction.plan?.durationDays ?? "0"} Days",
                                      ),
                                    ),
                                    const SizedBox(width: 18),
                                    Expanded(
                                      child: TransactionDetailInfoRow(
                                        label: "OCCUPANCY",
                                        value: capitalize(transaction.plan?.occupancyType?.replaceAll('_', ' ') ?? "N/A"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        GetBuilder<DashBoardController>(
                            builder: (dashBoardController) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: transactionDetailsPrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () async {
                                dashBoardController.dashPage = 0;
                                navigate(
                                    context: context, page: const DashboardScreen());
                              },
                              label: Text(
                                "Back to home",
                                style:
                                    Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
