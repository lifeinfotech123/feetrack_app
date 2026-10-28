import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';


class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({Key? key}) : super(key: key);

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  int _tabIndex = 0; // 0: Available Vaccines, 1: Immunization Passport / History

  final List<Map<String, dynamic>> _vaccines = [
    {
      'name': 'Influenza (Flu Quadrivalent)',
      'target': 'Adults & Children (Annual)',
      'doses': '1 Dose per year',
      'price': '\$25',
      'protectsAgainst': 'Seasonal Flu viruses (H1N1, H3N2)',
    },
    {
      'name': 'Hepatitis B Vaccine',
      'target': 'All age groups',
      'doses': '3 Dose series (0, 1, 6 mos)',
      'price': '\$30 / dose',
      'protectsAgainst': 'Chronic liver infections',
    },
    {
      'name': 'HPV Vaccine (Gardasil 9)',
      'target': 'Teens & Young Adults (Age 9-26)',
      'doses': '2 or 3 Doses',
      'price': '\$90 / dose',
      'protectsAgainst': 'Cervical & HPV-related cancers',
    },
    {
      'name': 'Pneumococcal Conjugate (Prevnar 20)',
      'target': 'Seniors 65+ & High Risk',
      'doses': 'Single dose booster',
      'price': '\$65',
      'protectsAgainst': 'Pneumonia & Meningitis',
    },
  ];

  final List<Map<String, String>> _history = [
    {'name': 'COVID-19 Booster (mRNA)', 'date': '10 Jan 2026', 'center': 'City Care Hospital', 'status': 'Completed'},
    {'name': 'Tetanus Toxoid (TT Booster)', 'date': '14 Aug 2025', 'center': 'Apollo Health Center', 'status': 'Completed'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: pharmacyTeal,
        elevation: 0,
        title: const Text('Vaccination Booking & Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: pharmacyTeal,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _buildTab('Schedule Vaccine', 0),
                  _buildTab('Digital Vaccine Passport', 1),
                ],
              ),
            ),
          ),
          Expanded(
            child: _tabIndex == 0 ? _buildVaccineCatalog() : _buildHistory(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isSelected ? pharmacyTeal : colorWhite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVaccineCatalog() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vaccines.length,
      itemBuilder: (context, index) {
        final v = _vaccines[index];
        return FadeSlideTransitionWidget(
          index: index,
          child: ModernCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(v['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                    ),
                    Text(v['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: pharmacyTeal)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Target: ${v['target']}', style: const TextStyle(color: primaryColor, fontSize: 12)),
                const SizedBox(height: 2),
                Text('Dosage schedule: ${v['doses']}', style: const TextStyle(color: textMuted, fontSize: 11)),
                const SizedBox(height: 4),
                Text('Protects against: ${v['protectsAgainst']}', style: const TextStyle(fontSize: 11, color: textDark, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pharmacyTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: pharmacyTeal,
                            content: Text('Vaccination appointment booked for ${v['name']}!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.vaccines, size: 16, color: colorWhite),
                      label: const Text('Book Slot', style: TextStyle(color: colorWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistory() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ModernCard(
          color: pharmacyTealBg,
          child: Row(
            children: const [
              Icon(Icons.qr_code, size: 40, color: pharmacyTeal),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Verified Digital Immunization Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: pharmacyTeal)),
                    Text('Universal QR code verified under WHO / MOH standards.', style: TextStyle(fontSize: 11, color: textDark)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._history.map((h) => ModernCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: wellnessGreenBg, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.verified, color: wellnessGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                        Text('${h['center']} • ${h['date']}', style: const TextStyle(color: textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.file_download_outlined, color: primaryColor),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vaccine certificate downloaded!'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
