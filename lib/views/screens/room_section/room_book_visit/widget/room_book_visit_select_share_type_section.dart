import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/room_section/room_book_visit/widget/pd_visit_book_visit_widget.dart';

class RoomBookVisitSelectShareType extends StatelessWidget {
  const RoomBookVisitSelectShareType({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Sharing Type",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 20,
                color: blackText3,
              ),
        ),
        sizedBoxHeight(height: 16),
        SizedBox(
          height: 90,
          child: ListView.separated(
            itemBuilder: (context, index) {
              return PgVisitBookWidget(isSelect: true);
            },
            separatorBuilder: (_, __) => sizedBoxWidth(width: 12),
            itemCount: 5,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
          ),
        )

        // )
      ],
    );
  }
}
