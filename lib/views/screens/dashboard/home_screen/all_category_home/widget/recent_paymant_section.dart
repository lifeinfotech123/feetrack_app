import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:vlr/controllers/transaction_controller.dart';
import 'package:vlr/controllers/wallet_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/transaction_screen/transaction_screen.dart';
import 'package:vlr/views/screens/transaction_screen/widget/transaction_widget.dart';

class RecentPaymentSection extends StatelessWidget {
  const RecentPaymentSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (walletController) {
      return GetBuilder<TransactionController>(
          builder: (transactionController) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  width: 1,
                  color: const Color(0x1AC3C6D1).withValues(alpha: 0.10))),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Transactions",
                    style: Helper(context).textTheme.titleMedium?.copyWith(
                          fontSize: 16,
                          color: blackText1,
                        ),
                  ),
                  CustomButton(
                    onTap: () {
                      navigate(
                          context: context, page: const TransactionScreen());
                    },
                    type: ButtonType.tertiary,
                    child: Text(
                      "View history",
                      style: Helper(context).textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            color: primaryColor,
                          ),
                    ),
                  ),
                ],
              ),
              sizedBoxHeight(height: 14),
              transactionController.isTransactionLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transactionController.transactionList.isEmpty
                      ? const Center(child: Text("No transactions yet"))
                      : ListView.separated(
                          itemCount:
                              transactionController.transactionList.length > 3
                                  ? 3
                                  : transactionController.transactionList.length,
                          shrinkWrap: true,
                separatorBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    color: greyDart.withValues(alpha: 0.10),
                  ),
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return TransactionWidget(
                    transaction: transactionController.transactionList[index],
                  );
                },
              ),
            ],
          ),
        );
      });
    });
  }
}
