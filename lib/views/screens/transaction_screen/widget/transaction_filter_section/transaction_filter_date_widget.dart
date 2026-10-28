import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/transaction_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/date_formatters_and_converters.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';

class TransactionFilterDateWidget extends StatelessWidget {
  final String title;
  final bool isFromDate;

  const TransactionFilterDateWidget({
    super.key,
    required this.title,
    required this.isFromDate,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(
      builder: (transactionController) {
        final DateTime selectedDate = isFromDate
            ? (transactionController.fromDate ?? getDateTime())
            : (transactionController.toDate ?? getDateTime());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: greyText3,
                    letterSpacing: 0.55,
                  ),
            ),

            sizedBoxHeight(height: 9),

            CustomButton(
              onTap: () async {
                FocusScope.of(context).unfocus();

                final DateTime? picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  initialDate: selectedDate,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: primaryColor,
                          onPrimary: Colors.white,
                          onSurface: black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  if (isFromDate) {
                    transactionController.fromDate = picked;
                  } else {
                    transactionController.toDate = picked;
                  }

                  transactionController.update();
                }
              },
              color: greyLight,
              height: 54,
              radius: 16,
              borderColor: white,
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: primaryText1,
                  ),

                  sizedBoxWidth(width: 12),

                  Expanded(
                    child: Text(
                      DateFormatters()
                          .dMyDash
                          .format(selectedDate),
                      overflow: TextOverflow.ellipsis,
                      style:
                          Helper(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: blackText1,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}