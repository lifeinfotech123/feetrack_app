// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:vlr/data/models/transaction_model.dart';
// import 'package:vlr/services/constants.dart';
// import 'package:vlr/services/theme.dart';
// import 'package:vlr/views/base/common_button.dart';
// import 'package:vlr/views/base/custom_image.dart';
// import 'package:vlr/views/screens/school/student_profile/widget/top_section_student_profile.dart';
// import 'package:vlr/views/screens/transaction_details_screen/transaction_details_screen.dart';

// class StudentProfileScreen extends StatelessWidget {
//   const StudentProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 2,
//         title: Text(
//           "School Profile",
//           style: Helper(context).textTheme.titleMedium?.copyWith(
//                 fontSize: 20,
//                 color: blackText3,
//               ),
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: AppConstants.screenPadding,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CustomButton(
//               height: 68,
//               radius: 24,
//               onTap: () {
//                 navigate(
//                     context: context,
//                     page: TransactionDetailsScreen(
//                       transaction: TransactionModel(
//                           transactionId: "transactionId",
//                           title: 'title',
//                           subtitle: 'subtitle',
//                           dateTime: DateTime.now(),
//                           paymentMode: "paymentMode",
//                           status: 'status',
//                           amount: 2000,
//                           recipient: 'recipient',
//                           payerVpa: 'payerVpa',
//                           gatewayId: 'gatewayId',
//                           rrnNumber: 'rrnNumber',
//                           feePoints: 20,
//                           imagePath: 'imagePath'),
//                     ));
//               },
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SvgPicture.asset(
//                     Assets.svgsCash,
//                     colorFilter: ColorFilter.mode(blueLight6, BlendMode.srcIn),
//                   ),
//                   sizedBoxWidth(width: 12),
//                   Text(
//                     "Pay Now (1,200)",
//                     style: Helper(context).textTheme.titleMedium?.copyWith(
//                           fontSize: 18,
//                           color: blueLight6,
//                         ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: AppConstants.screenPadding,
//         child: Column(
//           children: [
//             const TopSectionStudentProfile(),
//             sizedBoxHeight(height: 40),
//             Stack(
//               children: [
//                 Container(
//                   clipBehavior: Clip.antiAlias,
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(24),
//                     color: white,
//                     border: Border.all(width: 1, color: greyDart),
//                   ),
//                   child: Column(
//                     children: [
//                       Text(
//                         "TOTAL DUS FEE",
//                         style: Helper(context).textTheme.labelLarge?.copyWith(
//                               fontWeight: FontWeight.w700,
//                               fontSize: 16,
//                               letterSpacing: 1.6,
//                               color: greyText5,
//                             ),
//                       ),
//                       sizedBoxHeight(height: 16),
//                       Text(
//                         "1,200",
//                         style: Helper(context).textTheme.titleMedium?.copyWith(
//                               fontSize: 48,
//                               color: blueLight3,
//                             ),
//                       ),
//                       sizedBoxHeight(height: 16),
//                       Container(
//                         height: 4,
//                         width: 48,
//                         decoration: BoxDecoration(
//                           color: greenDark,
//                           borderRadius: BorderRadius.circular(999),
//                         ),
//                       ),
//                       sizedBoxHeight(height: 32),
//                       Divider(
//                         color: greyLight,
//                       ),
//                       sizedBoxHeight(height: 24),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Icon(
//                             Icons.calendar_month,
//                             color: blackText3,
//                           ),
//                           sizedBoxWidth(width: 8),
//                           Text(
//                             "Academic Year 2023-24",
//                             style:
//                                 Helper(context).textTheme.titleSmall?.copyWith(
//                                       fontSize: 16,
//                                       color: blackText3,
//                                     ),
//                           ),
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//                 Positioned(
//                   top: -70,
//                   right: -70,
//                   child: CircleAvatar(
//                     radius: 64,
//                     backgroundColor: primaryColor.withValues(alpha: 0.05),
//                   ),
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
