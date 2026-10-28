// import 'package:flutter/material.dart';
// import 'package:vlr/services/constants.dart';
// import 'package:vlr/services/theme.dart';
// import 'package:vlr/views/screens/bookings/booking_screen.dart';

// class ProfileBookingSection extends StatelessWidget {
//   const ProfileBookingSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         sizedBoxHeight(height: 32),
//         Text(
//           "BOOKINGS",
//           style: Helper(context).textTheme.bodyMedium?.copyWith(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: greyText2,
//                 letterSpacing: 1.4,
//               ),
//         ),
//         sizedBoxHeight(height: 16),
//         GestureDetector(
//           onTap: () {
//             navigate(context: context, page: const BookingScreen());
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
//             decoration: BoxDecoration(
//               color: white,
//               borderRadius: BorderRadius.circular(32),
//               border: Border.all(
//                 width: 1,
//                 color: greyLight4.withValues(alpha: 0.30),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: primaryText1.withValues(alpha: 0.1),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.book_online_outlined,
//                     color: primaryText1,
//                   ),
//                 ),
//                 sizedBoxWidth(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "My Bookings",
//                         style: Helper(context).textTheme.bodyMedium?.copyWith(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: blackText1,
//                             ),
//                       ),
//                       sizedBoxHeight(height: 4),
//                       Text(
//                         "View all your gym and room bookings",
//                         style: Helper(context).textTheme.bodySmall?.copyWith(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w400,
//                               color: greyText3,
//                             ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: greyText3,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
