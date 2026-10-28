// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:vlr/controllers/home_controller.dart';
// import 'package:vlr/services/constants.dart';
// import 'package:vlr/services/theme.dart';
// import 'package:vlr/views/screens/gym/new_gym_sceen/gym_profile_screen/widget/new_gym_banner.dart';
// import 'package:vlr/views/screens/gym/new_gym_sceen/gym_profile_screen/widget/new_gym_profile_package_section.dart';

// class NewGymProfileScreen extends StatefulWidget {
//   const NewGymProfileScreen({super.key});

//   @override
//   State<NewGymProfileScreen> createState() => _NewGymProfileScreenState();
// }

// class _NewGymProfileScreenState extends State<NewGymProfileScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Get.find<HomeController>().fetchCategoriesListingById();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const NewGymProfileBanner(),
//             sizedBoxHeight(height: 20),
//             GetBuilder<HomeController>(builder: (homeController) {
//               return Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "About",
//                       style: Helper(context).textTheme.titleMedium?.copyWith(
//                             fontSize: 24,
//                             color: blackText1,
//                           ),
//                     ),
//                     sizedBoxHeight(height: 16),
//                     Text(
//                       homeController.selectListingModel?.description ?? "",
//                       style: Helper(context).textTheme.bodySmall?.copyWith(
//                             fontSize: 16,
//                             color: greyDart2,
//                           ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//             const NewGymProfilePackageSection()
//           ],
//         ),
//       ),
//     );
//   }
// }
