import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:vlr/controllers/transaction_controller.dart';
import 'package:vlr/data/models/trans_filter_payment_type_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class TranPaymentTypeWidget extends StatelessWidget {
  final TransFilterPaymentTypeModel transFilterPaymentTypeModel;

  const TranPaymentTypeWidget({
    super.key,
    required this.transFilterPaymentTypeModel,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(builder: (transactionController) {
      final bool isSelected =
          transactionController.selectTransFilterPaymentTypeModel?.id ==
              transFilterPaymentTypeModel.id;
      final Color backgroundColor = isSelected ? primaryText1 : greyLight3;
      final Color textColor = isSelected ? white : greyText2;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          transFilterPaymentTypeModel.paymentType ?? "",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: textColor,
              ),
        ),
      );
    });
  }
}
