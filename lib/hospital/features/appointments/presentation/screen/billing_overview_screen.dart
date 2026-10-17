import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../data/repositories/appointment_repo.dart';
import 'booking_succsess_screen.dart';

class BillingOverviewScreen extends StatefulWidget {
  final Map<String, dynamic>? appointmentData;
  final Map<String, dynamic>? razorpayData;
  final Map<String, dynamic>? doctorData;

  const BillingOverviewScreen({
    super.key,
    this.appointmentData,
    this.razorpayData,
    this.doctorData,
  });

  @override
  State<BillingOverviewScreen> createState() => _BillingOverviewScreenState();
}

class _BillingOverviewScreenState extends State<BillingOverviewScreen> {
  late Razorpay _razorpay;
  String _selectedMethod = 'Razorpay';
  bool _isLoadingGateways = true;
  bool _isVerifying = false;

  Map<String, dynamic>? _razorpayGateway;

  dynamic get _rawFee {
    final doc = widget.doctorData;
    final appt = widget.appointmentData;
    final rzp = widget.razorpayData;

    // 1. Doctor's fee is the primary source of truth
    final docFee = doc?['consultation_fees'] ?? doc?['fee'] ?? doc?['fees'];
    if (docFee != null && docFee.toString().trim().isNotEmpty) {
      return docFee;
    }

    // 2. Appointment payload fee
    final apptFee = appt?['consultation_fees'] ??
        appt?['fees'] ??
        appt?['fee'] ??
        appt?['amount'];
    if (apptFee != null && apptFee.toString().trim().isNotEmpty) {
      return apptFee;
    }

    // 3. Razorpay order amount if available
    final rzpAmt = rzp?['amount'];
    if (rzpAmt is num && rzpAmt > 0) {
      return (rzpAmt / 100);
    }

    return 500;
  }

  String get _displayFees {
    final val = _rawFee;
    final s = val.toString().trim().replaceAll('₹', '');
    return '₹$s';
  }

  num get _feesNum {
    final val = _rawFee;
    if (val is num) return val;
    final clean = val.toString().replaceAll('₹', '').trim();
    return num.tryParse(clean) ?? 500;
  }

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _fetchPaymentGateways();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint(
        'Razorpay Success: paymentId=${response.paymentId}, orderId=${response.orderId}, signature=${response.signature}');

    final appt = widget.appointmentData;
    final rzp = widget.razorpayData;

    final String apptId = appt?['id']?.toString() ??
        appt?['appointment_id']?.toString() ??
        appt?['data']?['id']?.toString() ??
        '';

    final String hospitalDomain = appt?['hospital'] is Map
        ? ((appt!['hospital'] as Map)['domain']?.toString() ??
            (appt['hospital'] as Map)['name']?.toString() ??
            '')
        : (appt?['hospital']?.toString() ?? '');

    final String apptNo = appt?['appointment_no']?.toString() ??
        rzp?['order_id']?.toString() ??
        response.orderId ??
        '';

    final String docName = appt?['doctor_name']?.toString() ??
        widget.doctorData?['name']?.toString() ??
        '';
    final String dateStr = appt?['appointment_date']?.toString() ?? '';
    final String slotStr = appt?['slot']?.toString() ?? '';
    final String feesStr = _displayFees;

    if (mounted) {
      setState(() {
        _isVerifying = true;
      });
    }

    final res = await verifyPayment(
      appointmentId: apptId,
      hospitalDomain: hospitalDomain,
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );

    if (!mounted) return;
    setState(() {
      _isVerifying = false;
    });

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Payment verified successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccsessScreen(
            bookingId: apptNo,
            title: 'Appointment Payment Successful',
            doctorName: docName,
            amount: feesStr,
            date: dateStr,
            time: slotStr,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Payment verification failed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Razorpay Error: ${response.code} - ${response.message}');
    if (mounted) {
      setState(() {
        _isVerifying = false;
      });
      _cancelDraftAppointment();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment cancelled / failed: ${response.message ?? ''}. Appointment is NOT booked.',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _cancelDraftAppointment() async {
    try {
      final appt = widget.appointmentData;
      final apptId =
          appt?['id']?.toString() ?? appt?['appointment_id']?.toString();
      if (apptId != null && apptId.isNotEmpty) {
        final repo = AppointmentRepo();
        await repo.cancelAppointment(apptId);
      }
    } catch (e) {
      debugPrint('Error cancelling unpaid draft appointment: $e');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay External Wallet: ${response.walletName}');
  }

  Future<void> _fetchPaymentGateways() async {
    setState(() {
      _isLoadingGateways = true;
    });

    try {
      final repo = AppointmentRepo();
      final decoded = await repo.fetchPaymentGateways();

      if (decoded['status'] == true) {
        final data = decoded['data'] ?? {};
        final gatewaysList =
            (data['gateways'] is List) ? (data['gateways'] as List) : [];
        Map<String, dynamic>? rzp;
        for (var g in gatewaysList) {
          if (g is Map<String, dynamic> && g['slug'] == 'razorpay') {
            rzp = g;
            break;
          }
        }

        if (!mounted) return;
        setState(() {
          _razorpayGateway = rzp;
          _isLoadingGateways = false;
          if (rzp != null && rzp['active'] == true) {
            _selectedMethod = 'Razorpay';
          } else {
            _selectedMethod = 'Cash';
          }
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoadingGateways = false;
        });
      }
    } catch (e) {
      debugPrint('Exception fetching gateways: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingGateways = false;
      });
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String appointmentId,
    required String hospitalDomain,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    try {
      final repo = AppointmentRepo();
      final decoded = await repo.verifyPayment(
        appointmentId: appointmentId,
        hospitalDomain: hospitalDomain,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      final isSuccess = decoded['status'] == true || decoded['success'] == true;
      return {
        'success': isSuccess,
        'message': decoded['message'] ??
            (isSuccess
                ? 'Payment verified successfully.'
                : 'Payment verification failed.'),
        'data': decoded['data'],
      };
    } catch (e) {
      debugPrint('Exception in verifyPayment: $e');
      return {
        'success': false,
        'message': 'Error verifying payment: $e',
      };
    }
  }

  Future<void> _handlePaymentConfirm() async {
    if (_isVerifying) return;

    final appt = widget.appointmentData;
    final rzp = widget.razorpayData;

    // 1. If Online Gateway (Razorpay) is selected
    if (_selectedMethod == 'Razorpay') {
      final keyId = (_razorpayGateway?['credentials'] is Map
              ? _razorpayGateway!['credentials']['key_id']
              : null) ??
          rzp?['key_id'] ??
          'rzp_test_TWIAoYszpcVthe';

      final num feesNum = _feesNum;
      final int amountInPaise = (feesNum * 100).toInt();

      final String hospName = appt?['hospital'] is Map
          ? ((appt!['hospital'] as Map)['name']?.toString() ?? 'Hospital')
          : (appt?['hospital']?.toString() ?? 'Hospital');

      final String docName = appt?['doctor_name']?.toString() ??
          widget.doctorData?['name']?.toString() ??
          '';

      Map<String, dynamic>? rzpObj;
      if (appt?['razorpay'] is Map<String, dynamic>) {
        rzpObj = appt!['razorpay'] as Map<String, dynamic>;
      } else if (rzp is Map<String, dynamic>) {
        rzpObj = rzp;
      }

      final String rzpOrderId = rzpObj?['order_id']?.toString() ??
          rzpObj?['razorpay_order_id']?.toString() ??
          appt?['razorpay_order_id']?.toString() ??
          '';

      var options = {
        'key': keyId,
        'amount': amountInPaise,
        'name': hospName,
        'description': docName.isNotEmpty
            ? 'Consultation Fee for $docName'
            : 'Appointment Fee Payment',
        if (rzpOrderId.isNotEmpty &&
            !rzpOrderId.startsWith('order_17') &&
            (rzpObj?['amount'] == null || rzpObj!['amount'] == amountInPaise))
          'order_id': rzpOrderId,
        'prefill': {
          'contact': appt?['phone']?.toString() ?? '',
          'email': appt?['email']?.toString() ?? '',
        },
      };

      try {
        debugPrint('Opening Razorpay options: $options');
        _razorpay.open(options);
        // Razorpay SDK is now opened.
        // We do NOT navigate here! Razorpay will call _handlePaymentSuccess on success
        // or _handlePaymentError on failure/cancellation.
      } catch (e) {
        debugPrint('Error launching Razorpay: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error launching payment gateway: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      return;
    }

    // 2. If Cash (Pay at Hospital Counter)
    if (_selectedMethod == 'Cash') {
      setState(() {
        _isVerifying = true;
      });

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
      });

      final String apptNo = appt?['appointment_no']?.toString() ??
          'APT-${DateTime.now().millisecondsSinceEpoch % 10000}';
      final String docName = appt?['doctor_name']?.toString() ?? 'Doctor';
      final String dateStr = appt?['appointment_date']?.toString() ?? '';
      final String slotStr = appt?['slot']?.toString() ?? '';
      final String feesStr = appt?['fees'] != null
          ? '₹${appt!['fees']}'
          : (rzp?['amount'] != null
              ? '₹${(rzp!['amount'] as num) / 100}'
              : '₹500');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment confirmed! Pay at counter upon arrival.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccsessScreen(
            bookingId: apptNo,
            title: 'Appointment Booked (Pay at Counter)',
            doctorName: docName,
            amount: feesStr,
            date: dateStr,
            time: slotStr,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Cancel Appointment?'),
            content: const Text(
              'Your appointment has not been booked yet. If you exit now, payment will not be completed and the slot will not be reserved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Stay & Pay'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Exit Without Booking'),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          await _cancelDraftAppointment();
          if (!context.mounted) return;
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          title: const Text(
            'Payment Gateway',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: colorWhite),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderCard(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Select Payment Gateway'),
                  const SizedBox(height: 12),
                  if (_isLoadingGateways)
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    )
                  else ...[
                    // Razorpay Option
                    if (_razorpayGateway != null)
                      _buildGatewayTile(
                        title: 'Online Gateway',
                        subtitle: 'Pay securely via UPI, Cards & NetBanking',
                        icon: Icons.account_balance_wallet,
                        value: 'Razorpay',
                        badgeText: 'Active',
                      ),

                    // Cash Option
                    _buildGatewayTile(
                      title: 'Pay at Hospital Counter',
                      subtitle: 'Pay cash directly upon arrival at clinic',
                      icon: Icons.money,
                      value: 'Cash',
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildSectionTitle('Appointment Information'),
                  const SizedBox(height: 12),
                  _buildSummaryBox(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomPayButton(),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final appt = widget.appointmentData;
    final String feesStr = _displayFees;

    final String hospName = appt?['hospital'] is Map
        ? ((appt!['hospital'] as Map)['name']?.toString() ?? 'Hospital')
        : (appt?['hospital']?.toString() ?? 'Hospital');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Appointment Payment ($hospName)',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            feesStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeaderStat(
                'Appt No',
                'Pending',
                valueColor: Colors.amberAccent,
              ),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildHeaderStat(
                'Status',
                'Pending Payment',
                valueColor: Colors.amberAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, color: Colors.white70, size: 14),
                SizedBox(width: 6),
                Text(
                  'Complete payment to confirm booking',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
    );
  }

  Widget _buildGatewayTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    String? badgeText,
  }) {
    bool isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? fillColor : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : borderGrey,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.1)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? primaryColor : textDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                          color: isSelected ? primaryColor : textDark,
                        ),
                      ),
                      if (badgeText != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: textMuted),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryColor : colorGrey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBox() {
    final appt = widget.appointmentData;
    final doc = widget.doctorData;
    final String docName = appt?['doctor_name']?.toString() ??
        doc?['name']?.toString() ??
        'Doctor';
    final String dateStr = appt?['appointment_date']?.toString() ?? '';
    final String slotStr = appt?['slot']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Doctor Name', docName),
          if (dateStr.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Appointment Date', dateStr),
          ],
          if (slotStr.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Time Slot', slotStr),
          ],
          const SizedBox(height: 8),
          _buildSummaryRow('Consultation Fee', _displayFees),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: textMuted, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(
              color: textDark, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildBottomPayButton() {
    final String feesStr = _displayFees;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isVerifying ? null : _handlePaymentConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  _selectedMethod == 'Cash'
                      ? 'Confirm Booking (Pay at Hospital Counter)'
                      : 'Pay $feesStr via $_selectedMethod',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
        ),
      ),
    );
  }
}
