import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/hospital/features/lab_reports/presentation/screen/lab_reports_screen.dart';
import 'package:vlr/hospital/features/profile/presentation/screen/profile_screen.dart';
import 'package:vlr/hospital/features/profile/logics/hospital_profile_controller.dart';

import '../../../../core/constants/colors.dart';
import '../../../appointments/presentation/screen/appointments_screen.dart';
import '../../../home_screen/presentation/screen/home_screen.dart';

class HospitalDashboardScreen extends StatefulWidget {
  final String? username;
  final String? userId;

  const HospitalDashboardScreen({
    super.key,
    this.username,
    this.userId,
  });

  @override
  State<HospitalDashboardScreen> createState() =>
      _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HospitalProfileController>()) {
      Get.put(HospitalProfileController());
    }

    final authCtrl =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final bool isLoggedIn = authCtrl?.isLoggedIn() ?? false;
    final resolvedUserId = widget.userId ??
        (isLoggedIn ? (authCtrl?.userModel?.id?.toString() ?? '') : '');

    _screens = [
      const HospitalHomeScreen(),
      AppointmentsScreen(userId: resolvedUserId),
      const LabReportsScreen(),
      const HospitalProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: colorWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home'),
              _buildNavItem(1, Icons.calendar_month_rounded, 'Appointments'),
              _buildNavItem(2, Icons.science_rounded, 'Lab Reports'),
              _buildNavItem(3, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? primaryColor : colorGrey,
              size: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryColor : colorGrey,
            ),
          ),
        ],
      ),
    );
  }
}
