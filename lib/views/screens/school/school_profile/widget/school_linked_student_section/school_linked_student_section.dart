import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/school/new_student_profile/new_student_profile_screen.dart';
import 'package:vlr/views/screens/school/school_profile/widget/school_linked_student_section/student_profile_widget.dart';

class SchoolLinkedStudentSection extends StatelessWidget {
  const SchoolLinkedStudentSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Linked Students",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 20,
                      color: blackText1,
                    ),
              ),
              Text(
                " 2 Enrolled",
                style: Helper(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      color: blueLight3,
                    ),
              ),
            ],
          ),
          sizedBoxHeight(height: 24),
          ListView.separated(
            itemBuilder: (context, index) {
              return GestureDetector(
                  onTap: () {
                    navigate(
                        context: context, page: const NewStudentProfileScreen());
                  },
                  child: const StudentProfileWidget());
            },
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
              child: Divider(
                color: greyLight6,
              ),
            ),
            itemCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
          )
          //
        ],
      ),
    );
  }
}
