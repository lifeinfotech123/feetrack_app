import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/widgets/animated_widgets.dart';

class HealthDocumentsScreen extends StatefulWidget {
  const HealthDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<HealthDocumentsScreen> createState() => _HealthDocumentsScreenState();
}

class _HealthDocumentsScreenState extends State<HealthDocumentsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Prescriptions', 'Lab Reports', 'Scans & X-Rays', 'Discharge Summary'];

  final List<Map<String, dynamic>> _docs = [
    {
      'title': 'Dr. Mohamed Saeed Prescription',
      'category': 'Prescriptions',
      'date': '14 Sep 2026',
      'size': '420 KB PDF',
      'icon': Icons.receipt_long,
      'color': primaryColor,
    },
    {
      'title': 'Complete Blood Count (CBC) Lab Report',
      'category': 'Lab Reports',
      'date': '12 Sep 2026',
      'size': '1.2 MB PDF',
      'icon': Icons.science,
      'color': diagnosticViolet,
    },
    {
      'title': 'Chest X-Ray Digital Scan',
      'category': 'Scans & X-Rays',
      'date': '04 Jun 2026',
      'size': '4.5 MB DICOM/JPG',
      'icon': Icons.biotech,
      'color': pharmacyTeal,
    },
    {
      'title': 'Day Care Surgical Discharge Summary',
      'category': 'Discharge Summary',
      'date': '18 Feb 2026',
      'size': '850 KB PDF',
      'icon': Icons.folder_shared,
      'color': ambulanceAmber,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn();

    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: const Text('Health Document Vault', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Browsing as Guest',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Please log in with your FeeTrack account to view and upload your prescription scans, lab reports and discharge summaries.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.login_rounded,
                      color: colorWhite, size: 18),
                  label: const Text(
                    'Log In to FeeTrack',
                    style: TextStyle(
                      color: colorWhite,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filtered = _docs.where((d) => _selectedCategory == 'All' || d['category'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Health Document Vault', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Category chips
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: colorWhite,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorWhite : textDark,
                    ),
                    selected: isSelected,
                    selectedColor: primaryColor,
                    backgroundColor: backgroundColor,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final doc = filtered[index];
                final Color color = doc['color'] as Color;

                return FadeSlideTransitionWidget(
                  index: index,
                  child: ModernCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                          child: Icon(doc['icon'], color: color, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                              const SizedBox(height: 2),
                              Text('${doc['category']} • ${doc['date']}', style: const TextStyle(fontSize: 11, color: textMuted)),
                              const SizedBox(height: 2),
                              Text(doc['size'], style: const TextStyle(fontSize: 10, color: primaryColor, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye_outlined, color: primaryColor),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(backgroundColor: primaryColor, content: Text('Opening ${doc['title']}...')),
                            );
                          },
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: primaryColor,
              content: Text('Document uploaded and safely encrypted in your health locker.'),
            ),
          );
        },
        icon: const Icon(Icons.upload_file, color: colorWhite),
        label: const Text('Upload Document', style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
