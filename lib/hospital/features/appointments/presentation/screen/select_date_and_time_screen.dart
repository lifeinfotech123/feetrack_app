import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:vlr/controllers/auth_controller.dart';
import '../../../../../ecomerce/constants.dart';
import '../../../doctor/data/model/doctor_model.dart';
import '../../../doctor/logics/doctor_controller.dart';
import '../../logics/appointment_controller.dart';
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
  State<SelectDateAndTimeScreen> createState() =>
      _SelectDateAndTimeScreenState();
}

class _SelectDateAndTimeScreenState extends State<SelectDateAndTimeScreen> {
  DateTime _viewDate = DateTime.now();
  int selectedDate = DateTime.now().day;
  String selectedTime = "11:00 AM";
  String selectedConsultationType = "Online";
  bool isFavorite = false;
  bool _isSubmitting = false;

  final TextEditingController _firstNameController =
      TextEditingController(text: 'Patient');
  final TextEditingController _lastNameController =
      TextEditingController(text: 'Bhargava');
  final TextEditingController _phoneController =
      TextEditingController(text: '9876543210');
  final TextEditingController _emailController =
      TextEditingController(text: 'patient@gmail.com');
  final TextEditingController _messageController =
      TextEditingController(text: 'Routine health checkup');
  final TextEditingController _addressController =
      TextEditingController(text: 'Sector 14, Lucknow');

  String selectedGender = 'Male';
  bool isLiveConsultation = false;
  String selectedPaymentMode = 'Online';

  late final AppointmentController _appointmentController;
  late final DoctorController _doctorController;
  late final Razorpay _razorpay;
  Map<String, dynamic>? _pendingAppointmentData;
  Map<String, dynamic>? _pendingDoctorData;
  String _pendingDoctorName = '';
  String _pendingDate = '';
  String _pendingTime = '';
  num _pendingFee = 0;
  final List<String> _apiTimeSlots = [];
  final Map<String, String> _slotShifts = {};
  bool _isLoadingSlots = true;

  DateTime get _now => DateTime.now();

  DateTime get _selectedAppointmentDate =>
      DateTime(_viewDate.year, _viewDate.month, selectedDate);

  bool get _isSelectedDateToday {
    final now = _now;
    return DateUtils.isSameDay(_selectedAppointmentDate, now);
  }

  bool _isPastDate(DateTime date) {
    final today = DateUtils.dateOnly(_now);
    return DateUtils.dateOnly(date).isBefore(today);
  }

  DateTime? _slotStart(String slot) {
    try {
      final time =
          DateFormat('hh:mm a').parseStrict(slot.split('-').first.trim());
      final date = _selectedAppointmentDate;
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    } catch (_) {
      return null;
    }
  }

  bool _isSlotAvailable(String slot) {
    if (_isPastDate(_selectedAppointmentDate)) return false;
    if (!_isSelectedDateToday) return true;
    final start = _slotStart(slot);
    return start != null && start.isAfter(_now);
  }

  void _ensureSelectedTime() {
    if (_isSlotAvailable(selectedTime)) return;
    final firstAvailable = _apiTimeSlots.firstWhereOrNull(_isSlotAvailable);
    selectedTime = firstAvailable ?? '';
  }

  void _selectDate(int day) {
    final date = DateTime(_viewDate.year, _viewDate.month, day);
    if (_isPastDate(date)) return;
    setState(() {
      selectedDate = day;
      _ensureSelectedTime();
    });
    _loadDoctorSlots();
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
    _appointmentController = Get.isRegistered<AppointmentController>()
        ? Get.find<AppointmentController>()
        : Get.put(AppointmentController());
    _doctorController = Get.isRegistered<DoctorController>()
        ? Get.find<DoctorController>()
        : Get.put(DoctorController());
    _razorpay = Razorpay()
      ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess)
      ..on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError)
      ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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

    _loadDoctorSlots();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _addressController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  final List<String> disabledSlots = [];

  Future<void> _loadDoctorSlots() async {
    Map<String, dynamic> doctor =
        Map<String, dynamic>.from(widget.doctorData ?? const {});
    final doctorId = doctor['id'];
    String hospital = '';
    final hospitalData = doctor['hospital'];
    if (hospitalData is Map) {
      hospital = (hospitalData['domain'] ??
                  hospitalData['hospital_domain'] ??
                  hospitalData['name'])
              ?.toString()
              .trim() ??
          '';
    }
    if (hospital.isEmpty) {
      hospital = (doctor['hospital_domain'] ?? doctor['domain'] ?? '')
          .toString()
          .trim();
    }

    Map<String, String> slots = {};
    if (doctorId != null && hospital.isNotEmpty) {
      final response = await _doctorController.fetchDoctorSlots(
        doctorId: doctorId,
        hospital: hospital,
        date: DateFormat('yyyy-MM-dd').format(_selectedAppointmentDate),
      );
      if (response['status'] == true && response['data'] is Map) {
        slots = _extractSlots(Map<String, dynamic>.from(response['data']));
      }
    }

    if (slots.isEmpty && doctorId != null) {
      final details = await _doctorController.fetchDoctorDetails(
        doctorId,
        hospitalDomain: _doctorHospitalDomain(doctor),
      );
      if (details != null) doctor = details.rawJson;
      slots = _extractSlots(doctor);
    }
    if (!mounted) return;
    setState(() {
      _apiTimeSlots
        ..clear()
        ..addAll(slots.keys);
      _slotShifts
        ..clear()
        ..addAll(slots);
      _isLoadingSlots = false;
      _ensureSelectedTime();
    });
  }

  String? _doctorHospitalDomain(Map<String, dynamic> doctor) {
    final hospital = doctor['hospital'];
    final domain = hospital is Map
        ? hospital['domain'] ??
            hospital['hospital_domain'] ??
            hospital['domain_name']
        : null;
    final value = domain ??
        doctor['hospital_domain'] ??
        doctor['domain'] ??
        doctor['domain_name'];
    final normalized = value?.toString().trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  Map<String, String> _extractSlots(Map<String, dynamic> doctor) {
    final result = <String, String>{};
    final candidates = [
      doctor['available_slots'],
      doctor['appointment_slots'],
      doctor['time_slots'],
      doctor['slots'],
      doctor['schedule'] is Map ? doctor['schedule']['slots'] : null,
    ];
    for (final candidate in candidates) {
      if (candidate is! List) continue;
      for (final item in candidate) {
        if (item is String && item.trim().isNotEmpty) {
          result[item.trim()] = _shiftFromSlot(item);
        } else if (item is Map) {
          if (item['is_available'] == false || item['is_available'] == 0) {
            continue;
          }
          final start = item['slot'] ??
              item['label'] ??
              item['time'] ??
              item['start_time'] ??
              item['start'];
          final end = item['end_time'] ?? item['end'];
          if (start == null) continue;
          final slot = end != null && !start.toString().contains('-')
              ? '${start.toString().trim()} - ${end.toString().trim()}'
              : start.toString().trim();
          if (slot.isNotEmpty) {
            result[slot] = item['shift']?.toString() ?? _shiftFromSlot(slot);
          }
        }
      }
      if (result.isNotEmpty) return result;
    }

    // A range is still doctor API data; derive 30-minute slots from it only.
    final hours = doctor['inhouse_hours'] ??
        doctor['visiting_hours'] ??
        (doctor['schedule'] is Map ? doctor['schedule']['hours'] : null);
    if (hours is String) {
      final parts = hours.split(RegExp(r'\s*-\s*'));
      if (parts.length == 2) {
        try {
          var start = DateFormat('hh:mm a').parseStrict(parts.first.trim());
          final end = DateFormat('hh:mm a').parseStrict(parts.last.trim());
          while (start.isBefore(end)) {
            final next = start.add(const Duration(minutes: 30));
            if (next.isAfter(end)) break;
            final slot =
                '${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(next)}';
            result[slot] = _shiftFromSlot(slot);
            start = next;
          }
        } catch (_) {}
      }
    }
    return result;
  }

  String _shiftFromSlot(String slot) {
    try {
      final start =
          DateFormat('hh:mm a').parseStrict(slot.split('-').first.trim());
      return start.hour < 12 ? 'Morning' : 'Evening';
    } catch (_) {
      return 'General';
    }
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstDayOffset(DateTime date) {
    return DateTime(date.year, date.month, 1).weekday % 7;
  }

  void _showBookingSuccess({
    required Map<String, dynamic> appointmentData,
    required Map<String, dynamic> doctorData,
    required String doctorName,
    required num fee,
    required String date,
    required String time,
  }) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSuccsessScreen(
          bookingId: appointmentData['appointment_no']?.toString(),
          title: 'Doctor Consultation',
          doctorName: appointmentData['doctor_name']?.toString() ?? doctorName,
          amount: fee.toString(),
          date: appointmentData['appointment_date']?.toString() ?? date,
          time: appointmentData['slot']?.toString() ?? time,
          bookingData: appointmentData,
          doctorData: doctorData,
        ),
      ),
    );
  }

  Future<bool> _openRazorpay({
    required Map<String, dynamic> appointmentData,
    required Map<String, dynamic> doctorData,
    required String doctorName,
    required num fee,
    required String date,
    required String time,
  }) async {
    _pendingAppointmentData = appointmentData;
    _pendingDoctorData = doctorData;
    _pendingDoctorName = doctorName;
    _pendingFee = fee;
    _pendingDate = date;
    _pendingTime = time;

    final gatewayResponse =
        await _appointmentController.appointmentRepo.fetchPaymentGateways();
    final gatewayData = gatewayResponse['data'];
    final gateways = gatewayData is Map && gatewayData['gateways'] is List
        ? gatewayData['gateways'] as List
        : <dynamic>[];
    Map<String, dynamic>? gateway;
    for (final item in gateways) {
      if (item is Map && item['slug']?.toString().toLowerCase() == 'razorpay') {
        gateway = Map<String, dynamic>.from(item);
        break;
      }
    }

    final credentials = gateway?['credentials'];
    final razorpayData = appointmentData['razorpay'] is Map
        ? Map<String, dynamic>.from(appointmentData['razorpay'])
        : <String, dynamic>{};
    final keyId = (credentials is Map ? credentials['key_id'] : null) ??
        razorpayData['key_id'] ??
        appointmentData['razorpay_key_id'];
    final orderId = razorpayData['order_id'] ??
        razorpayData['razorpay_order_id'] ??
        appointmentData['razorpay_order_id'];
    final gatewayActive = gateway?['active'];
    final isGatewayActive = gatewayActive == true ||
        gatewayActive == 1 ||
        gatewayActive?.toString().toLowerCase() == 'true' ||
        gatewayActive?.toString() == '1';
    if (!isGatewayActive ||
        keyId == null ||
        keyId.toString().trim().isEmpty ||
        orderId == null ||
        orderId.toString().trim().isEmpty) {
      throw StateError('Razorpay payment details are unavailable.');
    }

    final rawOrderAmount = num.tryParse(
      razorpayData['amount']?.toString() ?? '',
    );
    final amountInPaise = (fee * 100).round();
    if (rawOrderAmount != null &&
        rawOrderAmount > 0 &&
        rawOrderAmount.round() != amountInPaise) {
      final serverAmount = (rawOrderAmount / 100).toStringAsFixed(2);
      throw StateError(
        'Doctor consultation fee is ₹${fee.toStringAsFixed(2)}, but the payment order is ₹$serverAmount. No payment was started.',
      );
    }
    final hospital = doctorData['hospital'];
    final hospitalName = hospital is Map
        ? hospital['name']?.toString() ?? 'Hospital'
        : 'Hospital';

    _razorpay.open({
      'key': keyId.toString(),
      'amount': amountInPaise,
      'order_id': orderId.toString(),
      'name': hospitalName,
      'description': 'Consultation Fee for $doctorName',
      'prefill': {
        'contact': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      },
    });
    return true;
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final appointmentData = _pendingAppointmentData;
    final doctorData = _pendingDoctorData;
    if (appointmentData == null || doctorData == null) return;

    final appointmentId = appointmentData['id'] ??
        appointmentData['appointment_id'] ??
        (appointmentData['appointment'] is Map
            ? appointmentData['appointment']['id']
            : null);
    final hospitalDomain = appointmentData['hospital_domain'] ??
        appointmentData['domain'] ??
        (appointmentData['hospital'] is Map
            ? appointmentData['hospital']['domain']
            : doctorData['hospital'] is Map
                ? doctorData['hospital']['domain']
                : doctorData['hospital_domain']);
    if (appointmentId == null || response.orderId == null) {
      _showValidationError(
          'Payment could not be verified. Please contact support.');
      if (mounted) setState(() => _isSubmitting = false);
      return;
    }

    final verification = await _appointmentController.verifyPayment(
      appointmentId: appointmentId.toString(),
      hospitalDomain: hospitalDomain?.toString() ?? '',
      razorpayOrderId: response.orderId!,
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );
    if (!mounted) return;

    if (verification.success) {
      appointmentData['payment_status'] = 'paid';
      _showBookingSuccess(
        appointmentData: appointmentData,
        doctorData: doctorData,
        doctorName: _pendingDoctorName,
        fee: _pendingFee,
        date: _pendingDate,
        time: _pendingTime,
      );
    } else {
      _showValidationError(
        verification.message.isNotEmpty
            ? verification.message
            : 'Payment verification failed. Please contact support.',
      );
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    await _cancelPendingAppointment();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    _showValidationError(
      'Payment cancelled or failed: ${response.message ?? 'Please try again.'}',
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay external wallet: ${response.walletName}');
  }

  Future<void> _cancelPendingAppointment() async {
    final appointmentId = _pendingAppointmentData?['id'] ??
        _pendingAppointmentData?['appointment_id'];
    if (appointmentId != null) {
      await _appointmentController.appointmentRepo
          .cancelAppointment(appointmentId);
    }
    _pendingAppointmentData = null;
    _pendingDoctorData = null;
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

    if (_isSubmitting || _appointmentController.isBookingLoading.value) return;

    final apptDate = _selectedAppointmentDate;
    if (_isPastDate(apptDate)) {
      _showValidationError('Please select today or a future appointment date.');
      return;
    }
    if (selectedTime.isEmpty || !_isSlotAvailable(selectedTime)) {
      _showValidationError('Please select an available future time slot.');
      return;
    }
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      _showValidationError('Please complete all required patient details.');
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    var razorpayOpened = false;

    try {
      final Map<String, dynamic> doc =
          Map<String, dynamic>.from(widget.doctorData ?? const {});
      final dynamic rawId = doc['id'];
      final int docId = (rawId is num)
          ? rawId.toInt()
          : (int.tryParse(rawId?.toString() ?? '') ?? 0);
      if ((doc['address'] == null ||
              doc['address'].toString().trim().isEmpty) &&
          docId > 0) {
        final details = await _doctorController.fetchDoctorDetails(
          docId,
          hospitalDomain: _doctorHospitalDomain(doc),
        );
        if (details != null) doc.addAll(details.rawJson);
      }

      String hospDomain = '';
      if (doc['hospital'] is Map) {
        final hospMap = doc['hospital'] as Map;
        hospDomain = hospMap['domain']?.toString() ??
            hospMap['hospital_domain']?.toString() ??
            hospMap['name']?.toString() ??
            '';
      } else if (doc['hospital'] is String &&
          (doc['hospital'] as String).isNotEmpty) {
        hospDomain = doc['hospital'].toString();
      }

      if (hospDomain.isEmpty) {
        hospDomain = doc['hospital_domain']?.toString() ??
            doc['domain']?.toString() ??
            '';
      }

      final String dName = doc['name']?.toString() ?? widget.doctorName;

      if (hospDomain.isEmpty || docId <= 0 || dName.trim().isEmpty) {
        _showValidationError(
            'Doctor or hospital details are unavailable. Please try again.');
        return;
      }

      final int maxDays = _daysInMonth(_viewDate);
      final int safeDay = selectedDate.clamp(1, maxDays);
      final DateTime apptDate =
          DateTime(_viewDate.year, _viewDate.month, safeDay);
      final String formattedDate = DateFormat('yyyy-MM-dd').format(apptDate);

      final String slotStr = selectedTime;

      final String shiftStr =
          _slotShifts[selectedTime] ?? _shiftFromSlot(selectedTime);

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
        "hospital_domain": hospDomain,
        "domain": hospDomain,
        "doctor_id": docId,
        "doctor_name": dName,
        "appointment_date": formattedDate,
        "slot": slotStr,
        "shift": shiftStr,
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "gender": selectedGender,
        "payment_mode": selectedPaymentMode,
        "payment_status": "pending",
        "service_name": "Doctor Consultation",
        "live_consultation": isLiveConsultation ? "Yes" : "No",
        "message": _messageController.text.trim().isEmpty
            ? "Routine health checkup"
            : _messageController.text.trim(),
        "alternate_address": _addressController.text.trim().isEmpty
            ? "Sector 14, Lucknow"
            : _addressController.text.trim(),
        "consultation_fees": parsedFee,
        "fees": parsedFee,
        "amount": parsedFee,
        "fee": parsedFee,
      };

      debugPrint('Create Appointment Payload: ${jsonEncode(requestPayload)}');

      final booking =
          await _appointmentController.createAppointment(requestPayload);
      final bool isSuccess = booking.status;

      if (isSuccess) {
        final apptData = Map<String, dynamic>.from(booking.data ?? const {});

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
        if (apptData['hospital_domain'] == null) {
          apptData['hospital_domain'] = hospDomain;
        }
        if (apptData['domain'] == null) {
          apptData['domain'] = hospDomain;
        }
        apptData['payment_mode'] = selectedPaymentMode;

        // Also ensure doc map preserves the fee
        doc['consultation_fees'] = parsedFee;
        doc['fees'] = parsedFee;
        doc['fee'] = parsedFee;

        if (selectedPaymentMode == 'Cash') {
          _showBookingSuccess(
            appointmentData: apptData,
            doctorData: doc,
            doctorName: dName,
            fee: parsedFee,
            date: formattedDate,
            time: selectedTime,
          );
        } else {
          razorpayOpened = await _openRazorpay(
            appointmentData: apptData,
            doctorData: doc,
            doctorName: dName,
            fee: parsedFee,
            date: formattedDate,
            time: selectedTime,
          );
        }
      } else {
        String errorMsg = 'Failed to book appointment.';

        if (booking.message?.trim().isNotEmpty == true) {
          errorMsg = booking.message!.trim();
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
      if (selectedPaymentMode != 'Cash' && _pendingAppointmentData != null) {
        await _cancelPendingAppointment();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted && !razorpayOpened) {
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
    int prevMonthDays =
        _daysInMonth(DateTime(_viewDate.year, _viewDate.month - 1));

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
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black, size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17,
              letterSpacing: -0.5),
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
                            border: Border.all(
                                color: primaryColor.withValues(alpha: 0.2),
                                width: 2),
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
                                    ? widget.doctorData!['hospital']['domain']
                                        ?.toString()
                                    : null,
                                gender:
                                    widget.doctorData?['gender']?.toString(),
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
                            constraints: const BoxConstraints(
                                minWidth: 10, minHeight: 10),
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
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.designation,
                                  style: const TextStyle(
                                      color: primaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              if (widget.consultationFee != null ||
                                  widget.doctorData?['consultation_fees'] !=
                                      null ||
                                  widget.doctorData?['fee'] != null ||
                                  widget.doctorData?['fees'] != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.consultationFee ??
                                        '₹${widget.doctorData?['consultation_fees'] ?? widget.doctorData?['fee'] ?? widget.doctorData?['fees']}',
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
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
                            color:
                                isFavorite ? Colors.pink[50] : Colors.grey[50],
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

              
              // Calendar View
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[100]!),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded,
                              color: Colors.black87),
                          onPressed: DateUtils.dateOnly(_viewDate)
                                  .isAfter(DateUtils.dateOnly(DateTime.now()))
                              ? () => setState(() {
                                    _viewDate = DateTime(
                                        _viewDate.year, _viewDate.month - 1);
                                    selectedDate = selectedDate.clamp(
                                        1, _daysInMonth(_viewDate));
                                    _ensureSelectedTime();
                                  })
                              : null,
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(_viewDate),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded,
                              color: Colors.black87),
                          onPressed: () => setState(() {
                            _viewDate =
                                DateTime(_viewDate.year, _viewDate.month + 1);
                            selectedDate =
                                selectedDate.clamp(1, _daysInMonth(_viewDate));
                            _ensureSelectedTime();
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                              .map((d) => SizedBox(
                                    width: 36,
                                    child: Text(
                                      d,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11),
                                    ),
                                  ))
                              .toList(),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: 42,
                      itemBuilder: (context, index) {
                        int day = index - offset + 1;
                        if (day < 1) {
                          return Center(
                              child: Text('${prevMonthDays + day}',
                                  style: TextStyle(
                                      color: Colors.grey[300], fontSize: 12)));
                        }
                        if (day > daysCount) {
                          return Center(
                              child: Text('${day - daysCount}',
                                  style: TextStyle(
                                      color: Colors.grey[300], fontSize: 12)));
                        }

                        final date =
                            DateTime(_viewDate.year, _viewDate.month, day);
                        final isPast = _isPastDate(date);
                        bool isSelected = selectedDate == day;
                        bool isToday = day == DateTime.now().day &&
                            _viewDate.month == DateTime.now().month &&
                            _viewDate.year == DateTime.now().year;

                        return GestureDetector(
                          onTap: isPast ? null : () => _selectDate(day),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: isToday && !isSelected
                                  ? Border.all(color: primaryColor, width: 1.5)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : (isPast
                                          ? Colors.grey[350]
                                          : (isToday
                                              ? primaryColor
                                              : Colors.black87)),
                                  fontWeight: isSelected || isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
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
              if (_isLoadingSlots)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                )
              else if (_apiTimeSlots.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No appointment slots are available for this doctor.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: _apiTimeSlots.length,
                  itemBuilder: (context, index) {
                    String time = _apiTimeSlots[index];
                    bool isDisabled =
                        disabledSlots.contains(time) || !_isSlotAvailable(time);
                    bool isSelected = selectedTime == time;

                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () => setState(() => selectedTime = time),
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
                                : (isDisabled
                                    ? Colors.transparent
                                    : Colors.grey[200]!),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            time,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDisabled
                                      ? Colors.grey[400]
                                      : Colors.black87),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
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
                              color: isSel ? primaryColor : Colors.grey[100],
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

              // Consultation Details Form
              _buildSectionTitle('Consultation Details'),
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
                          onChanged: (val) =>
                              setState(() => isLiveConsultation = val),
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
                      subtitle: 'Pay UPI / Card / Netbanking',
                      icon: Icons.payment_outlined,
                      value: 'Online',
                    ),
                    const Divider(height: 1),
                    _buildPaymentOptionTile(
                      title: 'Cash Pay at Hospital',
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
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: -0.2),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        backgroundColor:
            isSel ? primaryColor.withValues(alpha: 0.1) : Colors.grey[100],
        child: Icon(icon,
            color: isSel ? primaryColor : Colors.grey[600], size: 20),
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
              color: isSelected ? primaryColor : Colors.grey.shade300,
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
                        color: isSelected ? primaryColor : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      type,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: isSelected ? primaryColor : Colors.grey.shade800,
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
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
                      color: isSelected ? primaryColor : Colors.grey.shade400,
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
