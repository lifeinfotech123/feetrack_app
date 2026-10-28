import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';


class BedAdmissionScreen extends StatefulWidget {
  const BedAdmissionScreen({Key? key}) : super(key: key);

  @override
  State<BedAdmissionScreen> createState() => _BedAdmissionScreenState();
}

class _BedAdmissionScreenState extends State<BedAdmissionScreen> {
  String _selectedRoom = 'Single Private Deluxe';
  String _admissionType = 'Planned Surgery / Procedure';
  final TextEditingController _hospitalCtrl = TextEditingController(text: 'City Care Multi-Specialty Hospital');


  final TextEditingController _doctorCtrl = TextEditingController(text: 'Dr. Mohamed Saeed');
  final TextEditingController _notesCtrl = TextEditingController();

  final List<Map<String, dynamic>> _rooms = [
    {
      'title': 'General Ward (Shared)', 
      'price': '\$35 / day', 
      'features': 'Nurse call button, basic amenities', 
      'image': 'https://images.unsplash.com/photo-1516549655169-df83a0774514?q=80&w=200&auto=format&fit=crop'
    },
    {
      'title': 'Semi-Private (Twin)', 
      'price': '\$75 / day', 
      'features': 'Attached restroom, TV, couch', 
      'image': 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?q=80&w=200&auto=format&fit=crop'
    },
    {
      'title': 'Single Private Deluxe', 
      'price': '\$140 / day', 
      'features': 'AC, Sofa cum bed, Refrigerator', 
      'image': 'https://images.unsplash.com/photo-1586773860418-d37222d8fce2?q=80&w=200&auto=format&fit=crop'
    },
    {
      'title': 'Critical Care ICU Bed', 
      'price': '\$250 / day', 
      'features': '1:1 Nurse, Ventilator support', 
      'image': 'https://images.unsplash.com/photo-1516549589363-4ef1a86d2572?q=80&w=200&auto=format&fit=crop'
    },
  ];

  @override
  void dispose() {
    _hospitalCtrl.dispose();
    _doctorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Hospital Bed & Admission Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorWhite)),
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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: primaryColor),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Pre-book admission bed with cashless insurance pre-authorization support.', style: TextStyle(fontSize: 12, color: primaryDark)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Admission Type'),
            ModernCard(
              child: Column(
                children: ['Planned Surgery / Procedure', 'Emergency / Acute Condition', 'Maternity / Delivery'].map((type) {
                  return RadioListTile<String>(
                    value: type,
                    groupValue: _admissionType,
                    activeColor: primaryColor,
                    title: Text(type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    onChanged: (val) => setState(() => _admissionType = val!),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Select Room Category'),
            ...List.generate(_rooms.length, (index) {
              final r = _rooms[index];
              final isSelected = _selectedRoom == r['title'];
              return FadeSlideTransitionWidget(
                index: index,
                child: ModernCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.zero,
                  border: Border.all(color: isSelected ? primaryColor : borderGrey, width: isSelected ? 2 : 1),
                  onTap: () => setState(() => _selectedRoom = r['title']),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                        child: Image.network(
                          r['image'],
                          width: 100,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(r['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                                  ),
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(Icons.check_circle, color: primaryColor, size: 18),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(r['features'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: textMuted)),
                              const SizedBox(height: 6),
                              Text(r['price'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            const SectionHeader(title: 'Hospital & Doctor Details'),
            ModernCard(
              child: Column(
                children: [
                  TextField(
                    controller: _hospitalCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Hospital Name', prefixIcon: Icon(Icons.apartment, color: primaryColor)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _doctorCtrl,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(labelText: 'Referring Doctor', prefixIcon: Icon(Icons.person, color: primaryColor)),
                  ),
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
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: primaryColor,
                      content: Text('Admission enquiry submitted! Hospital admission desk will contact you with bed allotment details.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Submit Bed Request', style: TextStyle(color: colorWhite, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
