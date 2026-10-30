import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/wallet_controller.dart';
import 'wallet_screen.dart';

class WalletTransactionReserveTabbarScreen extends StatefulWidget {
  const WalletTransactionReserveTabbarScreen({super.key});

  @override
  State<WalletTransactionReserveTabbarScreen> createState() =>
      _WalletTransactionReserveTabbarScreenState();
}

class _WalletTransactionReserveTabbarScreenState
    extends State<WalletTransactionReserveTabbarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<WalletController>();
      controller.fetchWalletBalance();
      controller.fetchMyTransactions();
    });
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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Get.back();
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
        ),
        title: const Text(
          "Wallet",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: const WalletScreen(),
    );
  }
}
