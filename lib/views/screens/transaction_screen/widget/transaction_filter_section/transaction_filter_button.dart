import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:vlr/controllers/transaction_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';
import 'package:vlr/views/screens/transaction_screen/widget/transaction_filter_section/transaction_filter_date_widget.dart';
import 'package:vlr/views/screens/transaction_screen/widget/transaction_filter_section/transaction_filter_payment_method_section.dart';
import 'package:vlr/views/screens/transaction_screen/widget/transaction_filter_section/transaction_filter_tran_status_sectin.dart';

class TransactionFilterButton extends StatelessWidget {
  const TransactionFilterButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(builder: (transactionController) {
      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    sizedBoxHeight(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Filter Transactions",
                          style: Helper(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: blackText1,
                              ),
                        ),
                        CustomButton(
                          onTap: () {
                            transactionController.resetTransactionFilters();
                          },
                          type: ButtonType.tertiary,
                          child: Text(
                            "Clear All",
                            style:
                                Helper(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: primaryText1,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    sizedBoxHeight(height: 31),
                    Row(
                      children: [
                        const Expanded(
                          child: TransactionFilterDateWidget(
                            title: "FROM",
                            isFromDate: true,
                          ),
                        ),
                        sizedBoxWidth(width: 16),
                        const Expanded(
                          child: TransactionFilterDateWidget(
                            title: "TO",
                            isFromDate: false,
                          ),
                        )
                      ],
                    ),
                    const TransactionFilterTranStatusSection(),
                    const TransactionFilterPaymentMethodSection(),
                    sizedBoxHeight(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryText1,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        onPressed: () {
                          transactionController.fetchRecentTransactions();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Apply Filter",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    sizedBoxHeight(
                      height: MediaQuery.of(context).padding.bottom,
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            color: blueLight2.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(
                Icons.filter_list,
                color: primaryText1,
              ),
              sizedBoxWidth(width: 6),
              Text(
                "Filter",
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: primaryText1,
                    ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
