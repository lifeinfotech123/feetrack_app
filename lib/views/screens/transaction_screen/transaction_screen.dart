import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/transaction_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/transaction_screen/widget/transaction_filter_section/transaction_filter_button.dart';
import 'package:vlr/views/screens/transaction_screen/widget/transaction_top_section.dart';
import 'package:vlr/views/screens/transaction_screen/widget/transaction_widget.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<TransactionController>().fetchRecentTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(builder: (transactionController) {
      return Scaffold(
        appBar: AppBar(
          shadowColor: black.withValues(alpha: 0.05),
          title: Text(
            "Transactions",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryText1,
                  letterSpacing: 1.4,
                ),
          ),
          actions: [const TransactionFilterButton(), sizedBoxWidth(width: 16)],
        ),
        body: transactionController.isTransactionLoading
            ? const Center(child: CircularProgressIndicator())
            : transactionController.transactionList.isEmpty
                ? Center(
                    child: Text(
                      "No Transactions Found",
                      style: Helper(context).textTheme.bodyMedium,
                    ),
                  )
                : SingleChildScrollView(
                    padding: AppConstants.screenPadding,
                    child: Column(
                      children: [
                        TransactionTopRow(
                            count: transactionController.transactionList.length),
                        sizedBoxHeight(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  width: 1,
                                  color: const Color(0xFFC3C6D11A)
                                      .withValues(alpha: 0.10))),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return TransactionWidget(
                                transaction:
                                    transactionController.transactionList[index],
                              );
                            },
                            separatorBuilder: (_, __) =>
                                sizedBoxHeight(height: 16),
                            itemCount:
                                transactionController.transactionList.length,
                          ),
                        )
                      ],
                    ),
                  ),
      );
    });
  }
}
