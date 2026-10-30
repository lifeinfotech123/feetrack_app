import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/gym_profile_controller.dart';
import 'package:vlr/data/models/user_model.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';
import 'package:vlr/views/screens/dashboard/profile/profile_edit_screen/profile_edit_screen.dart';
import 'package:vlr/views/screens/gym/attendance/gym_invoice_list_screen.dart';
import 'package:vlr/views/screens/gym/gym_book_visit/gym_my_visit_screen.dart';
import 'package:vlr/views/screens/gym/wallet/gym_wallet_main_screen.dart';

class GymProfileScreen extends StatefulWidget {
  const GymProfileScreen({super.key});

  @override
  State<GymProfileScreen> createState() => _GymProfileScreenState();
}

class _GymProfileScreenState extends State<GymProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<GymProfileController>().fetchProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final isLoggedIn = authController.isLoggedIn();
        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FC),
          appBar: AppBar(
            title: const Text(
              'GYM PROFILE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            backgroundColor: const Color(0xFFF4F7FC),
            foregroundColor: const Color(0xFF17233D),
            elevation: 0,
            actions: [
              if (isLoggedIn)
                IconButton(
                  tooltip: 'Refresh profile',
                  onPressed: Get.find<GymProfileController>().fetchProfile,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: !isLoggedIn
              ? _buildGuestView(context)
              : GetBuilder<GymProfileController>(
                  builder: (controller) {
                    if (controller.isLoading &&
                        controller.profile.user == null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.errorMessage != null &&
                        controller.profile.user == null) {
                      return _buildErrorView(controller);
                    }
                    return _buildProfileContent(
                      context,
                      controller.profile.user ?? authController.userModel,
                      controller.isLoading,
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: const Color(0xFFE8EDF5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  size: 34,
                  color: Color(0xFF2868D7),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your gym profile awaits',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1D2B43),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Log in to see your profile, visits and memberships in one place.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF7A879B),
                  height: 1.5,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF175FC2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                    if (!mounted) return;
                    if (Get.find<AuthController>().isLoggedIn()) {
                      await Get.find<GymProfileController>().fetchProfile();
                    }
                  },
                  child: const Text(
                    'Log In',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(GymProfileController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE8EDF5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 30,
                  color: Color(0xFFD95151),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not load your profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1D2B43),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage ?? 'Please try again in a moment.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF7A879B),
                  height: 1.45,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: controller.fetchProfile,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF175FC2),
                  side: const BorderSide(color: Color(0xFFBBD0F1)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserModel? user,
    bool isRefreshing,
  ) {
    final name = (user?.name?.trim().isNotEmpty == true)
        ? user!.name!.trim()
        : 'Gym Member';
    final phone = [
      user?.countryCode,
      user?.mobile,
    ].where((value) => value != null && value.trim().isNotEmpty).join(' ');
    return RefreshIndicator(
      onRefresh: Get.find<GymProfileController>().fetchProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          _buildProfileHeader(context, user, name, phone),
          if (isRefreshing) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              minHeight: 2,
              color: Color(0xFF3478F6),
              backgroundColor: Color(0xFFDCE7F7),
            ),
          ],
          const SizedBox(height: 28),
          _buildSectionHeading(
            title: 'Your gym activity',
            subtitle: 'Quick access to your bookings',
          ),
          const SizedBox(height: 14),
          _buildNavigationCard(
            context,
            title: 'My Visits',
            subtitle: 'Check your upcoming gym visits',
            icon: Icons.event_available_rounded,
            tint: const Color(0xFFE8F1FF),
            iconColor: const Color(0xFF2868D7),
            showVisits: true,
          ),
          const SizedBox(height: 12),
          _buildNavigationCard(
            context,
            title: 'My Memberships',
            subtitle: 'View plans and membership bookings',
            icon: Icons.card_membership_rounded,
            tint: const Color(0xFFE7F7F1),
            iconColor: const Color(0xFF16845B),
            showVisits: false,
          ),
          const SizedBox(height: 12),
          _buildNavigationCard(
            context,
            title: 'Wallet & Transactions',
            subtitle: 'View your account balance and wallet activity',
            icon: Icons.account_balance_wallet_rounded,
            tint: const Color(0xFFFFF3DF),
            iconColor: const Color(0xFFD58A13),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GymWalletMainScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildNavigationCard(
            context,
            title: 'Gym Invoices',
            subtitle: 'View invoices, payments and receipt details',
            icon: Icons.receipt_long_rounded,
            tint: const Color(0xFFF0EAFE),
            iconColor: const Color(0xFF7047C8),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GymInvoiceListScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserModel? user,
    String name,
    String phone,
  ) {
    final email = user?.email?.trim() ?? '';
    final isActive = user?.status?.toLowerCase() == 'active';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileEditScreen()),
        ),
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2B62), Color(0xFF1767C8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF164A99).withValues(alpha: 0.22),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned(
                  right: -32,
                  top: -55,
                  child: _decorativeCircle(170),
                ),
                Positioned(
                  right: 76,
                  bottom: -86,
                  child: _decorativeCircle(150),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 18, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.fitness_center_rounded,
                            color: Color(0xFFBBD8FF),
                            size: 17,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'YOUR FITNESS PROFILE',
                            style: TextStyle(
                              color: Color(0xFFD8E8FF),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.15,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.edit_outlined,
                            color: Colors.white.withValues(alpha: 0.82),
                            size: 19,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.55),
                                width: 1.5,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.18,
                              ),
                              child: ClipOval(
                                child: user?.image?.isNotEmpty == true
                                    ? Image.network(
                                        user!.image!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            _avatarFallback(name),
                                      )
                                    : _avatarFallback(name),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (email.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.78),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (phone.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    phone,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.78),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          _headerPill(
                            icon: Icons.badge_outlined,
                            label: 'Member #${user?.id ?? '--'}',
                          ),
                          const SizedBox(width: 8),
                          _headerPill(
                            icon: isActive
                                ? Icons.check_circle_outline_rounded
                                : Icons.info_outline_rounded,
                            label: user?.status?.isNotEmpty == true
                                ? user!.status!.toUpperCase()
                                : 'GYM MEMBER',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _decorativeCircle(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.055),
        ),
      );

  Widget _avatarFallback(String name) => Center(
        child: Text(
          name.characters.first.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _headerPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFD8E8FF)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF18243A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7A879B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color tint,
    required Color iconColor,
    bool? showVisits,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap ??
            () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => showVisits == true
                        ? const GymMyVisitsScreen()
                        : const GymMembershipsScreen(),
                  ),
                ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8EDF5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF19365D).withValues(alpha: 0.035),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1D2B43),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF7A879B),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F5FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF5B6B83),
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
