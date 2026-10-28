import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:get/get.dart';
import 'package:vlr/controllers/dashboard_controller.dart';
import 'package:vlr/controllers/wallet_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/dashboard/dashboard_screen.dart';
import 'package:vlr/views/screens/transaction_details_screen/widget/transaction_detail_card.dart';
import 'package:vlr/views/screens/transaction_details_screen/widget/transaction_detail_info_row.dart';

import '../../../base/custom_image.dart';

class AddMoneyToWalletTransactionStatusScreen extends GetView<WalletController> {
  const AddMoneyToWalletTransactionStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      final transaction = walletController.currentWalletTransactionStatus;
      final bool isFailed = transaction.status == "FAILED";
      final bool isSuccess = transaction.status == "SUCCESS";

      final Color badgeBackgroundColor = isFailed
          ? redLight
          : isSuccess
              ? transactionSuccessBackground
              : transactionPendingBackground;
      final Color badgeTextColor = isFailed
          ? red1
          : isSuccess
              ? transactionSuccessText
              : transactionPendingText;
      final Color heroBackgroundColor = isFailed
          ? redLight
          : isSuccess
              ? transactionSuccessBackground
              : transactionPendingBackground;
      final Color heroGlowColor = isFailed
          ? red1.withValues(alpha: 0.18)
          : isSuccess
              ? transactionSuccessText.withValues(alpha: 0.16)
              : transactionPendingAccent.withValues(alpha: 0.18);
      final Color heroIconColor = isFailed
          ? red1
          : isSuccess
              ? transactionSuccessText
              : transactionPendingAccent;
      final IconData heroIcon = isFailed
          ? Icons.close_rounded
          : isSuccess
              ? Icons.check_rounded
              : Icons.schedule_rounded;
      final String heroTitle = isFailed
          ? "PAYMENT FAILED"
          : isSuccess
              ? "PAYMENT SUCCESSFUL"
              : "PAYMENT PENDING";
      final String reassuranceText = isFailed
          ? "Don't worry, no money was deducted from your account."
          : isSuccess
              ? "Your wallet has been updated successfully."
              : "Your payment is being processed. Please wait a moment.";
      final String primaryButtonTitle = isFailed
          ? "Try Again"
          : "Payment Done";

      return Scaffold(
        backgroundColor: transactionDetailsBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            "Transaction Details",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: transactionDetailsPrimary,
                ),
          ),
          leading: IconButton(
            onPressed: () {
              pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: transactionDetailsPrimary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: walletController.shareWalletTransactionStatus,
              icon: Icon(
                Icons.ios_share_rounded,
                color: transactionDetailsPrimary,
              ),
            ),
            sizedBoxWidth(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  color: white,
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
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: heroBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: heroGlowColor,
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        heroIcon,
                        size: 46,
                        color: heroIconColor,
                      ),
                    ),
                    sizedBoxHeight(height: 18),
                    Text(
                      heroTitle,
                      textAlign: TextAlign.center,
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: transactionDetailsPrimary,
                          ),
                    ),
                    sizedBoxHeight(height: 10),
                    Text(
                      "₹${transaction.amount.toStringAsFixed(2)}",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: transactionDetailsPrimary,
                          ),
                    ),
                    sizedBoxHeight(height: 8),
                    Text(
                      transaction.subtitle,
                      textAlign: TextAlign.center,
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: greyText3,
                          ),
                    ),
                    if (walletController.qrCodeUrl != null) ...[
                      sizedBoxHeight(height: 24),
                      Text(
                        "Scan QR to Complete Payment",
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: transactionDetailsPrimary,
                            ),
                      ),
                      sizedBoxHeight(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: greyLight4.withValues(alpha: 0.5),
                          ),
                        ),
                        child: CustomImage(
                          path: walletController.qrCodeUrl!,
                          width: 160,
                          height: 160,
                        ),
                      ),
                      if (walletController.adminUpiId != null) ...[
                        sizedBoxHeight(height: 12),
                        Text(
                          "UPI ID: ${walletController.adminUpiId}",
                          style: Helper(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: greyText3,
                              ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              sizedBoxHeight(height: 20),
              TransactionDetailCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "STATUS",
                          style: Helper(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: greyText3,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBackgroundColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            transaction.status,
                            style:
                                Helper(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: badgeTextColor,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Divider(
                        height: 1,
                        color: greyLight4.withValues(alpha: 0.35),
                      ),
                    ),
                    TransactionDetailInfoRow(
                      label: "RECIPIENT",
                      value: transaction.recipient,
                    ),
                    sizedBoxHeight(height: 18),
                    TransactionDetailInfoRow(
                      label: "TRANSACTION ID",
                      value: transaction.transactionId,
                    ),
                    sizedBoxHeight(height: 18),
                    TransactionDetailInfoRow(
                      label: "PAYMENT METHOD",
                      value: transaction.paymentMode,
                    ),
                  ],
                ),
              ),
              sizedBoxHeight(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onTap: () {
                    if (isFailed) {
                      walletController.tryAddMoneyAgain(context);
                    } else {
                      Get.find<DashBoardController>().dashPage = 0;
                      navigate(
                        context: context,
                        page: const DashboardScreen(),
                        isRemoveUntil: true,
                      );
                    }
                  },
                  height: 58,
                  radius: 999,
                  color: transactionDetailsPrimary,
                  borderColor: transactionDetailsPrimary,
                  child: Center(
                    child: Text(
                      primaryButtonTitle,
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: white,
                          ),
                    ),
                  ),
                ),
              ),
              CustomButton(
                onTap: () {
                  Get.find<DashBoardController>().dashPage = 0;
                  navigate(
                    context: context,
                    page: const DashboardScreen(),
                    isRemoveUntil: true,
                  );
                },
                type: ButtonType.tertiary,
                child: Text(
                  "Back to Home",
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: transactionDetailsPrimary,
                      ),
                ),
              ),
              Text(
                reassuranceText,
                textAlign: TextAlign.center,
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: greyText3,
                    ),
              ),
              sizedBoxHeight(height: 20),
            ],
          ),
        ),
      );
    });
  }
}
