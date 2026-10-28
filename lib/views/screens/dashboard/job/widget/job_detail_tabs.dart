import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobDetailTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const JobDetailTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildTab(0, "Job Detail"),
              _buildTab(1, "Company"),
            ],
          ),
          // Divider
          Container(
            height: 1.h,
            width: double.infinity,
            color: const Color(0xFFF2F4F7),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final bool isActive = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF0052D9) : Colors.transparent,
                width: 3.h,
              ),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? const Color(0xFF0052D9) : const Color(0xFF98A2B3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
