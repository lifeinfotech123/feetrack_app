import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/gym_controller.dart';
import 'package:vlr/services/theme.dart';

class GymMembershipActivationScreen extends StatefulWidget {
  final String membershipId;
  final String gymTitle;
  final String gymAddress;
  final String packageName;
  final String trainerName;
  final String trainerSchedule;
  final String registeredMobile;
  final String initialStatus;

  const GymMembershipActivationScreen({
    super.key,
    required this.membershipId,
    required this.gymTitle,
    required this.gymAddress,
    required this.packageName,
    required this.trainerName,
    required this.trainerSchedule,
    required this.registeredMobile,
    required this.initialStatus,
  });

  @override
  State<GymMembershipActivationScreen> createState() =>
      _GymMembershipActivationScreenState();
}

class _GymMembershipActivationScreenState
    extends State<GymMembershipActivationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _verificationUnavailable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<GymController>().fetchMyGymBookings();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  String _statusFor(Map<String, dynamic>? membership) {
    final rawStatus = (membership?['activation_status'] ??
            membership?['membership_status'] ??
            membership?['status'] ??
            widget.initialStatus)
        .toString()
        .toLowerCase()
        .replaceAll('-', '_');

    return switch (rawStatus) {
      'active' => 'Active',
      'expired' => 'Expired',
      'inactive' => 'Inactive',
      'completed' ||
      'pending' ||
      'pending_otp' ||
      'pending_activation' =>
        'Pending Activation',
      _ => rawStatus.replaceAll('_', ' ').toUpperCase(),
    };
  }

  Map<String, dynamic>? _findMembership(List<dynamic> memberships) {
    for (final item in memberships) {
      if (item is! Map) continue;
      final membership = Map<String, dynamic>.from(item);
      if (membership['membership_id']?.toString() == widget.membershipId ||
          membership['booking_id']?.toString() == widget.membershipId) {
        return membership;
      }
    }
    return null;
  }

  String _maskedMobile() {
    final digits = widget.registeredMobile.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    final visibleDigits =
        digits.length <= 4 ? digits : digits.substring(digits.length - 4);
    return '•••• $visibleDigits';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Activate Membership'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17233D),
      ),
      body: GetBuilder<GymController>(
        builder: (controller) {
          final membership = _findMembership(controller.myGymMembershipsList);
          final status = _statusFor(membership);
          final isActive = status.toLowerCase() == 'active';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.gymTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (widget.gymAddress.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.gymAddress,
                        style: TextStyle(color: greyText3),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      widget.packageName,
                      style: TextStyle(color: greyText3),
                    ),
                    if (widget.trainerName.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Trainer: ${widget.trainerName}',
                        style: TextStyle(color: greyText3),
                      ),
                    ],
                    if (widget.trainerSchedule.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Schedule: ${widget.trainerSchedule}',
                        style: TextStyle(color: greyText3),
                      ),
                    ],
                    const SizedBox(height: 8),
                    SelectableText(
                      'Membership ID: ${widget.membershipId}',
                      style: TextStyle(color: greyText3, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text(
                          controller.isMyGymBookingsLoading
                              ? 'Refreshing…'
                              : status,
                          style: TextStyle(
                            color: isActive
                                ? Colors.green.shade700
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh status',
                          onPressed: controller.isMyGymBookingsLoading
                              ? null
                              : controller.fetchMyGymBookings,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    if (controller.myGymBookingsError != null)
                      Text(
                        controller.myGymBookingsError!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_maskedMobile().isNotEmpty) ...[
                Text(
                  'Enter the OTP received on ${_maskedMobile()}',
                  style: TextStyle(color: greyText3),
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Activation OTP',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: isActive
                      ? null
                      : () {
                          if (_otpController.text.trim().length != 6) {
                            setState(() => _verificationUnavailable = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enter the 6-digit OTP.'),
                              ),
                            );
                            return;
                          }
                          setState(() => _verificationUnavailable = true);
                        },
                  child: const Text('Verify & Activate Membership'),
                ),
              ),
              if (_verificationUnavailable) ...[
                const SizedBox(height: 12),
                const Text(
                  'OTP verification is not available yet because the backend activation API has not been created. Your membership remains pending; this screen will not activate it locally.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.redAccent,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
