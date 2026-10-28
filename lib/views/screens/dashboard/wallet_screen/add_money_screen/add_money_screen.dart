import 'package:flutter/material.dart' hide BottomNavigationBar;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vlr/controllers/wallet_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/dashboard/wallet_screen/add_money_screen/widget/add_money_amount_preset_card.dart';

import '../../../../../data/models/response/response_model.dart';
import '../../../../base/common_button.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  late Razorpay _razorpay;
  final WalletController walletController = Get.find<WalletController>();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay external wallet: ${response.walletName}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showToast(
        message: response.message ?? 'Payment cancelled or failed',
        toastType: ToastType.error);
    if (mounted) setState(() {});
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final amount = walletController.addMoneyAmount.value;
    if (amount <= 0) {
      showToast(message: "Invalid amount", toastType: ToastType.error);
      return;
    }

    ResponseModel res = await walletController.rechargeMyWallet(
      amount,
      paymentId: response.paymentId,
    );

    if (res.isSuccess) {
      showToast(message: res.message, toastType: ToastType.success);
      walletController.fetchWalletBalance();
      walletController.fetchMyTransactions();
      if (mounted) {
        Get.back();
      }
    } else {
      showToast(message: res.message, toastType: ToastType.error);
    }
  }

  void _openRazorpay() {
    final amount = walletController.addMoneyAmount.value;
    if (amount <= 0) {
      showToast(message: "Please enter a valid amount", toastType: ToastType.warning);
      return;
    }

    final double amountInPaise = amount * 100;
    String contact = '';
    String email = '';
    try {
      final auth = Get.find<dynamic>();
      contact = auth.userModel?.mobile?.toString() ?? '';
      email = auth.userModel?.email?.toString() ?? '';
    } catch (_) {}

    final options = {
      'key': 'rzp_test_TWIAoYszpcVthe',
      'amount': amountInPaise.toInt(),
      'name': 'FeeTrack',
      'description': 'Wallet Recharge',
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'theme': {'color': '#002060'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      showToast(message: "Unable to open payment gateway", toastType: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompact = MediaQuery.sizeOf(context).width < 360;

    return GetBuilder<WalletController>(builder: (walletController) {
      return Scaffold(
        backgroundColor: transactionDetailsBackground,
        appBar: AppBar(
          shadowColor: black.withValues(alpha: 0.05),
          centerTitle: true,
          title: Text(
            "Add Money",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: transactionDetailsPrimary,
                ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.notifications_none_rounded,
                color: transactionDetailsPrimary,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: CustomImage(
                path: Assets.imagesReview1,
                width: 36,
                height: 36,
                fit: BoxFit.cover,
                radius: 999,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            children: [
              sizedBoxHeight(height: 8),
              Text(
                "Enter Amount",
                textAlign: TextAlign.center,
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: greyText3,
                    ),
              ),
              sizedBoxHeight(height: 16),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "₹",
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: isCompact ? 38 : 44,
                            fontWeight: FontWeight.w800,
                            color: transactionDetailsPrimary,
                          ),
                    ),
                    sizedBoxWidth(width: 10),
                    Expanded(
                      child: TextField(
                        controller: walletController.addMoneyAmountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        onChanged: walletController.updateAddMoneyAmount,
                        style: Helper(context).textTheme.bodyMedium?.copyWith(
                              fontSize: isCompact ? 42 : 48,
                              fontWeight: FontWeight.w800,
                              color: transactionDetailsPrimary,
                            ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              sizedBoxHeight(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  walletController.presetAmounts.length,
                  (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right:
                              index == walletController.presetAmounts.length - 1
                                  ? 0
                                  : 12,
                        ),
                        child: AddMoneyAmountPresetCard(
                          title:
                              "+ ₹${walletController.presetAmounts[index].toStringAsFixed(0)}",
                          isSelected:
                              walletController.selectedPresetIndex.value ==
                                  index,
                          onTap: () {
                            walletController.selectPresetAmount(index);
                            walletController.update();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              sizedBoxHeight(height: 12),

              CustomButton(
                height: 54,
                radius: 100,
                isLoading: false,
                color: const Color(0xFF002060),
                borderColor: const Color(0xFF002060),
                onTap: _openRazorpay,
                child: Center(
                  child: Text(
                    "Proceed to Add Money",
                    style: Helper(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: white,
                        ),
                  ),
                ),
              ),

              sizedBoxHeight(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: greyText3,
                  ),
                  sizedBoxWidth(width: 8),
                  Expanded(
                    child: Text(
                      "SECURE 256-BIT ENCRYPTED PAYMENT",
                      textAlign: TextAlign.center,
                      style: Helper(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: greyText3,
                          ),
                    ),
                  ),
                ],
              ),
              sizedBoxHeight(height: 24),
            ],
          ),
        ),
      );
    });
  }
}




