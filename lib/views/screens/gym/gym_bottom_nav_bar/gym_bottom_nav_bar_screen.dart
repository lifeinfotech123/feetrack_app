import 'package:flutter/material.dart';
import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/views/screens/dashboard/home_screen/All_home/gym_home/gym_home_screen.dart';
import 'package:vlr/views/screens/gym/attendance/attendance_checkin_checkout_screen.dart';
import 'package:vlr/views/screens/gym/gym_book_visit/gym_my_visit_screen.dart';
import 'package:vlr/views/screens/gym/gym_profile/gym_profile_screen.dart';

class GymBottomNavBarScreen extends StatefulWidget {
  final int initialIndex;
  final String? listingId;
  final ListingModel? listingModel;

  const GymBottomNavBarScreen({
    super.key,
    this.initialIndex = 0,
    this.listingId,
    this.listingModel,
  });

  @override
  State<GymBottomNavBarScreen> createState() => _GymBottomNavBarScreenState();
}

class _GymBottomNavBarScreenState extends State<GymBottomNavBarScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 2);
  }

  @override
  void didUpdateWidget(covariant GymBottomNavBarScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex.clamp(0, 2);
      });
    }
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const GymHomeScreen(),
      const AttendanceCheckinCheckoutScreen(),
      const GymMembershipsScreen(),
      const GymProfileScreen(),
    ];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, -4),
            blurRadius: 18,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.fingerprint,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.book,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.account_circle_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 12 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF002060) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : const Color(0xFF64748B),
        ),
      ),
    );
  }
}
