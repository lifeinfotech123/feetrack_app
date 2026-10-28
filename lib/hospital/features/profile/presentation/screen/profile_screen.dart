import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/hospital/features/pharmacy/presentation/screens/pharmacy_bookings_screen.dart';
import 'package:vlr/hospital/features/support_ticket/presentation/screen/support_ticket_screen.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../bills_invoices/presentation/screen/bills_invoices_screen.dart';
import '../../../family_profiles/presentation/screen/family_profiles_screen.dart';
import '../../../health_documents/presentation/screen/health_documents_screen.dart';
import '../../../health_membership/presentation/screen/health_membership_screen.dart';
import '../../../insurance/presentation/screen/insurance_screen.dart';
import '../../../medical_records/presentation/screen/medical_records_screen.dart';
import '../../../offers_coupons/presentation/screen/offers_coupons_screen.dart';
import '../../../profile_health_id/presentation/screen/profile_health_id_screen.dart';
import '../../../ratings_feedback/presentation/screen/ratings_feedback_screen.dart';
import '../../../appointments/presentation/screen/appointments_screen.dart';
import '../../../appointments/logics/appointment_controller.dart';
import '../../../lab_reports/presentation/screen/lab_reports_screen.dart';
import '../../../lab_reports/controller/lab_controller.dart';
import '../../logics/hospital_profile_controller.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/app_router.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/base/dialogs/logout_dialog.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

class HospitalProfileScreen extends StatefulWidget {
  const HospitalProfileScreen({super.key});

  @override
  State<HospitalProfileScreen> createState() => _HospitalProfileScreenState();
}

class _HospitalProfileScreenState extends State<HospitalProfileScreen> {
  late final HospitalProfileController _controller;
  late final AppointmentController _appointmentController;
  late final LabController _labController;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<HospitalProfileController>()
        ? Get.find<HospitalProfileController>()
        : Get.put(HospitalProfileController());

    _appointmentController = Get.isRegistered<AppointmentController>()
        ? Get.find<AppointmentController>()
        : Get.put(AppointmentController());

    _labController = Get.isRegistered<LabController>()
        ? Get.find<LabController>()
        : Get.put(LabController());

    final isUserLoggedIn = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn();
    if (isUserLoggedIn) {
      _controller.fetchPatientDashboard();
      _appointmentController.fetchAppointments();
      _labController.fetchPatientLabBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = _controller.isLoading.value;
      final patient = _controller.patient.value;
      final counts = _controller.counts.value;
      final displayName = _controller.displayName;
      final patientId = _controller.patientId;
      final email = _controller.email;
      final phone = _controller.phone;
      final gender = _controller.gender;
      final bloodGroup = _controller.bloodGroup;

      final isUserLoggedIn = _controller.isLoggedIn;
      final contactText = isUserLoggedIn
          ? (email.isNotEmpty && phone.isNotEmpty
              ? '$email • $phone'
              : (email.isNotEmpty ? email : phone))
          : 'Please log in to manage your health records';

      // Compute total booked counts strictly for booked/valid records
      int bookedAppointmentsCount = 0;
      if (isUserLoggedIn) {
        final list = _appointmentController.appointments;
        if (list.isNotEmpty) {
          bookedAppointmentsCount = list.where((a) {
            final s = (a.status ?? '').toLowerCase();
            final p = (a.paymentStatus ?? '').toLowerCase();
            return !s.contains('cancel') &&
                !s.contains('reject') &&
                !p.contains('fail');
          }).length;
        } else {
          bookedAppointmentsCount = counts?['appointments'] ?? 0;
        }
      }

      int bookedLabReportsCount = 0;
      if (isUserLoggedIn) {
        final list = _labController.patientLabBookings;
        if (list.isNotEmpty) {
          bookedLabReportsCount = list.where((b) {
            final s = (b.bookingStatus ?? '').toLowerCase();
            final p = (b.paymentStatus ?? '').toLowerCase();
            return !s.contains('cancel') &&
                !s.contains('reject') &&
                !p.contains('fail');
          }).length;
        } else {
          bookedLabReportsCount =
              counts?['lab_reports'] ?? counts?['pathology_reports'] ?? 0;
        }
      }

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          title: const Text(
            'My Profile',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: colorWhite),
              onPressed: () async {
                await Future.wait([
                  _controller.fetchPatientDashboard(),
                  _appointmentController.fetchAppointments(),
                  _labController.fetchPatientLabBookings(),
                ]);
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _controller.fetchPatientDashboard(),
              _appointmentController.fetchAppointments(),
              _labController.fetchPatientLabBookings(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // 1. User Header Card (Top)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!isUserLoggedIn) {
                            _showLoginPrompt(context, 'Digital Health Card');
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileHealthIdScreen(
                                patientName: displayName,
                                healthId: patientId,
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundColor: colorWhite,
                              child: isLoading && patient == null
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: primaryColor,
                                      ),
                                    )
                                  : const Icon(Icons.person,
                                      size: 45, color: primaryColor),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: wellnessGreen,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.qr_code,
                                    size: 16, color: colorWhite),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        displayName,
                        style: const TextStyle(
                            color: colorWhite,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        contactText,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (gender.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                gender,
                                style: const TextStyle(
                                    color: colorWhite,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                          if (bloodGroup != null && bloodGroup.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                bloodGroup,
                                style: const TextStyle(
                                    color: colorWhite,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Health Counts Card (Appointments & Lab Reports)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Patient Health Summary',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: textDark),
                            ),
                            Icon(Icons.analytics_outlined,
                                size: 18, color: primaryColor),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCountGridItem(
                                icon: Icons.calendar_month_rounded,
                                label: 'Appointments',
                                count: isUserLoggedIn
                                    ? bookedAppointmentsCount
                                    : 0,
                                color: primaryColor,
                                onTap: () {
                                  if (!isUserLoggedIn) {
                                    _showLoginPrompt(context, 'Appointments');
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AppointmentsScreen(
                                        userId: patientId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCountGridItem(
                                icon: Icons.biotech_rounded,
                                label: 'Lab Reports',
                                count:
                                    isUserLoggedIn ? bookedLabReportsCount : 0,
                                color: ambulanceAmber,
                                onTap: () {
                                  if (!isUserLoggedIn) {
                                    _showLoginPrompt(context, 'Lab Reports');
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LabReportsScreen(
                                        userId: patientId,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Profile Menus
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildProfileGroup(
                        context,
                        title: 'Health Records & Family',
                        items: [
                          _ProfileMenuItem(
                            icon: Icons.history_edu,
                            title: 'Medicines Records',
                            subtitle: 'Previous diagnoses & vitals',
                            color: primaryColor,
                            onTap: () {
                              if (!isUserLoggedIn) {
                                _showLoginPrompt(
                                    context, 'Medical Records (EHR)');
                                return;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const PharmacyBookingsScreen()));
                            },
                          ),
                          // _ProfileMenuItem(
                          //   icon: Icons.folder_shared_outlined,
                          //   title: 'Health Documents Locker',
                          //   subtitle: 'Prescriptions & scan files',
                          //   color: pharmacyTeal,
                          //   onTap: () {
                          //     if (!isUserLoggedIn) {
                          //       _showLoginPrompt(
                          //           context, 'Health Documents Locker');
                          //       return;
                          //     }
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (_) =>
                          //                 const HealthDocumentsScreen()));
                          //   },
                          // ),
                          // _ProfileMenuItem(
                          //   icon: Icons.family_restroom_outlined,
                          //   title: 'Family & Dependents',
                          //   subtitle: 'Manage spouse, children, parents',
                          //   color: diagnosticViolet,
                          //   onTap: () {
                          //     if (!isUserLoggedIn) {
                          //       _showLoginPrompt(
                          //           context, 'Family & Dependents');
                          //       return;
                          //     }
                          //     Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //             builder: (_) =>
                          //                 const FamilyProfilesScreen()));
                          //   },
                          // ),
                        ],
                      ),
                      // const SizedBox(height: 14),

                      // _buildProfileGroup(
                      //   context,
                      //   title: 'Billing, Insurance & Plans',
                      //   items: [
                      //     _ProfileMenuItem(
                      //       icon: Icons.shield_outlined,
                      //       title: 'Health Insurance & Claims',
                      //       subtitle: 'TPA cashless hospitalization tracking',
                      //       color: primaryDark,
                      //       onTap: () => Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (_) => const InsuranceScreen())),
                      //     ),
                      //     _ProfileMenuItem(
                      //       icon: Icons.card_membership_outlined,
                      //       title: 'Health Membership Plans',
                      //       subtitle: 'Silver / Gold family healthcare tiers',
                      //       color: ambulanceAmber,
                      //       onTap: () => Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (_) =>
                      //                   const HealthMembershipScreen())),
                      //     ),
                      //     _ProfileMenuItem(
                      //       icon: Icons.receipt_long_outlined,
                      //       title: 'Bills & Payment Invoices',
                      //       subtitle:
                      //           'Download receipts & view history (${isUserLoggedIn ? (counts?['total_bills'] ?? 0) : 0})',
                      //       color: wellnessGreen,
                      //       onTap: () {
                      //         if (!isUserLoggedIn) {
                      //           _showLoginPrompt(
                      //               context, 'Bills & Payment Invoices');
                      //           return;
                      //         }
                      //         Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (_) =>
                      //                     const BillsInvoicesScreen()));
                      //       },
                      //     ),
                      //     _ProfileMenuItem(
                      //       icon: Icons.local_offer_outlined,
                      //       title: 'Coupons & Offers',
                      //       subtitle: 'Active discount vouchers',
                      //       color: offerOrange,
                      //       onTap: () => Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //               builder: (_) =>
                      //                   const OffersCouponsScreen())),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 14),

                      _buildProfileGroup(
                        context,
                        title: 'Help & Reviews',
                        items: [
                          _ProfileMenuItem(
                            icon: Icons.star_rate_outlined,
                            title: 'Ratings & Service Feedback',
                            subtitle: 'Rate doctors & clinical staff',
                            color: Colors.amber,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const RatingsFeedbackScreen())),
                          ),
                          _ProfileMenuItem(
                            icon: Icons.support_agent_outlined,
                            title: '24/7 Helpdesk & Support Tickets',
                            subtitle: 'Raise inquiries & complaints',
                            color: primaryColor,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const SupportTicketScreen())),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Logout / Login Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isUserLoggedIn ? errorColor : primaryColor,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (!isUserLoggedIn) {
                              navigate(
                                  context: context,
                                  isRemoveUntil: true,
                                  page: const LoginScreen());
                              AppRouter.goToLogin();
                              return;
                            }
                            bool? logout =
                                await showLogoutDialogue(context: context);
                            if (logout == true) {
                              if (Get.isRegistered<AuthController>()) {
                                await Get.find<AuthController>().logout();
                              }
                              _controller.resetGuestState();
                              if (context.mounted) {
                                navigate(
                                    context: context,
                                    isRemoveUntil: true,
                                    page: const LoginScreen());
                              }
                              AppRouter.goToLogin();
                            }
                          },
                          child: Text(
                            isUserLoggedIn ? 'LOGOUT' : 'LOG IN / SIGN UP',
                            style: const TextStyle(
                                color: colorWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showLoginPrompt(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Login Required',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Please log in to view and manage your $feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppRouter.goToLogin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Log In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Count Card Item
  Widget _buildCountGridItem({
    required IconData icon,
    required String label,
    required dynamic count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileGroup(BuildContext context,
      {required String title, required List<_ProfileMenuItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
        ),
        ModernCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isLast = index == items.length - 1;
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(item.icon, color: item.color, size: 20),
                    ),
                    title: Text(item.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: textDark)),
                    subtitle: Text(item.subtitle,
                        style: const TextStyle(fontSize: 11, color: textMuted)),
                    trailing: const Icon(Icons.chevron_right,
                        size: 18, color: colorGrey),
                    onTap: item.onTap,
                  ),
                  if (!isLast) const Divider(height: 1, indent: 56),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
