import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../data/hospital_services_data.dart';

class HomeActionWidget extends StatefulWidget {
  const HomeActionWidget({Key? key}) : super(key: key);

  @override
  State<HomeActionWidget> createState() => _HomeActionWidgetState();
}

class _HomeActionWidgetState extends State<HomeActionWidget> {
  bool _isExpanded = false;
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final displayedServices = _isExpanded
        ? (_selectedCategory == 'All'
            ? hospitalAllServices
            : hospitalAllServices
                .where((s) => s['category'] == _selectedCategory)
                .toList())
        : hospitalAllServices.take(8).toList();

    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGrey.withValues(alpha: 0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // If expanded, show quick category filter tabs
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.grid_view_rounded,
                        color: primaryColor, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'All Healthcare Services',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${displayedServices.length} items',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 4-Column Grid of Healthcare Services
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedServices.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.80,
                ),
                itemBuilder: (context, index) {
                  final item = displayedServices[index];
                  return _buildServiceItem(context, item);
                },
              ),
            ),
          ),

          // Bottom Expand / Collapse Handle & Notch
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (!_isExpanded) {
                  _selectedCategory = 'All';
                }
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color:
                    _isExpanded ? cardColor.withValues(alpha: 0.5) : colorWhite,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: borderGrey.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isExpanded ? 'Show Less' : 'Explore All Services',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: primaryColor,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, Map<String, dynamic> item) {
    final Color color = item['color'] as Color;
    final IconData icon = item['icon'] as IconData;
    final String title = (item['gridTitle'] ?? item['title']) as String;
    final String? badge = item['badge'] as String?;
    final Widget? screen = item['screen'] as Widget?;

    return AnimatedPressable(
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Container with 3D/duotone look & optional badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF4F9FF),
                      Color(0xFFE8F1FC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFD1E4FA),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.9),
                      blurRadius: 2,
                      offset: const Offset(-1, -1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: 26,
                  ),
                ),
              ),
              // Badge if present
              if (badge != null)
                Positioned(
                  top: -5,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: badge == 'SOS' || badge == '24/7'
                          ? emergencyRed
                          : (badge == 'LIVE'
                              ? const Color(0xFF00C853)
                              : primaryColor),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: colorWhite,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Service Title (Centered, 2 lines)
          Flexible(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textDark,
                height: 1.15,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
