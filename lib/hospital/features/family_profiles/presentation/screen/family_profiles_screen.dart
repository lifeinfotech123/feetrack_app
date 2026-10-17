import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

import '../../../../../ecomerce/constants.dart';
import '../../../../core/constants/colors.dart' hide primaryColor;
import '../../../../core/widgets/animated_widgets.dart';

class FamilyProfilesScreen extends StatefulWidget {
  const FamilyProfilesScreen({Key? key}) : super(key: key);

  @override
  State<FamilyProfilesScreen> createState() => _FamilyProfilesScreenState();
}

class _FamilyProfilesScreenState extends State<FamilyProfilesScreen> {
  String _activeMemberId = '1';

  @override
  void initState() {
    super.initState();
    final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final userName = (authCtrl?.isLoggedIn() ?? false) ? (authCtrl?.userModel?.name ?? 'User') : 'Guest';
    _members[0]['name'] = userName;
  }

  final List<Map<String, dynamic>> _members = [
    {
      'id': '1',
      'name': 'Primary Member',
      'relation': 'Self (Primary)',
      'age': '28 Yrs',
      'gender': 'Male',
      'bloodGroup': 'O+ve',
      'avatarColor': primaryColor,
    },
    {
      'id': '2',
      'name': 'Fatima Ahmed',
      'relation': 'Spouse',
      'age': '26 Yrs',
      'gender': 'Female',
      'bloodGroup': 'B+ve',
      'avatarColor': diagnosticViolet,
    },
    {
      'id': '3',
      'name': 'Zayan Ahmed',
      'relation': 'Son (Child)',
      'age': '3 Yrs',
      'gender': 'Male',
      'bloodGroup': 'O+ve',
      'avatarColor': wellnessGreen,
    },
    {
      'id': '4',
      'name': 'Mohamed Ali',
      'relation': 'Father (Senior)',
      'age': '62 Yrs',
      'gender': 'Male',
      'bloodGroup': 'A+ve',
      'avatarColor': ambulanceAmber,
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
          title: const Text('Family Members & Dependents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorWhite)),
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
                  'Please log in with your FeeTrack account to manage dependent profiles and family healthcare records.',
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
        title: const Text('Family Members & Dependents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: colorWhite)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: fillColor, borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.family_restroom, color: primaryColor, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Easily book appointments, tests & store health records for your entire family.', style: TextStyle(fontSize: 11, color: textDark)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SectionHeader(title: 'Active Family Profiles'),
            ..._members.map((member) {
              final isActive = _activeMemberId == member['id'];
              final Color color = member['avatarColor'] as Color;

              return ModernCard(
                margin: const EdgeInsets.only(bottom: 12),
                border: Border.all(color: isActive ? primaryColor : borderGrey, width: isActive ? 2 : 1),
                onTap: () => setState(() => _activeMemberId = member['id']),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: color.withOpacity(0.2),
                      child: Text(
                        member['name'].toString().substring(0, 1),
                        style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                              if (isActive) ...[
                                const SizedBox(width: 6),
                                StatusBadgeWidget(label: 'Active Patient', textColor: primaryColor, bgColor: fillColor),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${member['relation']} • ${member['age']} • ${member['gender']}', style: const TextStyle(fontSize: 11, color: textMuted)),
                          const SizedBox(height: 2),
                          Text('Blood Group: ${member['bloodGroup']}', style: const TextStyle(fontSize: 11, color: emergencyRed, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: member['id'],
                      groupValue: _activeMemberId,
                      activeColor: primaryColor,
                      onChanged: (val) => setState(() => _activeMemberId = val!),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: primaryColor, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  _showAddMemberDialog(context);
                },
                icon: const Icon(Icons.person_add_alt_1, color: primaryColor),
                label: const Text('Add New Family Member', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String relation = 'Child';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Add Family Member', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: relation,
              decoration: const InputDecoration(labelText: 'Relationship'),
              items: ['Child', 'Spouse', 'Parent', 'Sibling', 'Other'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => relation = val ?? 'Child',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _members.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameCtrl.text.trim(),
                    'relation': relation,
                    'age': '22 Yrs',
                    'gender': 'Male',
                    'bloodGroup': 'B+ve',
                    'avatarColor': primaryColor,
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: wellnessGreen, content: Text('Family profile added successfully!')),
                );
              }
            },
            child: const Text('Add Profile', style: TextStyle(color: colorWhite)),
          ),
        ],
      ),
    );
  }
}
