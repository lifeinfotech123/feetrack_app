import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/core/widgets/animated_widgets.dart';

class HomeDoctorVisitScreen extends StatefulWidget {
  const HomeDoctorVisitScreen({Key? key}) : super(key: key);

  @override
  State<HomeDoctorVisitScreen> createState() => _HomeDoctorVisitScreenState();
}

class _HomeDoctorVisitScreenState extends State<HomeDoctorVisitScreen> {
  String _selectedSpecialty = 'General Physician';
  String _urgencyLevel = 'Standard (Within 2 hrs)';
  final TextEditingController _addressController = TextEditingController(text: 'Flat 402, Sunshine Heights, Main Road, Block B');
  final TextEditingController _symptomsController = TextEditingController();

  final List<Map<String, dynamic>> _specialties = [
    {'name': 'General Physician', 'icon': Icons.medical_services_outlined},
    {'name': 'Pediatrician', 'icon': Icons.child_care_outlined},
    {'name': 'Geriatrician (Senior Care)', 'icon': Icons.elderly_outlined},
    {'name': 'Orthopedist', 'icon': Icons.healing_outlined},
    {'name': 'Cardiologist', 'icon': Icons.favorite_border_outlined},
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Home Doctor Visit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.home_work_outlined, color: colorWhite, size: 36),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Doctor At Your Doorstep', style: TextStyle(color: colorWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Verified certified physicians visit your home with essential diagnostic kits.', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Select Doctor Specialty'),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _specialties.length,
                    itemBuilder: (context, index) {
                      final spec = _specialties[index];
                      final isSelected = _selectedSpecialty == spec['name'];
                      return AnimatedPressable(
                        onTap: () => setState(() => _selectedSpecialty = spec['name']),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? primaryColor : borderGrey,
                              width: isSelected ? 2 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? primaryColor : borderGrey,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 7,
                                            height: 7,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: primaryColor,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Icon(
                                      spec['icon'],
                                      color: isSelected ? primaryColor : textMuted,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      spec['name'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                        color: isSelected ? primaryColor : textDark,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Patient Location & Address'),
                  ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: primaryColor, size: 20),
                            SizedBox(width: 8),
                            Text('Home Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _addressController,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: backgroundColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Symptoms / Special Notes'),
                  ModernCard(
                    child: TextField(
                      controller: _symptomsController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Describe patient conditions (e.g. fever for 2 days, difficulty walking)...',
                        hintStyle: TextStyle(fontSize: 12, color: textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SectionHeader(title: 'Visit Urgency & Arrival'),
                  ModernCard(
                    child: Column(
                      children: [
                        _buildUrgencyOption('Standard (Within 2 hrs)', '\$60', Icons.schedule),
                        const Divider(),
                        _buildUrgencyOption('Urgent Express (Within 45 mins)', '\$85', Icons.bolt),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: wellnessGreen,
                            content: Text('Doctor visit request confirmed! A physician will be assigned shortly.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Confirm Doctor Home Visit', style: TextStyle(color: colorWhite, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgencyOption(String title, String price, IconData icon) {
    final isSelected = _urgencyLevel == title;
    return InkWell(
      onTap: () => setState(() => _urgencyLevel = title),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? primaryColor : colorGrey, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
            ),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
            Radio<String>(
              value: title,
              groupValue: _urgencyLevel,
              activeColor: primaryColor,
              onChanged: (val) => setState(() => _urgencyLevel = val!),
            ),
          ],
        ),
      ),
    );
  }
}
