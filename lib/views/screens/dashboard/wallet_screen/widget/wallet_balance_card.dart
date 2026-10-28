import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:vlr/controllers/wallet_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/dashboard/wallet_screen/add_money_screen/add_money_screen.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [primaryColor, Color(0xFF1E3A8A)], // Modern blue gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative background circles
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Current Balance",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: white.withValues(alpha: 0.8),
                      ),
                    ),
                    Icon(Icons.account_balance_wallet_outlined, color: white.withValues(alpha: 0.8), size: 20),
                  ],
                ),
                sizedBoxHeight(height: 8),
                Text(
                  PriceConverter.convertToNumberFormat(walletController.walletBalance),
                  style:  TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: white,
                    letterSpacing: 0.5,
                  ),
                ),
                sizedBoxHeight(height: 24),
                Row(
                  children: [
                    _miniInfo(context, "Expenses", "0", Icons.arrow_downward_rounded),
                    const SizedBox(width: 24),
                    _miniInfo(context, "Income", "0", Icons.arrow_upward_rounded),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _miniInfo(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: white, size: 12),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: white.withValues(alpha: 0.6), fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style:  TextStyle(fontSize: 12, color: white, fontWeight: FontWeight.w700),
            ),
          ],
        )
      ],
    );
  }
}
