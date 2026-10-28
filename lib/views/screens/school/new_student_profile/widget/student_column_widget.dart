
import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class StudentColumnWidget extends StatelessWidget {
  const StudentColumnWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "GRADE",
          style: Helper(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 10,
                color: greyText5,
              ),
        ),
        Text(
          "2",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: blueLight3,
              ),
        ),
      ],
    );
  }
}
