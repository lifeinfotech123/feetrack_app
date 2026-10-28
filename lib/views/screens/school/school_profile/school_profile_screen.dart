import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/dashboard/home_screen/service_appbar/service_appbar.dart';
import 'package:vlr/views/screens/school/school_profile/widget/campus_amenities_school_section.dart';
import 'package:vlr/views/screens/school/school_profile/widget/school_about_section.dart';
import 'package:vlr/views/screens/school/school_profile/widget/school_gallery_section.dart';
import 'package:vlr/views/screens/school/school_profile/widget/school_info_section.dart';
import 'package:vlr/views/screens/school/school_profile/widget/school_linked_student_section/school_linked_student_section.dart';
import 'package:vlr/views/screens/school/school_profile/widget/top_section_school_profile.dart';

class SchoolProfileScreen extends StatelessWidget {
  const SchoolProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ServiceAppbar(
        title: "Second Home English Medium School",
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const TopSectionSchoolProfile(),
            sizedBoxHeight(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SchoolInfoSection(),
            ),
            const SchoolAboutSection(),
            sizedBoxHeight(height: 12),
            const CampusAmenitiesSchoolSection(),
            sizedBoxHeight(height: 12),
            const SchoolGallerySection(),
            sizedBoxHeight(height: 12),
            const SchoolLinkedStudentSection(),
            sizedBoxHeight(height: 20),
          ],
        ),
      ),
    );
  }
}
