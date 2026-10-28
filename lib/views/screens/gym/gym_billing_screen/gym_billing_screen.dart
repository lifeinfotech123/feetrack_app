import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/controllers/home_controller.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/gym/gym_billing_screen/widget/gym_checkout_mid_section/gym_checkout_mid_section.dart';
import 'package:vlr/views/screens/gym/gym_billing_screen/widget/gym_checkout_top_section/gym_checkout_top_section.dart';

class GymBillingScreen extends StatefulWidget {
  final String? roomId;
  const GymBillingScreen({super.key, this.roomId});

  @override
  State<GymBillingScreen> createState() => _GymBillingScreenState();
}

class _GymBillingScreenState extends State<GymBillingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSummary();
    });
  }

  void _fetchSummary() {
    final subscriptionController = Get.find<SubscriptionController>();
    final homeController = Get.find<HomeController>();
    final gymController = Get.find<GymController>();
    
    final listingId = homeController.selectListingModel?.id;
    final packageId = subscriptionController.selectedPlan?.id;

    if (listingId == null || packageId == null) {
      print('Missing listingId or packageId: listingId=$listingId, packageId=$packageId');
      showToast(message: "Plan details missing. Please select a plan again.");
      return;
    }

    final trainerId = gymController.selectGymTrainerModel?.id?.toString();

    // Determine booking type and pass appropriate parameters
    if (subscriptionController.hasRooms) {
      final rId = widget.roomId ?? subscriptionController.selectedRoomId;

      // Ensure the roomId is saved in the controller
      if (rId != null) {
        subscriptionController.setSelectedRoomId(rId);
      }

      subscriptionController.fetchBillingSummary(
        listingId: listingId,
        packageId: subscriptionController.selectedPlan?.id,
        roomId: rId,
        bedsBooked: subscriptionController.selectedBedsCount,
        paymentMethod: "online",
        useWallet: subscriptionController.useWallet,
      );
    } else if (subscriptionController.hasShifts) {
      subscriptionController.fetchBillingSummary(
        listingId: listingId,
        packageId: subscriptionController.selectedPlan?.id,
        shiftId: subscriptionController.selectedBatch?.id?.toString(),
        paymentMethod: "online",
        useWallet: subscriptionController.useWallet,
        trainerIds: trainerId != null ? [trainerId] : null,
      );
    } else {
      subscriptionController.fetchBillingSummary(
        listingId: listingId,
        packageId: subscriptionController.selectedPlan?.id,
        paymentMethod: "online",
        useWallet: subscriptionController.useWallet,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: white,
        elevation: 0,
        surfaceTintColor: white,
        title: Text(
          "CHECKOUT",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: primaryText1,
                letterSpacing: 1.2,
              ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: greyLight2.withValues(alpha: 0.05),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.horizontalPadding,
          vertical: 24,
        ),
        child: Column(
          children: [
            const GYMCheckoutTopSection(),
            sizedBoxHeight(height: 20),
            
            // Wallet Deduction Section
            GetBuilder<SubscriptionController>(builder: (subscriptionController) {
              return GetBuilder<AuthController>(builder: (authController) {
                final balance = double.tryParse(authController.userModel?.walletBalance ?? "0") ?? 0.0;
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF6366F1), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Wallet Balance",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              PriceConverter.convertToNumberFormat(balance),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A3B5D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: subscriptionController.useWallet,
                        activeColor: const Color(0xFF6366F1),
                        onChanged: (value) {
                          subscriptionController.updateUseWallet(value);
                          _fetchSummary();
                        },
                      ),
                    ],
                  ),
                );
              });
            }),
            
            const GYmCheckOutMidSection(),
          ],
        ),
      ),
    );
  }
}
