import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../doctor/data/model/doctor_model.dart';
import '../../../doctor/logics/doctor_controller.dart';
import '../../../doctor/presentation/screens/doctor_detail_screen.dart';
import '../../../doctor/presentation/screens/doctor_screen.dart';

class DoctorListSection extends StatelessWidget {
  const DoctorListSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DoctorController controller = Get.isRegistered<DoctorController>()
        ? Get.find<DoctorController>()
        : Get.put(DoctorController());

    return Obx(() {
      final doctorsList = controller.rawDoctors;
      if (controller.isLoadingDoctors.value && doctorsList.isEmpty) {
        return const SizedBox.shrink();
      }

      if (doctorsList.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Doctors',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DoctorScreen()),
                  );
                },
                child: Text(
                  'View all',
                  style: TextStyle(color: primaryColor, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: doctorsList.length,
              itemBuilder: (context, index) {
                final doctor = doctorsList[index];
                final String name = doctor['name']?.toString() ?? 'Doctor';
                final String specialty =
                    doctor['specialist']?['name']?.toString() ?? 'Specialist';
                final String photoUrl = DoctorModel.resolveDoctorPhoto(
                  photo: doctor['photo'] ?? doctor['image'] ?? doctor['profile_photo'],
                  domain: doctor['hospital']?['domain']?.toString(),
                  gender: doctor['gender']?.toString(),
                );
                final String rating = doctor['rating']?.toString() ?? '4.5';
                final String reviews =
                    doctor['rating_count']?.toString() ?? doctor['reviews']?.toString() ?? '120';

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorDetailScreen(
                          name: name,
                          specialty: specialty,
                          doctorName: name,
                          hospital: doctor['hospital']?['name']?.toString(),
                          rating: doctor['rating'],
                          reviewsCount: doctor['rating_count'] ?? doctor['reviews'],
                          doctorData: doctor,
                          doctorId: doctor['id'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderGrey, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(15)),
                                child: Image.network(
                                  photoUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.network(
                                    DoctorModel.resolveDoctorPhoto(
                                        photo: null,
                                        gender: doctor['gender']?.toString()),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.blue.shade100,
                                      child: const Icon(Icons.person,
                                          size: 40, color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ),
                              // Rating Chip
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 12),
                                      const SizedBox(width: 3),
                                      Text(
                                        rating,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.favorite_border,
                                      color: primaryColor, size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                specialty,
                                style: const TextStyle(
                                  color: textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$reviews Reviews',
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
