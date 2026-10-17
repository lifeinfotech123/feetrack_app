import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';

class HomeSampleCollectionScreen extends StatefulWidget {
  final List<String> selectedTestNames;
  final int totalPrice;

  const HomeSampleCollectionScreen({
    super.key,
    this.selectedTestNames = const ['Diagnostic Pathology Examination'],
    this.totalPrice = 150,
  });

  @override
  State<HomeSampleCollectionScreen> createState() => _HomeSampleCollectionScreenState();
}

class _HomeSampleCollectionScreenState extends State<HomeSampleCollectionScreen> {
  String _selectedSlot = 'Tomorrow, 07:00 AM - 08:00 AM (Fasting Slot)';
  late final TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final userAddress = authCtrl?.address1Controller.text.isNotEmpty == true
        ? authCtrl!.address1Controller.text
        : '';
    _addressCtrl = TextEditingController(text: userAddress);
  }

  final List<String> _slots = [
    'Tomorrow, 06:30 AM - 07:30 AM (Fasting Slot)',
    'Tomorrow, 07:30 AM - 08:30 AM (Fasting Slot)',
    'Tomorrow, 09:00 AM - 10:00 AM',
    'Tomorrow, 04:00 PM - 05:00 PM',
  ];

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: diagnosticViolet,
        elevation: 0,
        title: const Text('Home Sample Collection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
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
            // Safe Phlebotomist Guarantee Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: diagnosticVioletBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: diagnosticViolet.withOpacity(0.2)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.verified_user, color: diagnosticViolet, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('100% Safe & Certified Phlebotomist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: diagnosticViolet)),
                        Text('Temperature-controlled sample transit & 1-time sterile sealed kits.', style: TextStyle(fontSize: 11, color: textMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Selected Tests For Collection'),
            ModernCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.selectedTestNames.map((test) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, size: 16, color: diagnosticViolet),
                            const SizedBox(width: 8),
                            Expanded(child: Text(test, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                          ],
                        ),
                      )),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Home Collection Charges', style: TextStyle(fontSize: 12, color: textMuted)),
                      const Text('FREE', style: TextStyle(color: wellnessGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('\$${widget.totalPrice}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Select Collection Time Slot'),
            ModernCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: _slots.map((slot) {
                  return RadioListTile<String>(
                    value: slot,
                    groupValue: _selectedSlot,
                    activeColor: diagnosticViolet,
                    title: Text(slot, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    onChanged: (val) => setState(() => _selectedSlot = val!),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Collection Address'),
            ModernCard(
              child: TextField(
                controller: _addressCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.home_outlined, color: diagnosticViolet),
                  filled: true,
                  fillColor: backgroundColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: diagnosticViolet,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: diagnosticViolet,
                      content: Text('Sample collection scheduled! Phlebotomist will arrive on chosen slot.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Confirm Home Collection Booking', style: TextStyle(color: colorWhite, fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
