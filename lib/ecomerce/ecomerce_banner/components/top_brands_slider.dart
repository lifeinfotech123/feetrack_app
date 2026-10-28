import 'package:flutter/material.dart';

import '../../components/network_image_with_loader.dart';
import '../../constants.dart';
import '../../route/route_constants.dart';


class TopBrandModel {
  final String name;
  final String image;
  final String offer;
  final String category;

  const TopBrandModel({
    required this.name,
    required this.image,
    required this.offer,
    required this.category,
  });
}

const List<TopBrandModel> demoTopBrands = [
  TopBrandModel(
    name: "I love honey chilli potato",
    image: "https://images.unsplash.com/photo-1518013031107-fe82f77b515d?auto=format&fit=crop&w=800&q=85",
    offer: "HOT & SPICY 🌶️",
    category: "Crispy Potato Delight",
  ),
  TopBrandModel(
    name: "I love honey chilli potato",
    image: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=85",
    offer: "SPECIAL 50% OFF",
    category: "Sweet & Spicy",
  ),
  TopBrandModel(
    name: "I love honey chilli potato",
    image: "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=800&q=85",
    offer: "FRESH & CRISPY",
    category: "Favorite Snack",
  ),
  TopBrandModel(
    name: "I love honey chilli potato",
    image: "https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=800&q=85",
    offer: "BEST SELLER 🥔",
    category: "Hot Food Express",
  ),
];

class TopBrandsSlider extends StatelessWidget {
  const TopBrandsSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const accentBlue = Color(0xFF2962FF); // Electric Royal Blue

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.fastfood_rounded,
                    color: accentBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "I love honey chilli potato",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, onSaleScreenRoute);
              },
              child: const Text(
                "View All",
                style: TextStyle(
                  color: accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: defaultPadding / 1.5),

        // Horizontal Slider of Full-Cover HD Cards
        SizedBox(
          height: 155,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: demoTopBrands.length,
            itemBuilder: (context, index) {
              final brand = demoTopBrands[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, onSaleScreenRoute);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 145,
                    height: 155,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // 1. FULL CARD HD BACKGROUND IMAGE
                          Positioned.fill(
                            child: NetworkImageWithLoader(
                              brand.image,
                              radius: 16,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // 2. GRADIENT OVERLAY FOR READABILITY
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.35),
                                    Colors.black.withValues(alpha: 0.88),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.2, 0.6, 1.0],
                                ),
                              ),
                            ),
                          ),

                          // 3. TOP-LEFT OFFER BADGE CHIP
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: accentBlue,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentBlue.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                brand.offer,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ),

                          // 4. BOTTOM NAME & CATEGORY SUBTITLE
                          Positioned(
                            bottom: 10,
                            left: 10,
                            right: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  brand.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  brand.category,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
            },
          ),
        ),
      ],
    );
  }
}
