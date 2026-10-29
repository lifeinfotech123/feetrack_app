import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/permission_controller.dart';
import 'package:vlr/ecomerce/screens/checkout/views/cart_screen.dart';
import 'package:vlr/ecomerce/screens/instant_delivery/Presention/screen/instant_product_.dart';
import 'package:vlr/ecomerce/screens/restaurant/views/restaurant_table_list_screen.dart';
import '../../../../constants.dart';
import '../../../../controllers/cart_controller.dart';
import '../../../../route/app_text_constants.dart';

class HomeAppBarHeaderWidget extends StatefulWidget {
  const HomeAppBarHeaderWidget({super.key});

  @override
  State<HomeAppBarHeaderWidget> createState() => _HomeAppBarHeaderWidgetState();
}

class _HomeAppBarHeaderWidgetState extends State<HomeAppBarHeaderWidget> {
  late final PermissionController _permissionController;

  @override
  void initState() {
    super.initState();
    _permissionController = Get.isRegistered<PermissionController>()
        ? Get.find<PermissionController>()
        : Get.put(PermissionController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_permissionController.address == null ||
          _permissionController.address!.trim().isEmpty) {
        _permissionController.requestLocationPermissionAndFetch(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    // Rich modern gradient for header
    final headerGradient = isDark
        ? const LinearGradient(
            colors: [Color(0xFF231942), Color(0xFF130E26)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : const LinearGradient(
            colors: [Color(0xFF7B61FF), Color(0xFF5333ED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final authController =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

    final String displayName =
        authController?.userModel?.name?.trim().isNotEmpty == true
            ? authController!.userModel!.name!.trim()
            : (authController?.userModel?.firstName?.trim().isNotEmpty == true
                ? authController!.userModel!.firstName!.trim()
                : "Shopper");

    final String? userAvatar = authController?.userModel?.image;

    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: headerGradient,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : const Color(0xFF7B61FF))
                  .withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          top: topPadding + 8,
          left: defaultPadding,
          right: defaultPadding,
          bottom: defaultPadding * 1.2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Profile Avatar, Greeting, User Name & Action Buttons
            Row(
              children: [
                // Profile Avatar with Ring
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, profileScreenRoute);
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white24,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: userAvatar != null && userAvatar.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: userAvatar,
                                    fit: BoxFit.cover,
                                    width: 44,
                                    height: 44,
                                    errorWidget: (_, __, ___) => const Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          height: 11,
                          width: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Greeting & User Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome 👋",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFFFFD54F),
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Notification & Cart Action Buttons
                Row(
                  children: [
                    // Notification Button
                    Material(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          Navigator.pushNamed(
                              context, notificationsScreenRoute);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(9),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/Notification.svg",
                                height: 20,
                                width: 20,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  height: 8,
                                  width: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF3D00),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Dynamic Cart / Shopping Bag Button
                    Material(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(9),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/Bag.svg",
                                height: 20,
                                width: 20,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              ListenableBuilder(
                                listenable: CartController.instance,
                                builder: (context, _) {
                                  final cartCount =
                                      CartController.instance.totalItemCount;
                                  if (cartCount == 0) {
                                    return const SizedBox.shrink();
                                  }
                                  return Positioned(
                                    right: -4,
                                    top: -4,
                                    child: Container(
                                      padding: const EdgeInsets.all(2.5),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF4081),
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 15,
                                        minHeight: 15,
                                      ),
                                      child: Text(
                                        "$cartCount",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            // DYNAMIC Real Current Location Chip
            GetBuilder<PermissionController>(
              init: _permissionController,
              builder: (permCtrl) {
                final hasLoc = permCtrl.address != null &&
                    permCtrl.address!.trim().isNotEmpty;
                final locText = hasLoc
                    ? permCtrl.address!.trim()
                    : (permCtrl.locationFetched
                        ? "Tap to detect location"
                        : "Detecting location...");

                return InkWell(
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Updating current location..."),
                        duration: Duration(milliseconds: 900),
                      ),
                    );
                    await permCtrl.requestLocationPermissionAndFetch(context);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFFFFD54F),
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Deliver to: ",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            locText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.refresh_rounded,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Floating Search Bar Card
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, searchScreenRoute);
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF262038) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/Search.svg",
                      height: 20,
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                        primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Search for products, brands, stores...",
                        style: TextStyle(
                          fontSize: 13.5,
                          color:
                              isDark ? Colors.white60 : const Color(0xFF888894),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      height: 18,
                      width: 1,
                      color: isDark ? Colors.white12 : Colors.grey.shade300,
                    ),
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      "assets/icons/Filter.svg",
                      height: 18,
                      width: 18,
                      colorFilter: const ColorFilter.mode(
                        primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Quick Action Buttons: Food Delivery & Book Table
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const InstantProduct()),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262038) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFE8E8EE),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delivery_dining_rounded,
                                color: primaryColor, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Food Delivery",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RestaurantTableListScreen(
                                  domain: 'e-team-12',
                                )),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF262038) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFE8E8EE),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.table_restaurant_rounded,
                                color: Color(0xFF00C853), size: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Book Table",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
