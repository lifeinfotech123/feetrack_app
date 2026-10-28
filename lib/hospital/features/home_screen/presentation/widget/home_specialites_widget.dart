import 'package:flutter/material.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../doctor/presentation/screens/doctor_screen.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/features/doctor/presentation/screens/doctor_screen.dart';

class HomeSpecialitesWidget extends StatelessWidget {
  const HomeSpecialitesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> specialties = [
      {'name': 'Neurology', 'icon': Icons.psychology},
      {'name': 'Phoniatrics', 'icon': Icons.record_voice_over},
      {'name': 'Endocrinology', 'icon': Icons.opacity},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Specialties',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorScreen(initialSpecialty: 'All'),
                  ),
                );
              },
              child: const Text(
                'View all',
                style: TextStyle(color: primaryColor, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: specialties.length,
            itemBuilder: (context, index) {
              final specialtyName = specialties[index]['name'];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorScreen(initialSpecialty: specialtyName),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(specialties[index]['icon'], color: Colors.black, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        specialtyName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
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
  }
}
