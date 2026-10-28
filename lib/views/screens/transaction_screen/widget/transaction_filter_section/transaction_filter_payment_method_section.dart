import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:vlr/controllers/transaction_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/transaction_screen/widget/transaction_filter_section/tran_payment_type_widget.dart';

class TransactionFilterPaymentMethodSection extends StatelessWidget {
  const TransactionFilterPaymentMethodSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(builder: (transactionController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizedBoxHeight(height: 31),
          Text(
            "PAYMENT METHOD",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: greyText3,
                  letterSpacing: 0.55,
                ),
          ),
          sizedBoxHeight(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              transactionController.transPaymentTypeList.length,
              (index) {
                final paymentType =
                    transactionController.transPaymentTypeList[index];

                return GestureDetector(
                  onTap: () {
                    transactionController.selectTransFilterPaymentTypeModel =
                        paymentType;
                    transactionController.update();
                  },
                  child: TranPaymentTypeWidget(
                    transFilterPaymentTypeModel: paymentType,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
