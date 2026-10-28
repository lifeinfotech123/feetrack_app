import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class FeeRowOfWidget extends StatelessWidget {
  const FeeRowOfWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total Fee",
            style: Helper(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: greyDart2,
                ),
          ),
          Text(
            "₹60,000",
            style: Helper(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  color: blackText1,
                ),
          ),
        ],
      ),
    );
  }
}

class FeeRowOfWidgetModel {
  final String title;
  final String subTitle;
  final Color color;

  FeeRowOfWidgetModel(
      {required this.title, required this.subTitle, required this.color});
}

List<FeeRowOfWidgetModel> feeRowOfWidgetModelList = [
  FeeRowOfWidgetModel(title: "Total Fee", subTitle: "₹60,000", color: black),
  FeeRowOfWidgetModel(title: "Fee Paid", subTitle: "₹42,500", color: greenDark),
  FeeRowOfWidgetModel(
      title: "Remaining Fee", subTitle: "₹17,500", color: black),
  FeeRowOfWidgetModel(title: "Due Fee", subTitle: "₹8,750", color: redDark),
];
