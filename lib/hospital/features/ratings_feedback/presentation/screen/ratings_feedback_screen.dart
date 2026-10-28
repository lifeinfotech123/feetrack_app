import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';


class RatingsFeedbackScreen extends StatefulWidget {
  const RatingsFeedbackScreen({Key? key}) : super(key: key);

  @override
  State<RatingsFeedbackScreen> createState() => _RatingsFeedbackScreenState();
}

class _RatingsFeedbackScreenState extends State<RatingsFeedbackScreen> {
  int _doctorRating = 5;
  int _hospitalRating = 5;
  final TextEditingController _feedbackCtrl = TextEditingController();
  final Set<String> _selectedTags = {'Punctual Doctor', 'Clear Explanation'};

  final List<String> _tags = [
    'Punctual Doctor',
    'Clear Explanation',
    'Friendly Staff',
    'Clean Environment',
    'Quick Lab Processing',
    'Helpful Care Attendant',
  ];

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text('Rate Your Healthcare Experience', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorWhite)),
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
            // Completed service card
            ModernCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: fillColor,
                    child: Icon(Icons.person, color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Dr. Mohamed Saeed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                        Text('Neurology Consultation • City Care Hospital', style: TextStyle(fontSize: 11, color: textMuted)),
                        Text('Visit Date: 14 Sep 2026', style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Doctor Consultation Rating'),
            ModernCard(
              child: Column(
                children: [
                  const Text('How satisfied were you with the doctor’s advice?', style: TextStyle(fontSize: 12, color: textMuted)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        icon: Icon(
                          star <= _doctorRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 34,
                        ),
                        onPressed: () => setState(() => _doctorRating = star),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Hospital & Staff Rating'),
            ModernCard(
              child: Column(
                children: [
                  const Text('Hospital cleanliness, staff friendliness and waiting time', style: TextStyle(fontSize: 12, color: textMuted)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        icon: Icon(
                          star <= _hospitalRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: primaryColor,
                          size: 30,
                        ),
                        onPressed: () => setState(() => _hospitalRating = star),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'What went well? (Feedback Tags)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? primaryColor : textDark,
                  ),
                  selected: isSelected,
                  selectedColor: fillColor,
                  backgroundColor: colorWhite,
                  checkmarkColor: primaryColor,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Write a Detailed Review'),
            ModernCard(
              child: TextField(
                controller: _feedbackCtrl,
                maxLines: 4,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Share your experience to help other patients make informed healthcare decisions...',
                  hintStyle: TextStyle(fontSize: 12, color: textMuted),
                  border: InputBorder.none,
                ),
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
                      content: Text('Thank you! Your verified rating and feedback have been submitted.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Submit Rating & Review', style: TextStyle(color: colorWhite, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
