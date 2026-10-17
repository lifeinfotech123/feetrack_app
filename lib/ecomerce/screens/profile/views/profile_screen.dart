import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/app_router.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';
import '../../../components/network_image_with_loader.dart';
import '../../../constants.dart';
import '../../../route/route_constants.dart';
import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF6F6F9);

    return Scaffold(
      backgroundColor: bodyBg,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: defaultPadding,
            vertical: defaultPadding,
          ),
          children: [
            // 1. User Profile Info Card
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(defaultBorderRadious * 1.2),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFECECF2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ProfileCard(
                name: "Amrita Kumari",
                email: "amrita.kumari@gmail.com",
                imageSrc: "https://i.imgur.com/IXnwbLk.png",
                press: () {
                  Navigator.pushNamed(context, userInfoScreenRoute);
                },
              ),
            ),

            const SizedBox(height: defaultPadding),

            // 2. Promo Banner
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(defaultBorderRadious * 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(defaultBorderRadious * 1.2),
                child: const AspectRatio(
                  aspectRatio: 2.2,
                  child: NetworkImageWithLoader("https://i.imgur.com/dz0BBom.png"),
                ),
              ),
            ),

            const SizedBox(height: defaultPadding * 1.2),

            // 3. Account Section Header & Card
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Account",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(defaultBorderRadious * 1.2),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFECECF2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ProfileMenuListTile(
                    text: "Orders",
                    svgSrc: "assets/icons/Order.svg",
                    press: () {
                      Navigator.pushNamed(context, ordersScreenRoute);
                    },
                  ),
                  ProfileMenuListTile(
                    text: "Returns",
                    svgSrc: "assets/icons/Return.svg",
                    press: () {},
                  ),
                  ProfileMenuListTile(
                    text: "Wishlist",
                    svgSrc: "assets/icons/Wishlist.svg",
                    press: () {
                      Navigator.pushNamed(context, bookmarkScreenRoute);
                    },
                  ),
                  ProfileMenuListTile(
                    text: "Addresses",
                    svgSrc: "assets/icons/Address.svg",
                    press: () {
                      Navigator.pushNamed(context, addressesScreenRoute);
                    },
                  ),
                  ProfileMenuListTile(
                    text: "Payment",
                    svgSrc: "assets/icons/card.svg",
                    press: () {
                      Navigator.pushNamed(context, emptyPaymentScreenRoute);
                    },
                  ),
                  ProfileMenuListTile(
                    text: "Wallet",
                    svgSrc: "assets/icons/Wallet.svg",
                    press: () {
                      Navigator.pushNamed(context, walletScreenRoute);
                    },
                    isShowDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding * 1.2),

            // 4. Help & Support Section Header & Card
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "Help & Support",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(defaultBorderRadious * 1.2),
                border: Border.all(
                  color: isDark ? Colors.white12 : const Color(0xFFECECF2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ProfileMenuListTile(
                    text: "Get Help",
                    svgSrc: "assets/icons/Help.svg",
                    press: () {
                      Navigator.pushNamed(context, getHelpScreenRoute);
                    },
                  ),
                  ProfileMenuListTile(
                    text: "FAQ",
                    svgSrc: "assets/icons/FAQ.svg",
                    press: () {},
                    isShowDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding * 1.5),

            // 5. Log Out Button Card
            InkWell(
              onTap: () {
                _showLogoutDialog(context);
              },
              borderRadius: BorderRadius.circular(defaultBorderRadious * 1.2),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.08),
                  borderRadius:
                      BorderRadius.circular(defaultBorderRadious * 1.2),
                  border: Border.all(
                    color: errorColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/icons/Logout.svg",
                      height: 20,
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                        errorColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Log Out",
                      style: TextStyle(
                        color: errorColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: defaultPadding * 1.5),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious * 1.2),
        ),
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              if (Get.isRegistered<AuthController>()) {
                await Get.find<AuthController>().logout();
              }
              if (context.mounted) {
                navigate(
                    context: context,
                    isRemoveUntil: true,
                    page: const LoginScreen());
              }
              AppRouter.goToLogin();
            },
            child: const Text(
              "Log Out",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
