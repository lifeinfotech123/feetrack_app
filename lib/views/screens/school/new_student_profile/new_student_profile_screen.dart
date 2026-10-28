import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/dashboard/home_screen/service_appbar/service_appbar.dart';
import 'package:vlr/views/screens/school/new_student_profile/widget/class_teacher_profile_section.dart';
import 'package:vlr/views/screens/school/new_student_profile/widget/fee_structure_section/fee_structure_section.dart';
import 'package:vlr/views/screens/school/new_student_profile/widget/top_section_student_screen.dart';

class NewStudentProfileScreen extends StatelessWidget {
  const NewStudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ServiceAppbar(
        title: "Student Profile",
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            TopSectionStudentScreen(),
            sizedBoxHeight(height: 24),
            ClassTeacherProfileSection(),
            sizedBoxHeight(height: 48),
            FeeStructureSection()
          ],
        ),
      ),
    );
  }
}
