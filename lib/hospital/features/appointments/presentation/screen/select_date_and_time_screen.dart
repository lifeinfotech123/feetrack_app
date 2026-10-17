import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:vlr/controllers/auth_controller.dart';
import '../../../../../ecomerce/constants.dart';
import '../../../doctor/data/model/doctor_model.dart';
import '../../data/repositories/appointment_repo.dart';
import 'billing_overview_screen.dart';
import 'booking_succsess_screen.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';

class SelectDateAndTimeScreen extends StatefulWidget {
  final String doctorName;
  final String designation;
  final Map<String, dynamic>? doctorData;
  final String? consultationFee;

  const SelectDateAndTimeScreen({
    super.key,
    this.doctorName = "Mohamed Saeed",
    this.designation = "Physical Therapy",
    this.doctorData,
    this.consultationFee,
  });

  @override
  State<SelectDateAndTimeScreen> createState() => _SelectDateAndTimeScreenState();
}

class _SelectDateAndTimeScreenState extends State<SelectDateAndTimeScreen> {
  DateTime _viewDate = DateTime.now();
  int selectedDate = DateTime.now().day;
  String selectedTime = "11:00 AM";
  String selectedConsultationType = "Online";
  bool isFavorite = false;
  bool _isSubmitting = false;

  final TextEditingController _firstNameController = TextEditingController(text: 'Patient');
  final TextEditingController _lastNameController = TextEditingController(text: 'Bhargava');
  final TextEditingController _phoneController = TextEditingController(text: '9876543210');
  final TextEditingController _emailController = TextEditingController(text: 'patient@gmail.com');
  final TextEditingController _serviceNameController = TextEditingController(text: 'OPD General Consultation');
  final TextEditingController _messageController = TextEditingController(text: 'Routine health checkup');
  final TextEditingController _addressController = TextEditingController(text: 'Sector 14, Lucknow');

  String selectedGender = 'Male';
  bool isLiveConsultation = false;
  String selectedPaymentMode = 'Online';

  String get _displayFee {
    final raw = widget.consultationFee ??
        widget.doctorData?['consultation_fees'] ??
        widget.doctorData?['fee'] ??
        widget.doctorData?['fees'] ??
        '500';
    final s = raw.toString().trim().replaceAll('₹', '');
    return '₹$s';
  }

  @override
  void initState() {
    super.initState();
    try {
      if (Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        final u = auth.userModel;
        if (u != null) {
          final fName = u.firstName ??
              (u.name != null && u.name!.isNotEmpty
                  ? u.name!.split(' ').first
                  : '');
          final lName = u.lastName ??
              (u.name != null && u.name!.contains(' ')
                  ? u.name!.split(' ').sublist(1).join(' ')
                  : '');
          final phone = u.mobile ?? '';
          final email = u.email ?? '';
          final addr = u.address ?? '';
          if (fName.isNotEmpty) _firstNameController.text = fName;
          if (lName.isNotEmpty) _lastNameController.text = lName;
          if (phone.isNotEmpty) _phoneController.text = phone;
          if (email.isNotEmpty) _emailController.text = email;
          if (addr.isNotEmpty) _addressController.text = addr;
          if (u.gender != null && u.gender!.isNotEmpty) {
            final g = u.gender!.trim().toLowerCase();
            if (g == 'female') {
              selectedGender = 'Female';
            } else if (g == 'male') {
              selectedGender = 'Male';
            }
          }
        }
      }
    } catch (_) {}

    if (widget.doctorData != null &&
        widget.doctorData!['services'] is List &&
        (widget.doctorData!['services'] as List).isNotEmpty) {
      final s = (widget.doctorData!['services'] as List).first;
      if (s is Map && s['name'] != null) {
        _serviceNameController.text = s['name'].toString();
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _serviceNameController.dispose();
    _messageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  final List<String> timeSlots = [
    "09:00 AM", "09:30 AM", "10:00 AM",
    "10:30 AM", "11:00 AM", "11:30 AM",
    "12:00 PM", "12:30 PM", "01:00 PM",
    "02:00 PM", "03:00 PM", "04:00 PM"
  ];

  final List<String> disabledSlots = [];

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstDayOffset(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  Future<void> _bookAppointment() async {
    final bool isLoggedIn = Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn();
    if (!isLoggedIn) {
      showLoginRequiredDialog(
        context: context,
        title: "Login Required",
        message:
            "Please login to your account first before confirming an appointment.",
      );
      return;
    }

    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final Map<String, dynamic> doc = widget.doctorData ?? {};

      final String hospDomain = (doc['hospital'] is Map)
          ? (doc['hospital']['domain']?.toString() ??
              doc['hospital']['name']?.toString() ??
              'susmaHospital')
          : (doc['hospital']?.toString() ?? 'susmaHospital');

      final dynamic rawId = doc['id'] ?? 67;
      final int docId = (rawId is num)
          ? rawId.toInt()
          : (int.tryParse(rawId.toString()) ?? 67);

      final String dName = doc['name']?.toString() ?? widget.doctorName;

      final int maxDays = _daysInMonth(_viewDate);
      final int safeDay = selectedDate.clamp(1, maxDays);
      final DateTime apptDate =
          DateTime(_viewDate.year, _viewDate.month, safeDay);
      final String formattedDate = DateFormat('yyyy-MM-dd').format(apptDate);

      final String slotStr = selectedTime;

      final String shiftStr =
          selectedTime.toUpperCase().contains('AM') ? "Morning" : "Evening";

      final cleanFeeStr = (widget.consultationFee ??
              doc['consultation_fees']?.toString() ??
              doc['fee']?.toString() ??
              doc['fees']?.toString() ??
              '500')
          .replaceAll('₹', '')
          .trim();
      final num parsedFee = num.tryParse(cleanFeeStr) ?? 500;

      final Map<String, dynamic> requestPayload = {
        "hospital": hospDomain,
        "doctor_id": docId,
        "doctor_name": dName,
        "appointment_date": formattedDate,
        "slot": slotStr,
        "shift": shiftStr,
        "first_name": _firstNameController.text.trim().isEmpty ? "Patient" : _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim().isEmpty ? "Bhargava" : _lastNameController.text.trim(),
        "phone": _phoneController.text.trim().isEmpty ? "9876543210" : _phoneController.text.trim(),
        "email": _emailController.text.trim().isEmpty ? "patient@gmail.com" : _emailController.text.trim(),
        "gender": selectedGender,
        "payment_mode": selectedPaymentMode,
        "payment_status": "pending",
        "service_name": _serviceNameController.text.trim().isEmpty ? "OPD General Consultation" : _serviceNameController.text.trim(),
        "live_consultation": isLiveConsultation ? "Yes" : "No",
        "message": _messageController.text.trim().isEmpty ? "Routine health checkup" : _messageController.text.trim(),
        "alternate_address": _addressController.text.trim().isEmpty ? "Sector 14, Lucknow" : _addressController.text.trim(),
        "consultation_fees": parsedFee,
        "fees": parsedFee,
        "amount": parsedFee,
        "fee": parsedFee,
      };

      debugPrint('Create Appointment Payload: ${jsonEncode(requestPayload)}');

      final repo = Get.isRegistered<AppointmentRepo>()
          ? Get.find<AppointmentRepo>()
          : AppointmentRepo();
      final decoded = await repo.createAppointment(requestPayload);

      bool isSuccess = (decoded['status'] == true ||
          decoded['status'] == 'true' ||
          decoded['success'] == true);

      if (isSuccess) {
        final apptData = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : <String, dynamic>{};
        final rzpData = apptData['razorpay'] is Map<String, dynamic>
            ? apptData['razorpay'] as Map<String, dynamic>
            : null;

        // Force exact doctor fee and info to match selected doctor
        apptData['fees'] = parsedFee;
        apptData['consultation_fees'] = parsedFee;
        apptData['amount'] = parsedFee;
        apptData['fee'] = parsedFee;
        if (apptData['doctor_name'] == null) {
          apptData['doctor_name'] = dName;
        }
        if (apptData['hospital'] == null && doc['hospital'] != null) {
          apptData['hospital'] = doc['hospital'];
        }

        // Also ensure doc map preserves the fee
        doc['consultation_fees'] = parsedFee;
        doc['fees'] = parsedFee;
        doc['fee'] = parsedFee;

        if (mounted) {
          if (selectedPaymentMode == 'Cash') {
            final String apptNo = apptData['appointment_no']?.toString() ??
                'APT-${DateTime.now().millisecondsSinceEpoch % 10000}';
            final String docName = apptData['doctor_name']?.toString() ?? dName;
            final String dateStr =
                apptData['appointment_date']?.toString() ?? formattedDate;
            final String confirmedSlot =
                apptData['slot']?.toString() ?? selectedTime;
            final String feesStr = '₹$parsedFee';

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Appointment booked successfully! Please pay at the hospital desk.'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BookingSuccsessScreen(
                  bookingId: apptNo,
                  title: 'Appointment Booked (Pay at Counter)',
                  doctorName: docName,
                  amount: feesStr,
                  date: dateStr,
                  time: confirmedSlot,
                ),
              ),
            );
          } else {
            // Online payment: Mark status as Pending Payment
            apptData['status'] = 'Pending Payment';
            apptData['payment_status'] = 'pending';

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Please complete payment to confirm your appointment booking.'),
                backgroundColor: Color(0xFF4C80ED),
                duration: Duration(seconds: 2),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => BillingOverviewScreen(
                  appointmentData: apptData,
                  razorpayData: rzpData,
                  doctorData: doc,
                ),
              ),
            );
          }
        }
      } else {
        String errorMsg = 'Failed to book appointment.';

        if (decoded['message'] != null &&
            decoded['message'].toString().isNotEmpty) {
          errorMsg = decoded['message'].toString();
        } else if (decoded['error'] != null &&
            decoded['error'].toString().isNotEmpty) {
          errorMsg = decoded['error'].toString();
        } else if (decoded['errors'] != null) {
          final errs = decoded['errors'];
          if (errs is Map && errs.isNotEmpty) {
            final firstVal = errs.values.first;
            if (firstVal is List && firstVal.isNotEmpty) {
              errorMsg = firstVal.first.toString();
            } else {
              errorMsg = errs.values.first.toString();
            }
          } else if (errs is List && errs.isNotEmpty) {
            errorMsg = errs.first.toString();
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMsg,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Exception in _bookAppointment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int daysCount = _daysInMonth(_viewDate);
    int offset = _firstDayOffset(_viewDate);
    int prevMonthDays = _daysInMonth(DateTime(_viewDate.year, _viewDate.month - 1));

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17, letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: NetworkImage(
                              DoctorModel.resolveDoctorPhoto(
                                photo: widget.doctorData?['photo'] ??
                                    widget.doctorData?['image'] ??
                                    widget.doctorData?['profile_photo'],
                                domain: (widget.doctorData?['hospital'] is Map)
                                    ? widget.doctorData!['hospital']['domain']?.toString()
                                    : null,
                                gender: widget.doctorData?['gender']?.toString(),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.designation,
                                  style: const TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (widget.consultationFee != null ||
                                  widget.doctorData?['consultation_fees'] != null ||
                                  widget.doctorData?['fee'] != null ||
                                  widget.doctorData?['fees'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.consultationFee ??
                                        '₹${widget.doctorData?['consultation_fees'] ?? widget.doctorData?['fee'] ?? widget.doctorData?['fees']}',
                                    style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => setState(() => isFavorite = !isFavorite),
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isFavorite ? Colors.pink[50] : Colors.grey[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.pink : Colors.grey[400],
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Select Consultation Type'),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildConsultationCard('Online', Icons.videocam_outlined),
                  const SizedBox(width: 10),
                  _buildConsultationCard('Home Visit', Icons.home_outlined),
                  const SizedBox(width: 10),
                  _buildConsultationCard('Offline', Icons.location_on_outlined),
                ],
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Select A Day'),
              const SizedBox(height: 12),
              
              // Date Dropdown styled selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[100]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 20, color: primaryColor),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(
                          DateTime(_viewDate.year, _viewDate.month,
                              selectedDate.clamp(1, _daysInMonth(_viewDate)))),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                    ),
                    const Spacer(),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Calendar View
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[100]!),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.black87),
                          onPressed: () => setState(() {
                            _viewDate = DateTime(_viewDate.year, _viewDate.month - 1);
                            selectedDate = selectedDate.clamp(1, _daysInMonth(_viewDate));
                          }),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_viewDate),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: Colors.black87),
                          onPressed: () => setState(() {
                            _viewDate = DateTime(_viewDate.year, _viewDate.month + 1);
                            selectedDate = selectedDate.clamp(1, _daysInMonth(_viewDate));
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                          .map((d) => SizedBox(
                                width: 36,
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 11),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: 42,
                      itemBuilder: (context, index) {
                        int day = index - offset + 1;
                        if (day < 1) {
                          return Center(child: Text('${prevMonthDays + day}', style: TextStyle(color: Colors.grey[300], fontSize: 12)));
                        }
                        if (day > daysCount) {
                          return Center(child: Text('${day - daysCount}', style: TextStyle(color: Colors.grey[300], fontSize: 12)));
                        }
                        
                        bool isSelected = selectedDate == day; 
                        bool isToday = day == DateTime.now().day && _viewDate.month == DateTime.now().month && _viewDate.year == DateTime.now().year;

                        return GestureDetector(
                          onTap: () => setState(() => selectedDate = day),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.transparent,
                              shape: BoxShape.circle,
                              border: isToday && !isSelected ? Border.all(color: primaryColor, width: 1.5) : null,
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : (isToday ? primaryColor : Colors.black87),
                                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSectionTitle('Select Time'),
              const SizedBox(height: 12),
              
              // Time Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.4,
                ),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  String time = timeSlots[index];
                  bool isDisabled = disabledSlots.contains(time);
                  bool isSelected = selectedTime == time;
                  
                  return GestureDetector(
                    onTap: isDisabled ? null : () => setState(() => selectedTime = time),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? primaryColor 
                            : (isDisabled ? Colors.grey[100] : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected 
                              ? primaryColor 
                              : (isDisabled ? Colors.transparent : Colors.grey[200]!),
                        ),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ] : null,
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: TextStyle(
                            color: isSelected 
                                ? Colors.white 
                                : (isDisabled ? Colors.grey[400] : Colors.black87),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Patient Information Form
              _buildSectionTitle('Patient Information'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _firstNameController,
                            label: 'First Name',
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            icon: Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      controller: _emailController,
                      label: 'Email Address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: ['Male', 'Female', 'Other'].map((g) {
                        bool isSel = selectedGender == g;
                        return GestureDetector(
                          onTap: () => setState(() => selectedGender = g),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? primaryColor
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel ? primaryColor : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              g,
                              style: TextStyle(
                                color: isSel ? Colors.white : Colors.black87,
                                fontWeight:
                                    isSel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Consultation & Service Details Form
              _buildSectionTitle('Consultation & Service Details'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      controller: _serviceNameController,
                      label: 'Service Name',
                      icon: Icons.medical_services_outlined,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Video Consultation',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Consult with doctor online via video call',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isLiveConsultation,
                          activeTrackColor: primaryColor.withValues(alpha: 0.5),
                          activeThumbColor: primaryColor,
                          onChanged: (val) => setState(() => isLiveConsultation = val),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      controller: _addressController,
                      label: 'Alternate Address / Location',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildInputField(
                      controller: _messageController,
                      label: 'Health Message / Symptoms',
                      icon: Icons.chat_bubble_outline,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Mode Form
              _buildSectionTitle('Payment Mode'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildPaymentOptionTile(
                      title: 'Online Payment',
                      subtitle: 'Pay via Razorpay / UPI / Card / Netbanking',
                      icon: Icons.payment_outlined,
                      value: 'Online',
                    ),
                    const Divider(height: 1),
                    _buildPaymentOptionTile(
                      title: 'Cash / Pay at Hospital',
                      subtitle: 'Pay directly at the hospital desk',
                      icon: Icons.money_outlined,
                      value: 'Cash',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _bookAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      selectedPaymentMode == 'Cash'
                          ? 'Confirm Appointment (Pay at Counter)'
                          : 'Proceed to Payment ($_displayFee)',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: -0.2),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: primaryColor),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final bool isSel = selectedPaymentMode == value;
    return ListTile(
      onTap: () => setState(() => selectedPaymentMode = value),
      leading: CircleAvatar(
        backgroundColor: isSel ? primaryColor.withValues(alpha: 0.1) : Colors.grey[100],
        child: Icon(icon, color: isSel ? primaryColor : Colors.grey[600], size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
          fontSize: 13,
          color: isSel ? primaryColor : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      trailing: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSel ? primaryColor : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: isSel
            ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildConsultationCard(String type, IconData icon) {
    final bool isSelected = selectedConsultationType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedConsultationType = type;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 90,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Center content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor.withValues(alpha: 0.12)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isSelected
                            ? primaryColor
                            : Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      type,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: isSelected
                            ? primaryColor
                            : Colors.grey.shade800,
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Radio button
              Positioned(
                top: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? primaryColor
                          : Colors.grey.shade400,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                    child: Container(
                      height: 9,
                      width: 9,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
