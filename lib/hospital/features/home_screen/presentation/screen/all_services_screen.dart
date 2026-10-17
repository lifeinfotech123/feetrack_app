import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../data/hospital_services_data.dart';

class AllServicesScreen extends StatefulWidget {
  const AllServicesScreen({Key? key}) : super(key: key);

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = hospitalAllServices.where((s) {
      final matchQuery = s['title']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (s['desc'] ?? '')
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchCat =
          _selectedCategory == 'All' || s['category'] == _selectedCategory;
      return matchQuery && matchCat;
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          'All Healthcare Services',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorWhite,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header search & category chips
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            color: primaryColor,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search across all 35 healthcare services...',
                    hintStyle: const TextStyle(fontSize: 13, color: textMuted),
                    prefixIcon: const Icon(Icons.search, color: primaryColor),
                    filled: true,
                    fillColor: colorWhite,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: hospitalServiceCategories.length,
                    itemBuilder: (context, index) {
                      final cat = hospitalServiceCategories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? primaryColor : colorWhite,
                          ),
                          selected: isSelected,
                          selectedColor: colorWhite,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          checkmarkColor: primaryColor,
                          onSelected: (val) =>
                              setState(() => _selectedCategory = cat),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Services Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final s = filtered[index];
                final Color color = s['color'] as Color;

                return FadeSlideTransitionWidget(
                  index: index,
                  child: ModernCard(
                    padding: const EdgeInsets.all(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => s['screen'] as Widget,
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                s['icon'] as IconData,
                                color: color,
                                size: 22,
                              ),
                            ),
                            Text(
                              '#${s['id']}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          s['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (s['desc'] ?? '') as String,
                          style: const TextStyle(
                            fontSize: 10,
                            color: textMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
