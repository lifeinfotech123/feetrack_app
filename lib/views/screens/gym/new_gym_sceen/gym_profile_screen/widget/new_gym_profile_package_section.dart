// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:vlr/controllers/home_controller.dart';
// import 'package:vlr/controllers/subscription_controller.dart';
// import 'package:vlr/data/models/category_model/listing_model.dart';
// import 'package:vlr/data/models/category_model/package_model.dart';
// import 'package:vlr/services/constants.dart';
// import 'package:vlr/services/theme.dart';
// import 'package:vlr/views/base/shimmer.dart';
// import 'package:vlr/views/screens/gym/new_gym_sceen/gym_profile_screen/widget/gym_package_widget.dart';

// class NewGymProfilePackageSection extends StatelessWidget {
//   const NewGymProfilePackageSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: AppConstants.screenPadding,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Membership Plans",
//             style: Helper(context).textTheme.titleMedium?.copyWith(
//                   fontSize: 24,
//                   color: blackText1,
//                 ),
//           ),
//           sizedBoxHeight(height: 20),
//           GetBuilder<SubscriptionController>(builder: (subscriptionController) {
//             return GetBuilder<HomeController>(builder: (homeController) {
//               return ListView.separated(
//                   padding: EdgeInsets.zero,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     final _packageModel = homeController.isLoading
//                         ? PackageModel()
//                         : homeController.selectListingModel?.packages?[index];
//                     return CustomShimmer(
//                       isLoading: homeController.isLoading,
//                       child: GymPackageWidget(
//                         onTap: () {
//                           if (homeController.isLoading ||
//                               subscriptionController.isLoading) {
//                             return;
//                           }
//                           subscriptionController.updateSelectPackageModel(
//                               value: _packageModel);
//                           if (subscriptionController.selectPackageModel !=
//                               null) {
//                             subscriptionController.createSubscription();
//                           }
//                         },
//                         packageModel: _packageModel,
//                       ),
//                     );
//                   },
//                   separatorBuilder: (_, __) => sizedBoxHeight(height: 16),
//                   itemCount: homeController.isLoading
//                       ? 4
//                       : (homeController.selectListingModel?.packages?.length ??
//                           4));
//             });
//           })
//         ],
//       ),
//     );
//   }
// }
