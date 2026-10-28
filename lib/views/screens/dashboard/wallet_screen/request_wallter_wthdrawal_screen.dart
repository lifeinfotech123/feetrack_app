import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/wallet_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';

import '../../../../data/models/response/response_model.dart';

class RequestWallterWthdrawalScreen extends GetView<WalletController> {
  const RequestWallterWthdrawalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      return Scaffold(
        backgroundColor: transactionDetailsBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Request Withdrawal",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: transactionDetailsPrimary,
                ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: transactionDetailsPrimary,
              size: 20,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, "Withdrawal Amount"),
              sizedBoxHeight(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: greyLight4.withValues(alpha: 0.5)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      "₹",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: transactionDetailsPrimary,
                          ),
                    ),
                    sizedBoxWidth(width: 12),
                    Expanded(
                      child: TextField(
                        controller: walletController.withdrawalAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: transactionDetailsPrimary,
                            ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          hintText: "0.00",
                          hintStyle: TextStyle(color: greyText3, fontSize: 20),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              sizedBoxHeight(height: 24),
              _buildSectionTitle(context, "Payment Method (e.g. UPI ID)"),
              sizedBoxHeight(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: greyLight4.withValues(alpha: 0.5)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller:
                      walletController.withdrawalPaymentMethodController,
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: transactionDetailsPrimary,
                      ),
                  decoration: InputDecoration(
                    hintText: "Enter UPI ID or Bank Details",
                    hintStyle: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: greyText3,
                        ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              sizedBoxHeight(height: 24),
              _buildSectionTitle(context, "Notes (Optional)"),
              sizedBoxHeight(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: greyLight4.withValues(alpha: 0.5)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: walletController.withdrawalNotesController,
                  maxLines: 3,
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: transactionDetailsPrimary,
                      ),
                  decoration: InputDecoration(
                    hintText: "Reason for withdrawal...",
                    hintStyle: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: greyText3,
                        ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              sizedBoxHeight(height: 40),
              CustomButton(
                height: 56,
                radius: 100,
                isLoading: walletController.isLoading,
                color: const Color(0xFF002060),
                borderColor: const Color(0xFF002060),
                onTap: () async {
                  final amount = double.tryParse(
                          walletController.withdrawalAmountController.text) ??
                      0;
                  if (amount <= 0) {
                    showToast(
                        message: "Please enter a valid amount",
                        toastType: ToastType.warning);
                    return;
                  }
                  if (walletController
                      .withdrawalPaymentMethodController.text.isEmpty) {
                    showToast(
                        message: "Please enter payment method",
                        toastType: ToastType.warning);
                    return;
                  }

                  ResponseModel response =
                      await walletController.requestWithdrawal();

                  if (response.isSuccess) {
                    showToast(
                        message: response.message,
                        toastType: ToastType.success);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } else {
                    showToast(
                        message: response.message, toastType: ToastType.error);
                  }
                },
                child: Center(
                  child: Text(
                    "Submit Request",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: white,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Helper(context).textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: primaryText1,
          ),
    );
  }
}
