import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class TapSectionSchoolHomeScreen extends StatelessWidget {
  const TapSectionSchoolHomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: blueLight3,
            ),
            sizedBoxWidth(width: 20),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Koramangala",
                  style: Helper(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        color: blueLight3,
                      ),
                ),
                sizedBoxWidth(width: 2),
                Text(
                  "BENGALURU, INDIA BENGALURU, INDIABENGALURU, INDIABENGALURU, INDIABENGALURU, INDIABENGALURU, INDIABENGALURU, INDIABENGALURU, INDIABENGALURU, INDIA",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Helper(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 10,
                        color: greyDart2,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ))
          ],
        )
      ],
    );
  }
}
