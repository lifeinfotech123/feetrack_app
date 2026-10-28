import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/kyc_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/lanch_helper.dart';
import 'package:vlr/views/screens/auth_screens/kyc/kyc_screen.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';
import 'package:vlr/views/screens/bookings/booking_screen.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_edit_screen/profile_edit_screen.dart';
import 'package:vlr/views/screens/gym/attendance/attendance_checkin_checkout_screen.dart';
import 'package:vlr/views/screens/gym/gym_book_visit/gym_my_visit_screen.dart';
import 'package:vlr/views/screens/total_transaction_history/total_transaction_history_screen.dart';

import '../../../../base/custom_image.dart';
import '../../../../base/dialogs/delete_account_dialog.dart';
import '../../../../base/dialogs/logout_dialog.dart';
import '../../wallet_screen/wallet_transaction_reserve__tabbar_screen.dart';
import 'package:vlr/services/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<KycController>().getKycProfile();
        Get.find<AuthController>().fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF0F4F8), // Light background matching screenshot
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Header Card
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  if (!Get.find<AuthController>().isLoggedIn()) {
                    navigate(context: context, page: const LoginScreen());
                  } else {
                    navigate(context: context, page: const ProfileEditScreen());
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      GetBuilder<KycController>(
                        builder: (kycController) {
                          bool isApproved =
                              kycController.kycProfile?.status?.toLowerCase() ==
                                  'approved';
                          return Container(
                            padding: EdgeInsets.all(isApproved ? 3 : 0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isApproved
                                  ? Border.all(color: Colors.green, width: 2)
                                  : null,
                            ),
                            child: GetBuilder<AuthController>(
                              builder: (authController) {
                                return Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.shade900,
                                  ),
                                  child: ClipOval(
                                    child: CustomImage(
                                      path: authController.isLoggedIn()
                                          ? (authController.userModel?.image ??
                                              "")
                                          : "",
                                      fit: BoxFit.cover,
                                      isProfile: true,
                                      height: 60,
                                      width: 60,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // Name
                      Expanded(
                        child: GetBuilder<AuthController>(
                          builder: (authController) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  capitalize(authController.isLoggedIn()
                                      ? (authController.userModel?.name ??
                                          "Guest")
                                      : "Guest"),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                GetBuilder<KycController>(
                                    builder: (kycController) {
                                  if (authController.isLoggedIn() &&
                                      kycController.kycProfile?.status
                                              ?.toLowerCase() ==
                                          'approved') {
                                    return Row(
                                      children: [
                                        const Icon(Icons.verified,
                                            color: Colors.green, size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Verified",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                                const SizedBox(height: 4),
                                Text(
                                  authController.isLoggedIn()
                                      ? "Wallet Balance: ${PriceConverter.convert(authController.userModel?.walletBalance ?? "0.00")}"
                                      : "Wallet Balance: ${PriceConverter.convert("0.00")}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF283593),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      // Edit Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00ACC1).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "EDIT",
                          style: TextStyle(
                            color: Color(0xFF00ACC1), // Cyan text
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 12),
                child: Text(
                  "My History",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),

              // 4. Menu Items Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: Icons.person_outline,
                      title: "User Details",
                      onTap: () {
                        navigate(
                            context: context, page: const ProfileEditScreen());
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.document_scanner_outlined,
                      title: "KYC ",
                      onTap: () {
                        navigate(context: context, page: const KycScreen());
                      },
                    ),
                    const Divider(
                        height: 1,
                        color: Color(0xFFEEEEEE),
                        indent: 16,
                        endIndent: 16),
                    ProfileMenuItem(
                      icon: Icons.fact_check_outlined,
                      title: "Attendance",
                      onTap: () {
                        navigate(
                            context: context,
                            page: const AttendanceCheckinCheckoutScreen());
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: Color(0xFFEEEEEE),
                      indent: 16,
                      endIndent: 16,
                    ),
                    const Divider(
                      height: 1,
                      color: Color(0xFFEEEEEE),
                      indent: 16,
                      endIndent: 16,
                    ),
                    ProfileMenuItem(
                      icon: Icons.calendar_month_outlined,
                      title: "Bookings",
                      onTap: () {
                        if (!Get.find<AuthController>().isLoggedIn()) {
                          navigate(context: context, page: const LoginScreen());
                        } else {
                          navigate(
                              context: context, page: const BookingScreen());
                        }
                      },
                    ),
                    const Divider(
                        height: 1,
                        color: Color(0xFFEEEEEE),
                        indent: 16,
                        endIndent: 16),
                    ProfileMenuItem(
                      icon: Icons.account_balance,
                      title: "Wallet",
                      onTap: () {
                        navigate(
                            context: context,
                            page: const WalletTransactionReserveTabbarScreen());
                      },
                    ),
                    const Divider(
                        height: 1,
                        color: Color(0xFFEEEEEE),
                        indent: 16,
                        endIndent: 16),
                    ProfileMenuItem(
                      icon: Icons.history_rounded,
                      title: "My Payment History",
                      onTap: () {
                        navigate(
                            context: context,
                            page: const TotalTransactionHistoryScreen());
                      },
                    ),
                    const Divider(
                        height: 1,
                        color: Color(0xFFEEEEEE),
                        indent: 16,
                        endIndent: 16),
                    ProfileMenuItem(
                      icon: Icons.event_available,
                      title: "My Gym book",
                      onTap: () {
                        navigate(
                          context: context,
                          page: const GymMembershipsScreen(),
                        );
                      },
                    ),
                    const Divider(
                        height: 1,
                        color: Color(0xFFEEEEEE),
                        indent: 16,
                        endIndent: 16),
                    ProfileMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: "Help",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24)),
                            title: const Text("Contact Support",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                    "Need assistance? Dial our support number below.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey)),
                                const SizedBox(height: 24),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    LaunchHelper.callUs(number: "9000000");
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF002060)
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.phone_in_talk_rounded,
                                        color: Color(0xFF002060),
                                        size: 40),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text("+919040888400",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF002060))),
                              ],
                            ),
                            actions: [
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("CLOSE",
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(
                        height: 1,
                        color: Color(0xFFEEEEEE),
                        indent: 16,
                        endIndent: 16),
                    ProfileMenuItem(
                      icon: Icons.receipt_long_outlined,
                      title: "About US",
                      onTap: () {
                        LaunchHelper.launchInBrowser(
                            Uri.parse("https://app.feetrack.in/about-us"));
                      },
                    ),
                    const Divider(
                        height: 1,
                        color: Color(0xFFEEEEEE),
                        indent: 16,
                        endIndent: 16),
                    ProfileMenuItem(
                      icon: Icons.delete_forever_outlined,
                      title: "Delete Account",
                      onTap: () async {
                        bool? delete =
                            await showDeleteAccountDialogue(context: context);
                        if (delete == true) {
                          final authController = Get.find<AuthController>();
                          final value = await authController.deleteAccount();
                          if (value.isSuccess) {
                            showToast(
                                message: value.message,
                                typeCheck: value.isSuccess);
                            if (context.mounted) {
                              navigate(
                                  context: context,
                                  isRemoveUntil: true,
                                  page: const LoginScreen());
                            }
                          } else {
                            showToast(
                                message: value.message,
                                typeCheck: value.isSuccess);
                          }
                        }
                      },
                    ),
                    const Divider(
                        height: 1,
                        color: Color(0xFFEEEEEE),
                        indent: 16,
                        endIndent: 16),
                    GetBuilder<AuthController>(
                      builder: (authController) {
                        final isLoggedIn = authController.isLoggedIn();
                        return ProfileMenuItem(
                          icon: isLoggedIn ? Icons.logout : Icons.login,
                          title: isLoggedIn ? "Logout" : "Login",
                          onTap: () async {
                            if (!isLoggedIn) {
                              navigate(
                                  context: context,
                                  isRemoveUntil: true,
                                  page: const LoginScreen());
                              return;
                            }
                            bool? logout =
                                await showLogoutDialogue(context: context);
                            if (logout == true) {
                              final value = await authController.logout();
                              showToast(
                                  message: value.message.isNotEmpty
                                      ? value.message
                                      : "Logged out successfully",
                                  typeCheck: true);
                              if (context.mounted) {
                                navigate(
                                    context: context,
                                    isRemoveUntil: true,
                                    page: const LoginScreen());
                              }
                              AppRouter.goToLogin();
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
