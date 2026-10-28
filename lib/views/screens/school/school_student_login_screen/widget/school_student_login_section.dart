// import 'package:flutter/material.dart';
// import 'package:get/state_manager.dart';
// import 'package:vlr/controllers/school_controller.dart';
// import 'package:vlr/services/constants.dart';
// import 'package:vlr/services/theme.dart';
// import 'package:vlr/views/base/common_button.dart';
// import 'package:vlr/views/base/custom_image.dart';
// import 'package:vlr/views/screens/school/student_profile/student_profile_screen.dart';
// import 'package:vlr/views/widget/text_box/app_text_box.dart';

// class SchoolStudentLoginSection extends StatelessWidget {
//   const SchoolStudentLoginSection({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
//       decoration: BoxDecoration(
//         border: Border.all(
//           width: 1,
//           color: greyLight8.withValues(alpha: 0.30),
//         ),
//         color: white,
//         borderRadius: BorderRadius.circular(24),
//       ),
//       child: Column(
//         children: [
//           const CustomImage(
//             path: Assets.imagesSchoolLogo,
//             height: 92,
//             width: 92,
//             fit: BoxFit.cover,
//             radius: 9999,
//           ),
//           sizedBoxHeight(height: 18),
//           Text(
//             "St. Xavier's High School",
//             style: Helper(context).textTheme.titleMedium?.copyWith(
//                   fontSize: 20,
//                   color: blackText3,
//                 ),
//           ),
//           Text(
//             "St. Xavier's High School",
//             style: Helper(context).textTheme.bodySmall?.copyWith(
//                   fontSize: 16,
//                   color: greyDart2,
//                 ),
//           ),
//           sizedBoxHeight(height: 32),
//           GetBuilder<SchoolController>(builder: (schoolController) {
//             return Column(
//               children: [
//                 AppTextFieldWithHeading(
//                   controller: schoolController.studentFullNameController,
//                   preFixWidget: Icon(
//                     Icons.person_outline_rounded,
//                     color: greyText5,
//                     size: 22,
//                   ),
//                   headingWidget: Text(
//                     "STUDENT FULL NAME",
//                     style: Helper(context).textTheme.labelLarge?.copyWith(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           letterSpacing: 0.4,
//                           color: blackText3,
//                         ),
//                   ),
//                   hindText: "e.g. Rahul Sharma",
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Enter student full name";
//                     }
//                     return null;
//                   },
//                 ),
//                 sizedBoxHeight(height: 24),
//                 AppTextFieldWithHeading(
//                   controller: schoolController.studentIDController,
//                   preFixWidget: Icon(
//                     Icons.badge_outlined,
//                     color: greyText5,
//                     size: 22,
//                   ),
//                   textInputAction: TextInputAction.done,
//                   headingWidget: Text(
//                     "STUDENT ID",
//                     style: Helper(context).textTheme.labelLarge?.copyWith(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           letterSpacing: 0.4,
//                           color: blackText3,
//                         ),
//                   ),
//                   hindText: "e.g. SXHS-2024-089",
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return "Enter student Id";
//                     }
//                     return null;
//                   },
//                 ),
//                 sizedBoxHeight(height: 48),
//                 CustomButton(
//                   height: 56,
//                   radius: 9999,
//                   onTap: () {
//                     navigate(
//                         context: context, page: const StudentProfileScreen());
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Fetch Student Data",
//                         style: Helper(context).textTheme.labelLarge?.copyWith(
//                               fontWeight: FontWeight.w400,
//                               fontSize: 16,
//                               color: white,
//                             ),
//                       ),
//                       sizedBoxWidth(width: 4),
//                       Icon(
//                         Icons.arrow_forward,
//                         color: white,
//                       )
//                     ],
//                   ),
//                 ),
//                 sizedBoxHeight(height: 16),
//                 CustomButton(
//                   height: 48,
//                   type: ButtonType.tertiary,
//                   radius: 9999,
//                   onTap: () {
//                     pop(context);
//                   },
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Back to School List",
//                         style: Helper(context).textTheme.titleSmall?.copyWith(
//                               fontSize: 16,
//                               color: greenDark,
//                             ),
//                       ),
//                       sizedBoxWidth(width: 4),
//                       Icon(
//                         Icons.arrow_forward,
//                         color: white,
//                       )
//                     ],
//                   ),
//                 )
//               ],
//             );
//           })
//         ],
//       ),
//     );
//   }
// }
