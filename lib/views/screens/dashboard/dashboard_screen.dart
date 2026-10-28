import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vlr/ecomerce/entry_point.dart';

import 'package:vlr/services/constants.dart';

import 'package:vlr/views/screens/dashboard/home_screen/all_category_home/all_category_home_screen.dart';

import 'package:vlr/views/screens/dashboard/job/job_screen.dart';

import 'package:vlr/views/screens/dashboard/profile/profile_screen/profile_screen.dart';

import 'package:vlr/hospital/features/dashboard/presentation/screen/dashboard_screen.dart'
    as hospital;

import '../../../controllers/dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DashBoardController>().dashPage = 0;
    });
  }

  final List<Map<String, dynamic>> items = [
    {
      "activeIcon": Icons.home_rounded,
      "inactiveIcon": Icons.home_outlined,
      "label": "Home"
    },
    {
      "activeIcon": Icons.work,
      "inactiveIcon": Icons.work_outline,
      "label": "Job"
    },
    {
      "activeIcon": Icons.shopping_cart,
      "inactiveIcon": Icons.shopping_cart_outlined,
      "label": "Shopping"
    },
    {
      "activeIcon": Icons.local_hospital_rounded,
      "inactiveIcon": Icons.local_hospital_rounded,
      "label": "Hospital"
    },
    {
      "activeIcon": Icons.person_rounded,
      "inactiveIcon": Icons.person_outline,
      "label": "Profile"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final controller = Get.find<DashBoardController>();

        if (controller.dashPage != 0) {
          controller.dashPage = 0;
          return;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Row(
                children: [
                  Icon(Icons.exit_to_app_rounded, color: Color(0xFF002060)),
                  SizedBox(width: 8),
                  Text(
                    "Exit App",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: const Text(
                "Do you want to exit the app?",
                style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text(
                    "No",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002060),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text(
                    "Yes",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );

        if (shouldExit == true) {
          try {
            await SystemNavigator.pop();
          } catch (_) {
            exit(0);
          }
        }
      },
      child: Scaffold(
        extendBody: true,
        body: GetBuilder<DashBoardController>(
          builder: (DashBoardController controller) {
            return [
              const AllCategoryHomeScreen(),
              const JobScreen(),
              const SizedBox(), // placeholder — Shopping navigates to EntryPoint
              const SizedBox(), // placeholder — Hospital navigates to HospitalDashboardScreen

              const ProfileScreen(),
            ][controller.dashPage];
          },
        ),
        bottomNavigationBar: GetBuilder<DashBoardController>(
          builder: (DashBoardController controller) {
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(
                      0xFFF0F4F8), // Light background like screenshot
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(items.length, (index) {
                    final bool isActive = controller.dashPage == index;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (index == 2) {
                            // Navigate to EntryPoint as a separate screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EntryPoint(),
                              ),
                            );
                            return;
                          }
                          if (index == 3) {
                            // Navigate to HospitalDashboardScreen as a separate screen

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const hospital.HospitalDashboardScreen(),
                              ),
                            );
                            return;
                          }

                          controller.dashPage = index;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF283593) // Primary color
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isActive
                                    ? items[index]["activeIcon"]
                                    : items[index]["inactiveIcon"],
                                size: 18,
                                color: isActive ? Colors.white : Colors.black87,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                items[index]["label"],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Helper(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 9,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: isActive
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
