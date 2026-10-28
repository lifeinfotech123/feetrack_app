import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';

class PhysiotherapyScreen extends StatefulWidget {
  const PhysiotherapyScreen({Key? key}) : super(key: key);

  @override
  State<PhysiotherapyScreen> createState() => _PhysiotherapyScreenState();
}

class _PhysiotherapyScreenState extends State<PhysiotherapyScreen> {
  String _mode = 'Home Visit Session';
  String _condition = 'Back / Neck Pain Rehab';

  final List<Map<String, dynamic>> _conditions = [
    {'title': 'Back / Neck Pain Rehab', 'sessions': 'Recommended: 5 sessions', 'icon': Icons.accessibility_new},
    {'title': 'Post-Surgical Joint Replacement', 'sessions': 'Knee / Hip Mobility rehab', 'icon': Icons.accessible_forward},
    {'title': 'Stroke & Neurological Rehab', 'sessions': 'Motor skill & gait training', 'icon': Icons.psychology},
    {'title': 'Sports Injury & Frozen Shoulder', 'sessions': 'Tendonitis & muscle strain recovery', 'icon': Icons.sports_gymnastics},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: wellnessGreen,
        elevation: 0,
        title: const Text('Physiotherapy Care', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode selector (Home vs Clinic)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: wellnessGreenBg, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: ['Home Visit Session', 'Hospital / Clinic Session'].map((m) {
                  final isSelected = _mode == m;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mode = m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? wellnessGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          m,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isSelected ? colorWhite : wellnessGreen,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Select Condition or Therapy'),
            ...List.generate(_conditions.length, (index) {
              final c = _conditions[index];
              final isSelected = _condition == c['title'];
              return FadeSlideTransitionWidget(
                index: index,
                child: ModernCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  border: Border.all(color: isSelected ? wellnessGreen : borderGrey, width: isSelected ? 2 : 1),
                  onTap: () => setState(() => _condition = c['title']),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: isSelected ? wellnessGreenBg : backgroundColor, borderRadius: BorderRadius.circular(12)),
                        child: Icon(c['icon'], color: isSelected ? wellnessGreen : textMuted, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                            const SizedBox(height: 2),
                            Text(c['sessions'], style: const TextStyle(fontSize: 11, color: textMuted)),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: c['title'],
                        groupValue: _condition,
                        activeColor: wellnessGreen,
                        onChanged: (val) => setState(() => _condition = val!),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            ModernCard(
              color: wellnessGreenBg,
              child: Row(
                children: const [
                  Icon(Icons.verified, color: wellnessGreen),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Includes electrotherapy modalities (TENS, IFT, Ultrasound) & therapeutic exercises.', style: TextStyle(fontSize: 11, color: textDark)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: wellnessGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: wellnessGreen,
                      content: Text('Physiotherapy session scheduled! Therapist will contact you.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Book Physiotherapy Session (\$35)', style: TextStyle(color: colorWhite, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
