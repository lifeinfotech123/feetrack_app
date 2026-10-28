import 'package:flutter/material.dart';
import 'package:vlr/generated/assets.dart';
class HomeContainerWithImg extends StatelessWidget {
  const HomeContainerWithImg({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildCard(
              title: "Our Best\nGym",
              subtitle: "Find top gyms near you",
              imagePath: Assets.imagesGym,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildCard(
              title: "Book PG\nHostel",
              subtitle: "Affordable stays nearby",
              imagePath: Assets.imagesHostel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String imagePath,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF7FF),
            Color(0xFFD8F0FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          /// Image
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              imagePath,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),

          /// Title
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Text(
              title,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2937),
                height: 1.1,
              ),
            ),
          ),

          /// Decorative Circle
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}