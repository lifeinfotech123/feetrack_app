import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../prescriptions/presentation/screen/digital_prescription_screen.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({Key? key}) : super(key: key);

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _visitsHistory = [
    {
      'date': '14 Sep 2026',
      'doctor': 'Dr. Mohamed Saeed',
      'specialty': 'Neurology',
      'hospital': 'City Care Hospital',
      'diagnosis': 'Migraine with Aura',
      'treatment': 'Prescribed preventive medication & lifestyle modification',
      'rxId': 'RX-2026-8941',
      'status': 'Completed',
    },
    {
      'date': '02 Aug 2026',
      'doctor': 'Dr. Sarah Jenkins',
      'specialty': 'Cardiology',
      'hospital': 'Apollo Medical Center',
      'diagnosis': 'Mild Hypertension',
      'treatment': 'ECG Normal, advised low sodium diet',
      'rxId': 'RX-2026-6412',
      'status': 'Follow-up done',
    },
    {
      'date': '15 May 2026',
      'doctor': 'Dr. Emily Watson',
      'specialty': 'General Medicine',
      'hospital': 'Global Health Clinic',
      'diagnosis': 'Acute Pharyngitis',
      'treatment': 'Antibiotic course completed',
      'rxId': 'RX-2026-1180',
      'status': 'Resolved',
    },
  ];

  final List<Map<String, String>> _vitals = [
    {'name': 'Blood Pressure', 'value': '120/80 mmHg', 'status': 'Normal', 'icon': 'favorite'},
    {'name': 'Heart Rate', 'value': '74 bpm', 'status': 'Normal', 'icon': 'monitor_heart'},
    {'name': 'Blood Glucose', 'value': '95 mg/dL', 'status': 'Fasting (Good)', 'icon': 'water_drop'},
    {'name': 'BMI', 'value': '22.4', 'status': 'Healthy Weight', 'icon': 'accessibility'},
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
          title: const Text('Medical Records (EHR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
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
                  'Please log in with your FeeTrack account to view your past diagnosis history, doctor prescriptions and vitals metrics.',
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Medical Records (EHR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Segmented Tab bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: primaryColor,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTab('Visit History', 0),
                  _buildTab('Vitals & Metrics', 1),
                ],
              ),
            ),
          ),

          Expanded(
            child: _selectedTabIndex == 0 ? _buildVisitsTimeline() : _buildVitalsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
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
              fontSize: 13,
              color: isSelected ? primaryColor : colorWhite,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitsTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visitsHistory.length,
      itemBuilder: (context, index) {
        final visit = _visitsHistory[index];
        return FadeSlideTransitionWidget(
          index: index,
          child: ModernCard(
            margin: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event_note, color: primaryColor, size: 18),
                        const SizedBox(width: 6),
                        Text(visit['date']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                      ],
                    ),
                    StatusBadgeWidget(label: visit['status']!, textColor: wellnessGreen, bgColor: wellnessGreenBg),
                  ],
                ),
                const Divider(height: 18),
                Text(visit['doctor']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                Text('${visit['specialty']} • ${visit['hospital']}', style: const TextStyle(color: primaryColor, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Diagnosis: ${visit['diagnosis']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark)),
                      const SizedBox(height: 2),
                      Text('Treatment: ${visit['treatment']}', style: const TextStyle(fontSize: 11, color: textMuted)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DigitalPrescriptionScreen(
                              rxId: visit['rxId']!,
                              doctorName: visit['doctor']!,
                              specialty: visit['specialty']!,
                              date: visit['date']!,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt_long, size: 14, color: primaryColor),
                      label: const Text('View Prescription', style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
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

  Widget _buildVitalsView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Latest Health Vitals'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          itemCount: _vitals.length,
          itemBuilder: (context, index) {
            final v = _vitals[index];
            return ModernCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        index == 0 ? Icons.favorite : index == 1 ? Icons.monitor_heart : index == 2 ? Icons.water_drop : Icons.accessibility_new,
                        color: index == 0 ? emergencyRed : index == 1 ? pharmacyTeal : index == 2 ? ambulanceAmber : careIndigo,
                        size: 24,
                      ),
                      StatusBadgeWidget(label: 'Normal', textColor: wellnessGreen, bgColor: wellnessGreenBg),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(v['name']!, style: const TextStyle(fontSize: 11, color: textMuted)),
                  const SizedBox(height: 2),
                  Text(v['value']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
