import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class RowReviewProgressBar extends StatelessWidget {
  final RowReviewProgressBarModel rowReviewProgressBarModel;
  const RowReviewProgressBar({
    super.key,
    required this.rowReviewProgressBarModel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 45,
              child: Text(
                rowReviewProgressBarModel.titile,
                style: Helper(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: greyText2,
                    ),
              ),
            ),
            sizedBoxWidth(width: 26),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: rowReviewProgressBarModel.progressPer / 100,
                  minHeight: 10,
                  backgroundColor: greyLight3,
                  valueColor: AlwaysStoppedAnimation(
                    rowReviewProgressBarModel.progressBarColor,
                  ),
                ),
              ),
            ),
            sizedBoxWidth(width: 26),
            Text(
              "${rowReviewProgressBarModel.progressPer}%",
              style: Helper(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: rowReviewProgressBarModel.progressBarColor,
                  ),
            ),
          ],
        ));
  }
}

class RowReviewProgressBarModel {
  final String titile;
  final double progressPer;
  final Color progressBarColor;

  RowReviewProgressBarModel(
      {required this.titile,
      required this.progressPer,
      required this.progressBarColor});
}

List<RowReviewProgressBarModel> rowReviewProgressBarModelList = [
  RowReviewProgressBarModel(
    titile: "5 Star",
    progressPer: 88,
    progressBarColor: greenDark,
  ),
  RowReviewProgressBarModel(
    titile: "4 Star",
    progressPer: 9,
    progressBarColor: primaryText1,
  ),
  RowReviewProgressBarModel(
    titile: "3 Star",
    progressPer: 2,
    progressBarColor: greyLight4,
  ),
  RowReviewProgressBarModel(
    titile: "3 Star",
    progressPer: 1,
    progressBarColor: greyLight4,
  ),
  RowReviewProgressBarModel(
    titile: "1 Star",
    progressPer: 0.5,
    progressBarColor: red,
  ),
];
