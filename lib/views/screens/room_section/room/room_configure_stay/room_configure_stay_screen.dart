import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/room_section/room/room_booking/room_booking_screen.dart';
import 'package:vlr/views/screens/room_section/room/room_configure_stay/widget/room_add_on_services_section.dart';
import 'package:vlr/views/screens/room_section/room/room_configure_stay/widget/configure_stay_top_section.dart';
import 'package:vlr/views/screens/room_section/widget/room_bottom_action_button.dart';

class RoomConfigureStayScreen extends StatelessWidget {
  const RoomConfigureStayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Configure Stay",
          style: Helper(context).textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: blackText3,
              ),
        ),
      ),
      bottomNavigationBar: RoomBottomActionButton(
        title: "Continue to Booking",
        onTap: () {
          navigate(context: context, page: const RoomBookingScreen());
        },
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            const ConfigureStayTopSection(),
            sizedBoxHeight(height: 32),
            const RoomAddServiceSection()
          ],
        ),
      ),
    );
  }
}
