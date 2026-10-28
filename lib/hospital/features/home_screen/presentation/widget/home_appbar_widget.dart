import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/views/screens/notification/notification_screen.dart';

import '../../../../core/constants/colors.dart';
import '../../../profile/logics/hospital_profile_controller.dart';
import '../../../profile_health_id/presentation/screen/profile_health_id_screen.dart';

class HomeAppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);
    final profileCtrl = Get.isRegistered<HospitalProfileController>()
        ? Get.find<HospitalProfileController>()
        : Get.put(HospitalProfileController());

    return AppBar(
      backgroundColor: colorWhite,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: textDark, size: 19),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      titleSpacing: canPop ? 0 : 16,
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileHealthIdScreen(
                patientName: profileCtrl.displayName,
                healthId: profileCtrl.patientId,
              ),
            ),
          );
        },
        child: Obx(() {
          // Explicitly touch reactive variables so Obx always has an active listener
          profileCtrl.patient.value;
          profileCtrl.isLoading.value;
          final displayName = profileCtrl.displayName;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '👋 Hi, $displayName',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: const BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: textDark, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen()),
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: emergencyRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
