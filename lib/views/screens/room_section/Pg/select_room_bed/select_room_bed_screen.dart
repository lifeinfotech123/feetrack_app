import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/room_section/Pg/select_room_bed/widget/select_pg_room_section.dart';
import 'package:vlr/views/screens/room_section/Pg/select_room_bed/widget/select_room_bed_heading.dart';
import 'package:vlr/views/screens/room_section/Pg/select_room_bed/widget/select_room_bed_section.dart';
import 'package:vlr/views/screens/room_section/term_and_condition/term_and_condition_screen.dart';
import 'package:vlr/views/screens/room_section/widget/room_bottom_action_button.dart';

class SelectRoomAndBedScreen extends StatelessWidget {
  const SelectRoomAndBedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Select Room and Bed",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: blackText3,
              ),
        ),
      ),
      bottomNavigationBar: RoomBottomActionButton(
        title: "Confirm Selection",
        onTap: () {
          navigate(context: context, page: const TermAndConditionScreen());
        },
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SelectPgRoom(),
            sizedBoxHeight(height: 32),
            const SelectRoomBedHeading(),
            sizedBoxHeight(height: 16),
            const SelectRoomBedSection(
              isAvailable: true,
            ),
            sizedBoxHeight(height: 32),
            Stack(
              children: [
                CustomImage(
                  path: Assets.imagesPgRoomSharing,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height / 4,
                  radius: 18,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      "Room 301 actual photograph",
                      style: Helper(context).textTheme.labelLarge?.copyWith(
                            fontSize: 16,
                            color: white,
                          ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
