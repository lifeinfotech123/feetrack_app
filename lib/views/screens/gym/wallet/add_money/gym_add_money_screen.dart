import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../../controllers/wallet_controller.dart';
import '../../../../../data/models/response/response_model.dart';
import '../../../../../services/constants.dart';

class GymAddMoneyScreen extends StatefulWidget {
  const GymAddMoneyScreen({super.key});

  @override
  State<GymAddMoneyScreen> createState() => _GymAddMoneyScreenState();
}

class _GymAddMoneyScreenState extends State<GymAddMoneyScreen> {
  late Razorpay _razorpay;
  final WalletController walletController = Get.find<WalletController>();
  final TextEditingController amountController =
      TextEditingController(text: "500");

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
    amountController.dispose();
    super.dispose();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay external wallet: ${response.walletName}');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showToast(
        message: response.message ?? 'Payment cancelled or failed',
        toastType: ToastType.error);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;
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
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;
    if (amount <= 0) {
      showToast(
          message: "Please enter a valid amount", toastType: ToastType.warning);
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
      'prefill': {'contact': contact, 'email': email},
      'theme': {'color': '#002060'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      showToast(
          message: "Unable to open payment gateway",
          toastType: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
        ),
        title: const Text(
          "Add Money",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enter Amount",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A3B5D)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002060)),
                    decoration: InputDecoration(
                      prefixText: "₹ ",
                      prefixStyle: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF002060)),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FE),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openRazorpay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002060),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
