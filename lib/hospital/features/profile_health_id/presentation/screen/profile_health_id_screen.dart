import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';

class ProfileHealthIdScreen extends StatelessWidget {
  final String patientName;
  final String healthId;

  const ProfileHealthIdScreen({
    Key? key,
    this.patientName = 'Guest',
    this.healthId = 'N/A',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isGuest = patientName == 'Guest' || healthId == 'N/A' || healthId.isEmpty;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Digital Health ID & Card',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: colorWhite),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Health ID card QR shared!'),
                    behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ABHA / National Health Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.health_and_safety,
                              color: Colors.greenAccent, size: 24),
                          SizedBox(width: 8),
                          Text('NATIONAL HEALTH ID',
                              style: TextStyle(
                                  color: colorWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.2)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: (isGuest ? Colors.orange : Colors.green).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(isGuest ? 'GUEST' : 'ACTIVE',
                            style: TextStyle(
                                color: isGuest ? Colors.orangeAccent : Colors.greenAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: colorWhite,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.qr_code_2,
                            size: 65, color: textDark),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patientName,
                                style: const TextStyle(
                                    color: colorWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(isGuest ? 'No ABHA ID linked' : healthId,
                                style: const TextStyle(
                                    color: primaryLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.1)),
                            const SizedBox(height: 6),
                            Text(isGuest ? 'Status: Unauthenticated' : 'DOB: 12 Jun 1998 • Male',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                            Text(isGuest ? 'Blood Group: Not Provided' : 'Blood Group: O +ve',
                                style: TextStyle(
                                    color: isGuest ? Colors.white60 : Colors.redAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Emergency Medical Identifiers'),

            ModernCard(
              child: Column(
                children: [
                  _buildMedicalInfoRow(
                      'Allergies', isGuest ? 'None recorded' : 'Penicillin, Dust / Pollen'),
                  const Divider(),
                  _buildMedicalInfoRow('Chronic Conditions', isGuest ? 'None recorded' : 'Mild Migraine'),
                  const Divider(),
                  _buildMedicalInfoRow(
                      'Emergency ICE Contact', isGuest ? 'Not provided' : '+1 (555) 019-2834 (Spouse)'),
                  const Divider(),
                  _buildMedicalInfoRow(
                      'Organ Donor Registered', isGuest ? 'Not registered' : 'YES (Organ Donor #OD-9921)'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: primaryColor,
                      content:
                          Text('Health ID Card PDF downloaded to your files.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.download, color: colorWhite),
                label: const Text('Download Digital Health Card',
                    style: TextStyle(
                        color: colorWhite, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, color: textMuted))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textDark))),
        ],
      ),
    );
  }
}
