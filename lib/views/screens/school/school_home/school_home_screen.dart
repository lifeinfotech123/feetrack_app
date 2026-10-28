import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/common_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/widget/home_banner_section.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/room_home/widget/room_home_search_section.dart';
import 'package:vlr/views/screens/dashboard/home_screen/service_appbar/service_appbar.dart';
import 'package:vlr/views/screens/search/search_all_screen.dart';
import 'package:vlr/views/screens/school/school_home/widget/school_profile_widget.dart';
import 'package:vlr/views/screens/school/school_home/widget/top_section_school.dart';
import 'package:vlr/views/screens/school/school_profile/school_profile_screen.dart';
import 'package:vlr/views/widget/nearby_row_section.dart/nearby_row_section.dart';

class SchoolHomeScreen extends StatelessWidget {
  const SchoolHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ServiceAppbar(
        title: "Hi, Alex Johnson",
        isAllServiceHomeScreen: false,
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            // const SizedBox(height: 16),
            const TapSectionSchoolHomeScreen(),
            const SizedBox(height: 12),
            const HomeBanner(),
            const SizedBox(height: 32),
            GetBuilder<CommonController>(builder: (commonController) {
              return RoomHomeSearchBar(
                  hindText:
                      "Search by ${capitalize(commonController.currentSelectService.name)}...",
                  onTap: () {
                    commonController.updateSelectedServiceType(
                        value: SelectTypeService.school);
                    navigate(context: context, page: const SearchAllScreen());
                  });
            }),
            const SizedBox(height: 32),
            const NearByRowSection(),
            const SizedBox(height: 16),

            SizedBox(
              height: 400,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      navigate(
                          context: context, page: const SchoolProfileScreen());
                    },
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width - 32,
                        child: const SchoolProfileWIdget()),
                  );
                },
                separatorBuilder: (_, __) => sizedBoxWidth(width: 16),
                itemCount: 10,
                shrinkWrap: true,
              ),
            )

            //
          ],
        ),
      ),
    );
  }
}
