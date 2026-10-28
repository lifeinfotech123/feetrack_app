import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../../ecomerce/constants.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';


class BannerWidget extends StatefulWidget {
  const BannerWidget({Key? key}) : super(key: key);

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final List<String> doctorImages = [
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1538108149393-fbbd81895907?auto=format&fit=crop&w=900&q=80',
    'https://images.unsplash.com/photo-1651008376811-b90baee60c1f?auto=format&fit=crop&w=900&q=80',
  ];

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Background decoration
          Positioned(
            right: -30,
            bottom: -50,
            child: CircleAvatar(
              radius: 110,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),

          // Doctor Image Carousel
          Positioned(
            right: -10,
            bottom: 0,
            child: SizedBox(
              width: 160,
              height: 150,
              child: CarouselSlider.builder(
                itemCount: doctorImages.length,
                options: CarouselOptions(
                  height: 150,
                  viewportFraction: 1,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration:
                  const Duration(milliseconds: 800),
                  enlargeCenterPage: false,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return Image.network(
                    doctorImages[index],
                    height: 150,
                    width: 160,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 70,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Gradient overlay
          Positioned(
            right: 130,
            top: 0,
            bottom: 0,
            width: 70,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.7),
                    primaryColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 190,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Trusted doctors on your schedule',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Your Health In Safe\nHands',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      // Overlapping avatars
                      SizedBox(
                        width: 50,
                        height: 25,
                        child: Stack(
                          children: [
                            _avatar(
                              'https://i.pravatar.cc/100?u=doctor1',
                              0,
                            ),
                            _avatar(
                              'https://i.pravatar.cc/100?u=doctor2',
                              12,
                            ),
                            _avatar(
                              'https://i.pravatar.cc/100?u=doctor3',
                              24,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '30.000+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Happy Patients',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Carousel indicators
          Positioned(
            left: 16,
            bottom: 7,
            child: Row(
              children: List.generate(
                doctorImages.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 4),
                  height: 4,
                  width: currentIndex == index ? 14 : 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      currentIndex == index ? 0.9 : 0.4,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String imageUrl, double left) {
    return Positioned(
      left: left,
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.white,
        child: CircleAvatar(
          radius: 10,
          backgroundImage: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}


