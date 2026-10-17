import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../../controllers/auth_controller.dart';
import '../../../../core/constants/colors.dart';
import '../../../appointments/presentation/screen/booking_succsess_screen.dart';
import '../../../lab_reports/controller/lab_controller.dart';
import '../../../lab_reports/data/model/lab_model.dart';
import 'package:vlr/views/base/dialogs/login_required_dialog.dart';

class LabTestsScreen extends StatefulWidget {
  final DiagnosticLabModel? lab;
  final String? userId;
  final LabTestModel? initialTest;

  const LabTestsScreen({
    Key? key,
    this.lab,
    this.userId,
    this.initialTest,
  }) : super(key: key);

  @override
  State<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends State<LabTestsScreen> {
  late final LabController controller;
  late final Razorpay _razorpay;
  DiagnosticLabModel? _selectedLab;
  LabBookingResponse? _activeBooking;

  int _selectedTestIndex = 0;
  String _customTestName = 'Blood Test';
  final num _defaultTestPrice = 250;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LabController>()
        ? Get.find<LabController>()
        : Get.put(LabController());

    _selectedLab = widget.lab;

    _initRazorpay();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch dynamic tests from API: api/v1/hospital/lab/tests
      controller.fetchTests(category: _selectedLab?.category);

      if (_selectedLab == null && controller.diagnosticLabs.isNotEmpty) {
        setState(() {
          _selectedLab = controller.diagnosticLabs.first;
        });
      } else if (controller.diagnosticLabs.isEmpty) {
        controller.fetchLabListing().then((_) {
          if (mounted && _selectedLab == null && controller.diagnosticLabs.isNotEmpty) {
            setState(() {
              _selectedLab = controller.diagnosticLabs.first;
            });
          }
        });
      }
    });
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment Success: ${response.paymentId}, orderId: ${response.orderId}');
    if (_activeBooking == null) return;

    final booking = _activeBooking!;
    final hospDomain = booking.hospital?.domain ??
        _selectedLab?.hospital?.domain ??
        'usha';

    try {
      await controller.verifyPayment(
        razorpayOrderId:
            response.orderId ?? booking.razorpay?.orderId ?? 'order_dummy',
        razorpayPaymentId: response.paymentId ?? 'pay_dummy',
        razorpaySignature: response.signature ?? 'sig_dummy',
        bookingId: booking.bookingId ?? 0,
        hospital: hospDomain,
      );
    } catch (e) {
      debugPrint('Verify payment error: $e');
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingSuccsessScreen(
          bookingId: booking.bookingNo ?? 'LAB-${DateTime.now().millisecondsSinceEpoch}',
          title: booking.testName ?? 'Lab Test',
          doctorName: '${booking.labName ?? _selectedLab?.labName ?? "Diagnostic Lab"} (Paid Online)',
          amount: '₹${booking.netAmount ?? _defaultTestPrice}',
          date: booking.bookingDate ?? DateTime.now().toString().split(' ')[0],
        ),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Failed: ${response.code} - ${response.message}');
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Payment transaction was not completed.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: errorColor,
      colorText: colorWhite,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: ${response.walletName}');
  }

  void _openRazorpay(LabBookingResponse bookingRes) {
    _activeBooking = bookingRes;
    final rzp = bookingRes.razorpay!;

    final options = {
      'key': rzp.key ?? 'rzp_test_TWIAoYszpcVthe',
      'amount': rzp.amount ?? (((bookingRes.netAmount ?? _defaultTestPrice)) * 100).toInt(),
      'name': rzp.name ?? _selectedLab?.labName ?? 'Hospital Diagnostic Lab',
      'description': rzp.description ??
          'Lab Test: ${bookingRes.testName ?? "Test"} (${bookingRes.bookingNo ?? ""})',
      if (rzp.orderId != null && rzp.orderId!.isNotEmpty)
        'order_id': rzp.orderId,
      'prefill': {
        'name': rzp.prefill?.name ?? bookingRes.patientName ?? '',
        'contact': rzp.prefill?.contact ?? bookingRes.patientPhone ?? '',
        'email': rzp.prefill?.email ?? '',
      },
    };

    try {
      debugPrint('Opening Razorpay native modal: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay native open failed (desktop/emulator fallback): $e');
      _showFallbackPaymentDialog(bookingRes);
    }
  }

  void _showFallbackPaymentDialog(LabBookingResponse bookingRes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.payment_rounded, color: primaryColor),
            SizedBox(width: 8),
            Text('Razorpay Online Gateway', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Booking No: ${bookingRes.bookingNo}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Amount: ₹${bookingRes.netAmount ?? _defaultTestPrice}'),
            const SizedBox(height: 6),
            Text('Lab: ${bookingRes.labName ?? _selectedLab?.labName}'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Simulate payment success to test verification & complete your booking.',
                style: TextStyle(fontSize: 12, color: textDark),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingSuccsessScreen(
                    bookingId: bookingRes.bookingNo ?? 'LAB-PENDING',
                    title: bookingRes.testName ?? 'Lab Test',
                    doctorName: bookingRes.labName ?? 'Diagnostic Lab',
                    amount: '₹${bookingRes.netAmount ?? _defaultTestPrice}',
                    date: bookingRes.bookingDate,
                  ),
                ),
              );
            },
            child: const Text('Pay Later / Skip', style: TextStyle(color: textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _handlePaymentSuccess(PaymentSuccessResponse(
                'pay_test_${DateTime.now().millisecondsSinceEpoch}',
                bookingRes.razorpay?.orderId ?? 'order_simulated',
                'sig_simulated_${DateTime.now().millisecondsSinceEpoch}',
                null,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('SIMULATE SUCCESS', style: TextStyle(color: colorWhite)),
          ),
        ],
      ),
    );
  }

  void _showBookingBottomSheet({required String selectedTestName, required num testPrice}) {
    final activeLab = _selectedLab ??
        (controller.diagnosticLabs.isNotEmpty
            ? controller.diagnosticLabs.first
            : null);

    if (activeLab == null) {
      Get.snackbar(
        'Select Lab',
        'Please select a diagnostic lab before booking',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: warningColor,
        colorText: colorWhite,
      );
      return;
    }

    final AuthController? auth =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

    final testNameController = TextEditingController(text: selectedTestName);
    final nameController = TextEditingController(
      text: auth?.fullNameController.text.isNotEmpty == true
          ? auth!.fullNameController.text
          : 'John Doe',
    );
    final phoneController = TextEditingController(
      text: auth?.mobileNoController.text.isNotEmpty == true
          ? auth!.mobileNoController.text
          : '9876543210',
    );
    final addressController = TextEditingController(
      text: activeLab.address ?? '123 Main Street, Lucknow',
    );

    String collectionType = 'Home';
    DateTime bookingDate = DateTime.now();
    String paymentMode = 'Cash'; // Default: Cash or Online

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: colorWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Book Lab Test',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeLab.labName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: textMuted),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Test Name Field
                    const Text('Diagnostic Test to Book',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: testNameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.biotech_rounded, color: primaryColor, size: 22),
                        suffixText: '₹$testPrice',
                        suffixStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontSize: 15,
                        ),
                        hintText: 'Enter test name (e.g. Blood Test, CBC)',
                        filled: true,
                        fillColor: backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Patient Name
                    const Text('Patient Name',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person_outline, color: primaryColor, size: 20),
                        hintText: 'Enter full name',
                        filled: true,
                        fillColor: backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phone Number
                    const Text('Phone Number',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_outlined, color: primaryColor, size: 20),
                        hintText: '10-digit mobile number',
                        filled: true,
                        fillColor: backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Address
                    const Text('Sample Collection Address',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_on_outlined, color: primaryColor, size: 20),
                        hintText: 'Complete street address, city, pincode',
                        filled: true,
                        fillColor: backgroundColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Collection Type: Home vs Lab Center
                    const Text('Sample Collection Type',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => collectionType = 'Home'),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: collectionType == 'Home' ? primaryColor : backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: collectionType == 'Home' ? primaryColor : borderGrey,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.home_rounded,
                                    size: 16,
                                    color: collectionType == 'Home' ? colorWhite : textDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Home Pickup',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: collectionType == 'Home' ? colorWhite : textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => setModalState(() => collectionType = 'Center'),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: collectionType == 'Center' ? primaryColor : backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: collectionType == 'Center' ? primaryColor : borderGrey,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.store_mall_directory_rounded,
                                    size: 16,
                                    color: collectionType == 'Center' ? colorWhite : textDark,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Lab Visit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: collectionType == 'Center' ? colorWhite : textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Booking Date',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark)),
                            const SizedBox(height: 2),
                            Text(
                              bookingDate.toString().split(' ')[0],
                              style: const TextStyle(fontSize: 13, color: primaryColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: bookingDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                            );
                            if (picked != null) {
                              setModalState(() => bookingDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_today_rounded, size: 16, color: primaryColor),
                          label: const Text('Change Date', style: TextStyle(color: primaryColor)),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Payment Mode (Cash vs Online)
                    const Text('Choose Payment Option',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                    const SizedBox(height: 8),

                    // Cash Option
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: paymentMode == 'Cash' ? fillColor : backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: paymentMode == 'Cash' ? primaryColor : borderGrey,
                          width: paymentMode == 'Cash' ? 1.5 : 1,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: 'Cash',
                        groupValue: paymentMode,
                        activeColor: primaryColor,
                        title: const Text(
                          'Cash on Sample Collection',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: const Text(
                          'Pay cash directly when sample is collected or at the lab center',
                          style: TextStyle(fontSize: 11, color: textMuted),
                        ),
                        secondary: const Icon(Icons.payments_outlined, color: successColor),
                        onChanged: (val) {
                          if (val != null) setModalState(() => paymentMode = val);
                        },
                      ),
                    ),

                    // Online Option
                    Container(
                      decoration: BoxDecoration(
                        color: paymentMode == 'Online' ? fillColor : backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: paymentMode == 'Online' ? primaryColor : borderGrey,
                          width: paymentMode == 'Online' ? 1.5 : 1,
                        ),
                      ),
                      child: RadioListTile<String>(
                        value: 'Online',
                        groupValue: paymentMode,
                        activeColor: primaryColor,
                        title: const Text(
                          'Online Payment (Razorpay / UPI / Cards)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        subtitle: const Text(
                          'Pay instantly and securely via Razorpay gateway',
                          style: TextStyle(fontSize: 11, color: textMuted),
                        ),
                        secondary: const Icon(Icons.credit_card_rounded, color: primaryColor),
                        onChanged: (val) {
                          if (val != null) setModalState(() => paymentMode = val);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    Obx(() {
                      final isBooking = controller.isBookingLoading.value;
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isBooking
                              ? null
                              : () async {
                                  final bool isLoggedIn =
                                      Get.isRegistered<AuthController>() &&
                                          Get.find<AuthController>()
                                              .isLoggedIn();
                                  if (!isLoggedIn) {
                                    showLoginRequiredDialog(
                                      context: context,
                                      title: "Login Required",
                                      message:
                                          "Please login to your account first before booking a diagnostic lab test.",
                                    );
                                    return;
                                  }

                                  final pName = nameController.text.trim();
                                  final pPhone = phoneController.text.trim();
                                  final pAddr = addressController.text.trim();
                                  final pTest = testNameController.text.trim();

                                  if (pTest.isEmpty) {
                                    Get.snackbar('Validation', 'Please enter diagnostic test name',
                                        backgroundColor: warningColor, colorText: colorWhite);
                                    return;
                                  }
                                  if (pName.isEmpty) {
                                    Get.snackbar('Validation', 'Please enter patient name',
                                        backgroundColor: warningColor, colorText: colorWhite);
                                    return;
                                  }
                                  if (pPhone.isEmpty || pPhone.length < 10) {
                                    Get.snackbar('Validation', 'Please enter a valid 10-digit phone',
                                        backgroundColor: warningColor, colorText: colorWhite);
                                    return;
                                  }

                                  final hosp = activeLab.hospital?.domain ?? 'usha';
                                  final dateStr = bookingDate.toString().split(' ')[0];

                                  final res = await controller.bookTest(
                                    patientName: pName,
                                    patientPhone: pPhone,
                                    address: pAddr,
                                    testName: pTest,
                                    collectionType: collectionType,
                                    bookingDate: dateStr,
                                    paymentMode: paymentMode,
                                    hospital: hosp,
                                    labId: activeLab.id,
                                  );

                                  if (res != null && res.success) {
                                    Navigator.pop(ctx); // Close bottomsheet

                                    if (paymentMode == 'Cash') {
                                      // Instant booking success for Cash
                                      if (!mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BookingSuccsessScreen(
                                            bookingId: res.bookingNo ??
                                                'LAB-${DateTime.now().millisecondsSinceEpoch}',
                                            title: res.testName ?? pTest,
                                            doctorName: '${res.labName ?? activeLab.labName} (Cash on Collection)',
                                            amount: '₹${res.netAmount ?? testPrice}',
                                            date: res.bookingDate ?? dateStr,
                                          ),
                                        ),
                                      );
                                    } else {
                                      // Online mode: Launch Razorpay
                                      if (res.razorpay != null) {
                                        _openRazorpay(res);
                                      } else {
                                        // Fallback if razorpay block is omitted
                                        if (!mounted) return;
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => BookingSuccsessScreen(
                                              bookingId: res.bookingNo ??
                                                  'LAB-${DateTime.now().millisecondsSinceEpoch}',
                                              title: res.testName ?? pTest,
                                              doctorName: res.labName ?? activeLab.labName,
                                              amount: '₹${res.netAmount ?? testPrice}',
                                              date: res.bookingDate ?? dateStr,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isBooking
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(color: colorWhite, strokeWidth: 2.5),
                                )
                              : Text(
                                  paymentMode == 'Cash'
                                      ? 'CONFIRM BOOKING (CASH)'
                                      : 'PAY ONLINE & BOOK (RAZORPAY)',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: colorWhite,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Text(
          _selectedLab != null ? _selectedLab!.labName : 'Lab Test Booking',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorWhite,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: colorWhite),
            onPressed: () {
              controller.fetchTests(category: _selectedLab?.category);
            },
          ),
        ],
      ),
      body: Obx(() {
        final labs = controller.diagnosticLabs;
        final activeLab = _selectedLab ?? (labs.isNotEmpty ? labs.first : null);
        final dynamicTests = controller.tests;

        if (controller.isLoading.value && activeLab == null) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }

        // Selected test information
        final hasApiTests = dynamicTests.isNotEmpty;
        final selectedApiTest = hasApiTests
            ? dynamicTests[_selectedTestIndex.clamp(0, dynamicTests.length - 1)]
            : null;

        final currentTestName = selectedApiTest?.testName ?? _customTestName;
        final currentTestPrice = selectedApiTest != null
            ? (selectedApiTest.basePrice > 0 ? selectedApiTest.basePrice : _defaultTestPrice)
            : _defaultTestPrice;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected Lab Info Banner
                    if (activeLab != null) _buildLabHeader(activeLab, labs),

                    const SizedBox(height: 20),

                    // Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Diagnostic Tests',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hasApiTests ? '${dynamicTests.length} Tests' : 'Direct Booking',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Dynamic API Tests or Direct Booking card
                    if (controller.isTestsLoading.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      )
                    else if (hasApiTests)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dynamicTests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final test = dynamicTests[index];
                          final isSelected = _selectedTestIndex == index;
                          return _buildApiTestCard(test, index, isSelected);
                        },
                      )
                    else
                      // If API returns 0 tests (tests: []), show clean direct booking card
                      _buildDirectBookingCard(activeLab),

                    const SizedBox(height: 24),

                    // Test Preparation Guide
                    _buildPrepGuide(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Book Bar
            _buildBottomBar(
              testName: currentTestName,
              testPrice: currentTestPrice,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLabHeader(DiagnosticLabModel activeLab, List<DiagnosticLabModel> allLabs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_hospital_rounded, color: primaryColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeLab.labName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${activeLab.category ?? "Diagnostic"} • ${activeLab.hospital?.name ?? "ERP Partner"}',
                      style: const TextStyle(fontSize: 12, color: textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 2),
                    Text(
                      '${activeLab.rating}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: lightGrey),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  activeLab.location ?? activeLab.address ?? 'Lucknow, Uttar Pradesh',
                  style: const TextStyle(fontSize: 11, color: textDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.schedule_rounded, size: 14, color: textMuted),
              const SizedBox(width: 4),
              Text(
                activeLab.timing ?? '07:30 AM - 08:30 PM',
                style: const TextStyle(fontSize: 11, color: textMuted),
              ),
            ],
          ),

          // Switch lab dropdown if multiple labs exist
          if (allLabs.length > 1) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                _showSwitchLabModal(allLabs);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Change Diagnostic Center',
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      )),
                  Icon(Icons.arrow_drop_down, color: primaryColor, size: 18),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSwitchLabModal(List<DiagnosticLabModel> allLabs) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Diagnostic Center',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
              const SizedBox(height: 12),
              ...allLabs.map((lab) {
                final isCur = lab.id == _selectedLab?.id;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.science_rounded, color: primaryColor),
                  title: Text(lab.labName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${lab.category ?? ""} • ${lab.city ?? ""}'),
                  trailing: isCur
                      ? const Icon(Icons.check_circle, color: primaryColor)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedLab = lab;
                      _selectedTestIndex = 0;
                    });
                    controller.fetchTests(category: lab.category);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Dynamic API Test Card from api/v1/hospital/lab/tests
  Widget _buildApiTestCard(LabTestModel test, int index, bool isSelected) {
    final price = test.basePrice > 0
        ? test.basePrice
        : (test.standardCharge > 0 ? test.standardCharge : _defaultTestPrice);

    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? primaryColor : borderGrey,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() => _selectedTestIndex = index);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected ? fillColor : backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                        color: isSelected ? primaryColor : textMuted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.testName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? primaryColor : textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            test.description ?? '${test.category ?? "Diagnostic"} pathology examination',
                            style: const TextStyle(fontSize: 11, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹$price',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: lightGrey),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        test.subCategory ?? test.category ?? 'Diagnostic Test',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.timer_outlined, size: 12, color: textMuted),
                    const SizedBox(width: 3),
                    Text(
                      test.reportTime ?? '${test.reportDays * 24} Hours',
                      style: const TextStyle(fontSize: 10, color: textMuted),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.science_outlined, size: 12, color: textMuted),
                    const SizedBox(width: 3),
                    Text(
                      test.sampleType ?? 'Blood Specimen',
                      style: const TextStyle(fontSize: 10, color: textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Clean Direct Booking Card (When API returns 0 catalog tests)
  Widget _buildDirectBookingCard(DiagnosticLabModel? activeLab) {
    final suggestions = ['Blood Test', 'Pathology Screening', 'Biochemistry Test', 'Urine Routine'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.biotech_rounded, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Direct Diagnostic Booking',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    Text(
                      'Specify the test required for home collection or visit',
                      style: TextStyle(fontSize: 11, color: textMuted),
                    ),
                  ],
                ),
              ),
              const Text(
                '₹250',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Suggested quick selections
          const Text(
            'Select Test Name:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: suggestions.map((s) {
              final isSel = _customTestName.toLowerCase() == s.toLowerCase();
              return InkWell(
                onTap: () => setState(() => _customTestName = s),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSel ? primaryColor : backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSel ? primaryColor : borderGrey),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                      color: isSel ? colorWhite : textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
          TextField(
            onChanged: (val) {
              if (val.trim().isNotEmpty) {
                _customTestName = val.trim();
              }
            },
            decoration: InputDecoration(
              hintText: 'Or enter specific test (e.g. Blood Test)',
              hintStyle: const TextStyle(fontSize: 12, color: textMuted),
              filled: true,
              fillColor: backgroundColor,
              prefixIcon: const Icon(Icons.edit_note_rounded, color: primaryColor, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrepGuide() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: primaryColor, size: 18),
              SizedBox(width: 6),
              Text(
                'Important Test Guidelines',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Drink plenty of water before blood collection unless advised otherwise.\n• For fasting tests, maintain 10-12 hours fasting overnight.\n• Home collection technician will carry certified sterile equipment.',
            style: TextStyle(fontSize: 11, color: textDark, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar({required String testName, required num testPrice}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: colorWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total Payable', style: TextStyle(fontSize: 11, color: textMuted)),
              Text(
                '₹$testPrice',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _showBookingBottomSheet(
                  selectedTestName: testName,
                  testPrice: testPrice,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'BOOK TEST NOW',
                style: TextStyle(
                  color: colorWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
