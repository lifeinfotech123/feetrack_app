import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/ecomerce/screens/chat/views/live_chat_screen.dart';
import 'package:vlr/services/app_router.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

import '../../../components/network_image_with_loader.dart';
import '../../../constants.dart';
import '../../../controllers/profile_controller.dart';
import '../../address/presentation/views/addresses_screen.dart';
import '../../bookmark/views/bookmark_screen.dart';
import '../../coupon/views/coupon_screen.dart';
import '../../notification/view/notificatios_screen.dart';
import '../../order/views/orders_screen.dart';
import '../../preferences/views/preferences_screen.dart';
import '../../return_refund/views/return_refund_screen.dart';
import '../../user_info/views/user_info_screen.dart';
import '../../wallet/views/wallet_screen.dart';
import '../../restaurant/views/dining/my_table_bookings_screen.dart';
import '../../support/views/support_ticket_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF7F7FA);

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: bodyBg,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: "Notifications",
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,
          onRefresh: () => _controller.fetchAllData(),
          child: Obx(() {
            final user = _controller.profile.value;
            final String userName =
                (user?.name != null && user!.name.isNotEmpty)
                    ? user.name
                    : "Customer";
            final String userContact =
                (user?.email != null && user!.email.isNotEmpty)
                    ? user.email
                    : (user?.phone ?? "No contact details");
            final String? userAvatar = user?.avatar;
            final double walletBal = _controller.walletBalance.value;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              children: [
                // 1. Dynamic User Profile Card
                _buildUserProfileCard(
                  context,
                  name: userName,
                  contact: userContact,
                  avatar: userAvatar,
                  isDark: isDark,
                  cardBg: cardBg,
                ),

                const SizedBox(height: 16),

                // 2. Dynamic Quick Metrics Row (4 Single Stat Cards)
                _buildQuickStatsRow(
                  context,
                  walletAmount: walletBal,
                  isDark: isDark,
                  cardBg: cardBg,
                ),

                const SizedBox(height: 22),

                // 3. Dynamic Order Tracking (4 Distinct Single Status Cards)
                _buildSectionHeader(
                  context,
                  title: "Order Tracking",
                  actionText: "View All",
                  onActionTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _buildOrderTrackingGrid(context,
                    isDark: isDark, cardBg: cardBg),

                const SizedBox(height: 24),

                // 4. Shopping & Account (Individual Single Cards)
                _buildSectionHeader(context, title: "Account & Shopping"),
                const SizedBox(height: 10),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.local_mall_rounded,
                  iconColor: const Color(0xFF7C4DFF),
                  iconBgColor: const Color(0xFF7C4DFF).withValues(alpha: 0.12),
                  title: "All Orders",
                  subtitle: "Track live shipments, view history & reorder",
                  badgeText: _controller.totalOrders.value > 0
                      ? "${_controller.totalOrders.value} Orders"
                      : null,
                  badgeColor: const Color(0xFF7C4DFF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                ),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.favorite_rounded,
                  iconColor: const Color(0xFFE91E63),
                  iconBgColor: const Color(0xFFE91E63).withValues(alpha: 0.12),
                  title: "My Wishlist",
                  subtitle: "Explore products you've saved for later",
                  badgeText: "${_controller.wishlistCount.value} Items",
                  badgeColor: const Color(0xFFE91E63),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookmarkScreen()),
                    );
                  },
                ),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFF2979FF),
                  iconBgColor: const Color(0xFF2979FF).withValues(alpha: 0.12),
                  title: "Saved Delivery Addresses",
                  subtitle: "Manage home, work & other delivery locations",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddressesScreen()),
                    );
                  },
                ),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFFFF9800),
                  iconBgColor: const Color(0xFFFF9800).withValues(alpha: 0.12),
                  title: "My Wallet",
                  subtitle: "Balance, cashback & transaction history",
                  badgeText: "₹${walletBal.toStringAsFixed(0)}",
                  badgeColor: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletScreen()),
                    );
                  },
                ),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.confirmation_num_rounded,
                  iconColor: const Color(0xFFFF5722),
                  iconBgColor: const Color(0xFFFF5722).withValues(alpha: 0.12),
                  title: "Coupons & Discounts",
                  subtitle:
                      "Available discount vouchers & exclusive promo codes",
                  badgeText: "${_controller.couponsCount.value} Offers",
                  badgeColor: const Color(0xFFFF5722),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CouponScreen()),
                    );
                  },
                ),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.assignment_return_rounded,
                  iconColor: const Color(0xFFFB923C),
                  iconBgColor: const Color(0xFFFB923C).withValues(alpha: 0.12),
                  title: "Returns & Refunds",
                  subtitle: "View your return & refund requests",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ReturnRefundScreen()),
                    );
                  },
                ),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.rate_review_rounded,
                  iconColor: const Color(0xFFFFB300),
                  iconBgColor: const Color(0xFFFFB300).withValues(alpha: 0.12),
                  title: "Ratings & Reviews",
                  subtitle: "Share feedback on items you've purchased",
                  onTap: () {},
                ),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.table_restaurant_rounded,
                  iconColor: const Color(0xFF26A69A),
                  iconBgColor: const Color(0xFF26A69A).withValues(alpha: 0.12),
                  title: "Table Bookings",
                  subtitle: "View and manage your dine-in reservations",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const MyTableBookingsScreen(domain: 'e-team-12'),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 5. Preferences & Settings (Individual Single Cards)
                _buildSectionHeader(context, title: "Preferences & Security"),
                const SizedBox(height: 10),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.manage_accounts_rounded,
                  iconColor: const Color(0xFF5C6BC0),
                  iconBgColor: const Color(0xFF5C6BC0).withValues(alpha: 0.12),
                  title: "Account Settings",
                  subtitle: "Update personal details & password",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserInfoScreen()),
                    );
                  },
                ),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.tune_rounded,
                  iconColor: const Color(0xFF8E24AA),
                  iconBgColor: const Color(0xFF8E24AA).withValues(alpha: 0.12),
                  title: "App Preferences",
                  subtitle: "Language, currency & dark theme options",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PreferencesScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // 6. Help & Support (Individual Single Cards)
                _buildSectionHeader(context, title: "Help & Support"),
                const SizedBox(height: 10),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.headset_mic_rounded,
                  iconColor: const Color(0xFF00C853),
                  iconBgColor: const Color(0xFF00C853).withValues(alpha: 0.12),
                  title: "24/7 Customer Support",
                  subtitle: "Support tickets, live help & issue tracking",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SupportTicketListScreen(),
                      ),
                    );
                  },
                ),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.chat,
                  iconColor: const Color(0xFF0288D1),
                  iconBgColor: const Color(0xFF0288D1).withValues(alpha: 0.12),
                  title: "Live Chat",
                  subtitle: "Chating with our technical team",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LiveChatScreen(),
                      ),
                    );
                  },
                ),

                _buildSingleFeatureCard(
                  context,
                  icon: Icons.shield_outlined,
                  iconColor: const Color(0xFF607D8B),
                  iconBgColor: const Color(0xFF607D8B).withValues(alpha: 0.12),
                  title: "Privacy & Terms of Service",
                  subtitle: "How your data is protected & usage policies",
                  onTap: () {},
                ),

                const SizedBox(height: 20),

                // 7. Log Out Single Card
                _buildSingleFeatureCard(
                  context,
                  icon: Icons.logout_rounded,
                  iconColor: errorColor,
                  iconBgColor: errorColor.withValues(alpha: 0.12),
                  title: "Log Out",
                  subtitle: "Securely sign out of this account",
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context),
                ),

                const SizedBox(height: 24),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// 1. Dynamic User Profile Card
  Widget _buildUserProfileCard(
    BuildContext context, {
    required String name,
    required String contact,
    String? avatar,
    required bool isDark,
    required Color cardBg,
  }) {
    final bool hasAvatar = avatar != null && avatar.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : const Color(0xFFECECF2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with subtle glow ring
          Stack(
            children: [
              Container(
                width: 62,
                height: 62,
                padding: const EdgeInsets.all(2.5),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFF00C853)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipOval(
                  child: hasAvatar
                      ? NetworkImageWithLoader(
                          avatar,
                          radius: 100,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFF6C4FE0),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00C853),
                    shape: BoxShape.circle,
                    border: Border.all(color: cardBg, width: 2),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 9,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 14),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "ACTIVE",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFE65100),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  contact,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Edit Profile Button
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserInfoScreen()),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: primaryColor,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Dynamic Quick Metrics Row (4 Single Stat Cards)
  Widget _buildQuickStatsRow(
    BuildContext context, {
    required double walletAmount,
    required bool isDark,
    required Color cardBg,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            label: "Orders",
            value: "${_controller.totalOrders.value}",
            icon: Icons.local_mall_outlined,
            color: const Color(0xFF7C4DFF),
            isDark: isDark,
            cardBg: cardBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersScreen()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            label: "Wishlist",
            value: "${_controller.wishlistCount.value}",
            icon: Icons.favorite_border_rounded,
            color: const Color(0xFFE91E63),
            isDark: isDark,
            cardBg: cardBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookmarkScreen()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            label: "Coupons",
            value: "${_controller.couponsCount.value}",
            icon: Icons.confirmation_num_outlined,
            color: const Color(0xFFFF5722),
            isDark: isDark,
            cardBg: cardBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CouponScreen()),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            label: "Wallet",
            value: "₹${walletAmount.toStringAsFixed(0)}",
            icon: Icons.account_balance_wallet_outlined,
            color: const Color(0xFFFF9800),
            isDark: isDark,
            cardBg: cardBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalletScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFECECF2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Dynamic Order Tracking (4 Distinct Single Status Cards)
  Widget _buildOrderTrackingGrid(
    BuildContext context, {
    required bool isDark,
    required Color cardBg,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildOrderStatusCard(
            context,
            title: "Pending",
            count: "${_controller.pendingOrders.value}",
            icon: Icons.hourglass_top_rounded,
            color: const Color(0xFFFFB300),
            isDark: isDark,
            cardBg: cardBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrdersScreen(initialFilter: 'Pending'),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOrderStatusCard(
            context,
            title: "Shipped",
            count: "${_controller.shippedOrders.value}",
            icon: Icons.local_shipping_rounded,
            color: const Color(0xFF2979FF),
            isDark: isDark,
            cardBg: cardBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrdersScreen(initialFilter: 'Pending'),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOrderStatusCard(
            context,
            title: "Delivered",
            count: "${_controller.deliveredOrders.value}",
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF00C853),
            isDark: isDark,
            cardBg: cardBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrdersScreen(initialFilter: 'Delivered'),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildOrderStatusCard(
            context,
            title: "Returns",
            count: "${_controller.returnOrders.value}",
            icon: Icons.replay_rounded,
            color: const Color(0xFFFF5722),
            isDark: isDark,
            cardBg: cardBg,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const OrdersScreen(initialFilter: 'Canceled'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color cardBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFECECF2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (count != "0")
                  Positioned(
                    top: -3,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 4. Standalone Single Card Builder (Name with Icon)
  Widget _buildSingleFeatureCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E28) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDestructive
              ? errorColor.withValues(alpha: 0.25)
              : (isDark ? Colors.white12 : const Color(0xFFECECF2)),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDestructive
                ? errorColor.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // Stylized Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                // Name and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: isDestructive
                                    ? errorColor
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (badgeColor ?? primaryColor)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor ?? primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2.5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDestructive
                              ? errorColor.withValues(alpha: 0.8)
                              : (isDark ? Colors.white54 : Colors.black54),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Trailing Arrow
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? errorColor.withValues(alpha: 0.08)
                        : (isDark
                            ? const Color(0xFF262634)
                            : const Color(0xFFF4F4F8)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 19,
                    color: isDestructive
                        ? errorColor
                        : (isDark ? Colors.white38 : Colors.grey.shade400),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section Header
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    String? actionText,
    VoidCallback? onActionTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
              color: isDark ? Colors.white70 : Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
          if (actionText != null && onActionTap != null)
            InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    Text(
                      actionText,
                      style: const TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Log Out Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: errorColor, size: 24),
            SizedBox(width: 8),
            Text(
              "Log Out",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to log out of your account on this device?",
          style: TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                  page: const LoginScreen(),
                );
              }
              AppRouter.goToLogin();
            },
            child: const Text(
              "Yes, Log Out",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
