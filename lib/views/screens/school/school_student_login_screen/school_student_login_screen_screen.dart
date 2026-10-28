// import 'package:flutter/material.dart';
// import 'package:vlr/services/constants.dart';
// import 'package:vlr/services/theme.dart';
// import 'package:vlr/views/screens/school/school_student_login_screen/widget/school_student_login_section.dart';

// class SchoolStudentLoginScreenScreen extends StatelessWidget {
//   const SchoolStudentLoginScreenScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 2,
//         title: Text(
//           "School Student Login",
//           style: Helper(context).textTheme.titleMedium?.copyWith(
//                 fontSize: 20,
//                 color: blackText3,
//               ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: AppConstants.screenPadding,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Enter Student Details",
//               style: Helper(context).textTheme.titleSmall?.copyWith(
//                     fontSize: 16,
//                     color: blackText3,
//                   ),
//             ),
//             sizedBoxHeight(height: 8),
//             Text(
//               "Identify the student to proceed with fee payments.",
//               style: Helper(context).textTheme.bodySmall?.copyWith(
//                     fontSize: 16,
//                     color: greyDart2,
//                   ),
//             ),
//             sizedBoxHeight(height: 32),
//             const SchoolStudentLoginSection(),
//             sizedBoxHeight(height: 48),
//             SizedBox(
//               height: 8,
//               child: Center(
//                 child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemBuilder: (context, index) {
//                       return CircleAvatar(
//                         radius: 4,
//                         backgroundColor: primaryColor.withValues(alpha: 0.1),
//                       );
//                     },
//                     separatorBuilder: (_, __) => sizedBoxWidth(width: 12),
//                     itemCount: 5),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
