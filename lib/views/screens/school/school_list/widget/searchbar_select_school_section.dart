// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:vlr/controllers/school_controller.dart';
// import 'package:vlr/services/constants.dart';
// import 'package:vlr/services/theme.dart';
// import 'package:vlr/views/screens/school/school_list/widget/school_widget_select_school.dart';
// import 'package:vlr/views/screens/school/school_student_login_screen/school_student_login_screen_screen.dart';
// import 'package:vlr/views/widget/text_box/app_text_box.dart';

// class SearchBarSectionSelectSchool extends StatelessWidget {
//   const SearchBarSectionSelectSchool({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<SchoolController>(
//       builder: (schoolController) {
//         return Column(
//           children: [
//             AppTextFieldWithHeading(
//               controller: schoolController.schoolSearchController,
//               hindText: "Search School...",
//               preFixWidget: Icon(
//                 Icons.search_sharp,
//                 color: grey,
//               ),
//             ),
//             sizedBoxHeight(height: 14),
//             Text(
//               "Select your educational institution to proceed with fee payments and academic tracking.",
//               style: Helper(context).textTheme.bodySmall?.copyWith(
//                     fontSize: 15,
//                     color: greyDart2,
//                   ),
//             ),
//             ListView.separated(
//               padding: const EdgeInsets.only(top: 32),
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                     onTap: () {
//                       navigate(
//                           context: context,
//                           page: const SchoolStudentLoginScreenScreen());
//                     },
//                     child: const SchoolWidgetSelectSchool());
//               },
//               separatorBuilder: (_, __) => sizedBoxHeight(height: 16),
//               itemCount: 10,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//             )
//           ],
//         );
//       },
//     );
//   }
// }
