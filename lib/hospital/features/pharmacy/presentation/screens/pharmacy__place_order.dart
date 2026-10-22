import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/hospital/core/constants/colors.dart';

import '../../data/model/order_model.dart';
import '../../logics/pharmacy_controller.dart';
import 'package:vlr/hospital/features/profile/logics/hospital_profile_controller.dart';
import 'payment_verifed_screen.dart';

class PharmacyPlaceOrderScreen extends StatefulWidget {
  const PharmacyPlaceOrderScreen({super.key});

  @override
  State<PharmacyPlaceOrderScreen> createState() =>
      _PharmacyPlaceOrderScreenState();
}

class _PharmacyPlaceOrderScreenState extends State<PharmacyPlaceOrderScreen> {
  late final PharmacyController controller;
  late final Razorpay _razorpay;
  PlaceOrderResponse? _activeOrder;
  List<CartItem>? _lastCartSnapshot;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _paymentMode = 'online';

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PharmacyController>()
        ? Get.find<PharmacyController>()
        : Get.put(PharmacyController());

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _loadProfileData();
  }

  void _loadProfileData() {
    try {
      final auth = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : null;
      if (auth?.userModel != null) {
        final u = auth!.userModel!;
        final uName = u.name?.toString().trim() ?? '';
        final uPhone = u.phone?.toString().trim() ?? '';
        final uEmail = u.email?.toString().trim() ?? '';

        if (_nameController.text.isEmpty && uName.isNotEmpty) {
          _nameController.text = uName;
        }
        if (_phoneController.text.isEmpty && uPhone.isNotEmpty) {
          _phoneController.text = uPhone;
        }
        if (_emailController.text.isEmpty && uEmail.isNotEmpty) {
          _emailController.text = uEmail;
        }
      }

      final profile = Get.isRegistered<HospitalProfileController>()
          ? Get.find<HospitalProfileController>()
          : null;
      if (profile != null) {
        if (_nameController.text.isEmpty &&
            profile.displayName.isNotEmpty &&
            profile.displayName != 'Loading...' &&
            profile.displayName != 'Guest') {
          _nameController.text = profile.displayName;
        }
        if (_phoneController.text.isEmpty && profile.phone.isNotEmpty) {
          _phoneController.text = profile.phone;
        }
        if (_emailController.text.isEmpty && profile.email.isNotEmpty) {
          _emailController.text = profile.email;
        }
        final p = profile.patient.value;
        if (_addressController.text.isEmpty &&
            p != null &&
            p['address'] != null &&
            p['address'].toString().isNotEmpty) {
          _addressController.text = p['address'].toString();
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    if (controller.cart.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Please add medicines to your cart before placing an order.',
            ),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
      return;
    }

    // Auto-fill defaults if user left fields blank
    if (_nameController.text.trim().isEmpty) {
      _nameController.text = 'Patient';
    }
    if (_phoneController.text.trim().isEmpty) {
      _phoneController.text = '9876543210';
    }
    if (_addressController.text.trim().isEmpty) {
      _addressController.text = 'Hospital Ward / Home Delivery Address';
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();

    final firstMed = controller.cart.values.firstOrNull?.medicine;
    final hospitalDomain = (firstMed?.hospital?.domain != null &&
            firstMed!.hospital!.domain!.isNotEmpty)
        ? firstMed.hospital!.domain!
        : (controller.stores.isNotEmpty &&
                controller.stores.first.hospitalDomain != null &&
                controller.stores.first.hospitalDomain!.isNotEmpty)
            ? controller.stores.first.hospitalDomain!
            : (controller.categories.isNotEmpty &&
                    controller.categories.first.hospitalDomain != null &&
                    controller.categories.first.hospitalDomain!.isNotEmpty)
                ? controller.categories.first.hospitalDomain!
                : 'usha';

    final isCash = (_paymentMode == 'cash' ||
        _paymentMode == 'cod' ||
        _paymentMode.toLowerCase().contains('cash') ||
        _paymentMode.toLowerCase().contains('cod'));

    final cartSnapshot = controller.cart.values
        .map((item) => CartItem(
              medicine: item.medicine,
              qty: item.qty,
              selectedBatch: item.selectedBatch,
            ))
        .toList();
    _lastCartSnapshot = cartSnapshot;

    final orderRes = await controller.placeOrder(
      customerName: name,
      customerPhone: phone,
      customerEmail: email,
      shippingAddress: address,
      paymentMode: isCash ? 'Cash on Delivery (COD)' : 'Razorpay',
      hospital: hospitalDomain,
    );

    if (orderRes != null && orderRes.success) {
      if (isCash) {
        // Cash On Delivery: Order directly confirmed with immediate Order Number!
        final orderNo = orderRes.groupOrderNo ??
            orderRes.billNo ??
            (orderRes.bills.isNotEmpty
                ? (orderRes.bills.first.groupOrderNo ??
                    orderRes.bills.first.billNo)
                : null) ??
            (orderRes.billId != null
                ? 'MED-ORD-${orderRes.billId}'
                : 'MED-${DateTime.now().millisecondsSinceEpoch}');
        final bId = orderRes.billId ??
            (orderRes.bills.isNotEmpty ? orderRes.bills.first.billId : null);

        controller.clearCart();

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentVerifedScreen(
                placeOrderResponse: orderRes,
                billId: bId,
                groupOrderNo: orderNo,
                paymentMode: 'Cash on Delivery (COD)',
                grandTotal: orderRes.grandTotal ?? controller.cartGrandTotal,
                hospitalName: orderRes.hospital?.name ??
                    orderRes.labName ??
                    orderRes.storeName ??
                    firstMed?.hospital?.name,
                isCashOnDelivery: true,
                cartItems: cartSnapshot,
                customerName: name,
                customerPhone: phone,
                deliveryAddress: address,
              ),
            ),
          );
        }
      } else {
        // Online Payment: Launch Razorpay checkout immediately!
        if (orderRes.razorpay?.orderId?.trim().isNotEmpty != true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Payment order details are missing. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
        _activeOrder = orderRes;
        _openRazorpay(orderRes);
      }
    } else {
      final err = controller.errorMessage.value.isNotEmpty
          ? controller.errorMessage.value
          : 'Unable to place order. Please check item availability or connection.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _openRazorpay(PlaceOrderResponse orderRes) {
    final rzp = orderRes.razorpay;
    final firstMed = controller.cart.values.firstOrNull?.medicine;

    final num totalAmount = orderRes.grandTotal ?? controller.cartGrandTotal;
    final rzpAmount = rzp?.amount;
    final rzpAmountRupees = rzp?.amountRupees;
    final int amountInPaise = (rzpAmount != null && rzpAmount > 0)
        ? rzpAmount.toInt()
        : ((rzpAmountRupees != null && rzpAmountRupees > 0)
            ? (rzpAmountRupees * 100).toInt()
            : ((totalAmount > 0 ? totalAmount : 100) * 100).toInt());

    final rzpKey = rzp?.key;
    final String key = (rzpKey != null && rzpKey.isNotEmpty)
        ? rzpKey
        : 'rzp_test_TWIAoYszpcVthe';

    final rzpOrderId = rzp?.orderId;
    final options = {
      'key': key,
      'amount': amountInPaise > 0 ? amountInPaise : 10000,
      'name': rzp?.name ??
          orderRes.hospital?.name ??
          firstMed?.hospital?.name ??
          'Hospital Pharmacy',
      'description': rzp?.description ??
          'Medicine Order #${orderRes.groupOrderNo ?? orderRes.billNo ?? orderRes.billId ?? ""}',
      if (rzpOrderId != null && rzpOrderId.isNotEmpty) 'order_id': rzpOrderId,
      'prefill': {
        'name': rzp?.prefill?.name ??
            (_nameController.text.isNotEmpty
                ? _nameController.text.trim()
                : 'Patient'),
        'contact': rzp?.prefill?.contact ??
            (_phoneController.text.isNotEmpty
                ? _phoneController.text.trim()
                : '9876543210'),
        'email': rzp?.prefill?.email ??
            (_emailController.text.isNotEmpty
                ? _emailController.text.trim()
                : 'patient@hospital.com'),
      },
    };

    try {
      debugPrint('Opening Razorpay with options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint(
          'Razorpay native open failed (desktop/unsupported environment): $e');
      _showRazorpayPaymentDialog(orderRes);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint(
        'Payment Success: paymentId=${response.paymentId}, orderId=${response.orderId}');
    if (_activeOrder == null) {
      Get.snackbar(
        'Order Notice',
        'No pending medicine order found to verify.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    final orderRes = _activeOrder!;
    final hospDomain = orderRes.hospital?.domain ??
        controller.cart.values.firstOrNull?.medicine.hospital?.domain ??
        'usha';

    // Show verification indicator
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: pharmacyTeal),
                SizedBox(height: 16),
                Text(
                  'Verifying Razorpay payment...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Please do not press back or close the app.',
                  style: TextStyle(fontSize: 11, color: textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    final cartSnapshot = _lastCartSnapshot ??
        controller.cart.values
            .map((item) => CartItem(
                  medicine: item.medicine,
                  qty: item.qty,
                  selectedBatch: item.selectedBatch,
                ))
            .toList();

    final razorpayOrderId = response.orderId ?? orderRes.razorpay?.orderId;
    final paymentId = response.paymentId;
    final signature = response.signature;
    if (razorpayOrderId?.isNotEmpty != true ||
        paymentId?.isNotEmpty != true ||
        signature?.isNotEmpty != true) {
      if (Get.isDialogOpen == true) Get.back();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment details could not be verified. Please contact support before placing another order.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 6),
          ),
        );
      }
      return;
    }

    VerifyPaymentResponse? verifyRes;
    try {
      verifyRes = await controller.verifyPayment(
        razorpayOrderId: razorpayOrderId!,
        razorpayPaymentId: paymentId!,
        razorpaySignature: signature!,
        groupOrderNo: orderRes.groupOrderNo ?? orderRes.billNo ?? '',
        billId: orderRes.billId ??
            (orderRes.bills.isNotEmpty ? orderRes.bills.first.billId ?? 0 : 0),
        hospital: hospDomain,
      );
    } catch (e) {
      debugPrint('Payment verification exception: $e');
    }

    if (Get.isDialogOpen == true) Get.back();
    if (!mounted) return;

    if (verifyRes?.success != true) {
      _activeOrder = null;
      final message = verifyRes?.message?.trim().isNotEmpty == true
          ? verifyRes!.message!.trim()
          : controller.errorMessage.value.isNotEmpty
              ? controller.errorMessage.value
              : 'Payment was received, but the order could not be verified. Please contact support before trying again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }

    controller.clearCart();

    final orderNo = (verifyRes?.bills.isNotEmpty == true
            ? (verifyRes!.bills.first.groupOrderNo ??
                verifyRes.bills.first.billNo)
            : null) ??
        orderRes.groupOrderNo ??
        orderRes.billNo ??
        (orderRes.billId != null
            ? 'MED-ORD-${orderRes.billId}'
            : 'MED-${DateTime.now().millisecondsSinceEpoch}');
    final bId = (verifyRes?.bills.isNotEmpty == true
            ? verifyRes!.bills.first.billId
            : null) ??
        orderRes.billId;

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentVerifedScreen(
            verificationData: verifyRes,
            placeOrderResponse: orderRes,
            billId: bId,
            groupOrderNo: orderNo,
            paymentMode: 'Razorpay Online',
            grandTotal: orderRes.grandTotal ??
                (verifyRes?.bills.isNotEmpty == true
                    ? verifyRes!.bills.first.netAmount
                    : null) ??
                controller.cartGrandTotal,
            hospitalName: orderRes.hospital?.name ??
                verifyRes?.hospital?.name ??
                orderRes.labName ??
                orderRes.storeName,
            isCashOnDelivery: false,
            cartItems: cartSnapshot,
            customerName: _nameController.text.trim(),
            customerPhone: _phoneController.text.trim(),
            deliveryAddress: _addressController.text.trim(),
            paymentId: response.paymentId,
          ),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Razorpay Error: ${response.code} - ${response.message}');
    // If Razorpay payment fails or is cancelled: Medicine order is NOT booked!
    _activeOrder = null;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message?.isNotEmpty == true
              ? '${response.message}. Medicine order was NOT placed.'
              : 'Razorpay payment was cancelled or failed. Medicine order was NOT placed.'),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: ${response.walletName}');
  }

  void _showRazorpayPaymentDialog(PlaceOrderResponse orderRes) {
    final rzp = orderRes.razorpay!;
    final hospDomain = orderRes.hospital?.domain ??
        controller.cart.values.firstOrNull?.medicine.hospital?.domain ??
        'usha';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.payment_rounded, color: pharmacyTeal),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Razorpay Gateway',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: pharmacyTealBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Order ID: ${rzp.orderId ?? orderRes.groupOrderNo ?? orderRes.billNo}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: textDark)),
                  const SizedBox(height: 4),
                  Text('Amount: ₹${rzp.amountRupees ?? orderRes.grandTotal}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: pharmacyTeal)),
                  if (rzp.description != null) ...[
                    const SizedBox(height: 4),
                    Text(rzp.description!,
                        style: const TextStyle(fontSize: 11, color: textMuted)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Complete razorpay payment verification below:',
              style: TextStyle(fontSize: 12, color: textDark),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              _activeOrder = null;
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Payment was cancelled. Medicine order was NOT placed.',
                    ),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              }
            },
            child: const Text('Cancel & Abort',
                style: TextStyle(color: textMuted)),
          ),
          Obx(() {
            return ElevatedButton(
              onPressed: controller.isVerifyingPayment.value
                  ? null
                  : () async {
                      Navigator.pop(dialogCtx); // close modal
                      final cartSnapshot = _lastCartSnapshot ??
                          controller.cart.values
                              .map((item) => CartItem(
                                    medicine: item.medicine,
                                    qty: item.qty,
                                    selectedBatch: item.selectedBatch,
                                  ))
                              .toList();
                      final simPayId =
                          'pay_test_${DateTime.now().millisecondsSinceEpoch}';

                      VerifyPaymentResponse? verifyRes;
                      try {
                        verifyRes = await controller.verifyPayment(
                          razorpayOrderId: rzp.orderId ??
                              'order_simulated_${DateTime.now().millisecondsSinceEpoch}',
                          razorpayPaymentId: simPayId,
                          razorpaySignature:
                              'sig_${DateTime.now().millisecondsSinceEpoch}',
                          groupOrderNo:
                              orderRes.groupOrderNo ?? orderRes.billNo ?? '',
                          billId: orderRes.billId ??
                              (orderRes.bills.isNotEmpty
                                  ? orderRes.bills.first.billId ?? 0
                                  : 0),
                          hospital: hospDomain,
                        );
                      } catch (e) {
                        debugPrint('Verification error in test dialog: $e');
                      }

                      if (verifyRes?.success != true) {
                        _activeOrder = null;
                        final message = verifyRes?.message?.trim().isNotEmpty ==
                                true
                            ? verifyRes!.message!.trim()
                            : controller.errorMessage.value.isNotEmpty
                                ? controller.errorMessage.value
                                : 'Payment could not be verified. Please try again or contact support.';
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        }
                        return;
                      }

                      controller.clearCart();
                      final orderNo = (verifyRes?.bills.isNotEmpty == true
                              ? (verifyRes!.bills.first.groupOrderNo ??
                                  verifyRes.bills.first.billNo)
                              : null) ??
                          orderRes.groupOrderNo ??
                          orderRes.billNo ??
                          (orderRes.billId != null
                              ? 'MED-ORD-${orderRes.billId}'
                              : 'MED-${DateTime.now().millisecondsSinceEpoch}');
                      final bId = (verifyRes?.bills.isNotEmpty == true
                              ? verifyRes!.bills.first.billId
                              : null) ??
                          orderRes.billId;

                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentVerifedScreen(
                              verificationData: verifyRes,
                              placeOrderResponse: orderRes,
                              billId: bId,
                              groupOrderNo: orderNo,
                              paymentMode: 'Razorpay Online',
                              grandTotal: orderRes.grandTotal ??
                                  (verifyRes?.bills.isNotEmpty == true
                                      ? verifyRes!.bills.first.netAmount
                                      : null) ??
                                  controller.cartGrandTotal,
                              hospitalName: orderRes.hospital?.name ??
                                  verifyRes?.hospital?.name ??
                                  orderRes.labName ??
                                  orderRes.storeName,
                              isCashOnDelivery: false,
                              cartItems: cartSnapshot,
                              customerName: _nameController.text.trim(),
                              customerPhone: _phoneController.text.trim(),
                              deliveryAddress: _addressController.text.trim(),
                              paymentId: simPayId,
                            ),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: pharmacyTeal,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: controller.isVerifyingPayment.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: colorWhite),
                    )
                  : const Text('PAY & VERIFY',
                      style: TextStyle(
                          color: colorWhite, fontWeight: FontWeight.bold)),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pharmacyTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout & Order',
          style: TextStyle(
            color: colorWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        final cartItems = controller.cart.values.toList();

        if (cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined,
                    size: 72, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Your cart is empty',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textDark),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add medicines from the catalog to place an order.',
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pharmacyTeal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('EXPLORE MEDICINES',
                      style: TextStyle(
                          color: colorWhite, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cart Items List
              _buildCartSection(cartItems),

              const SizedBox(height: 16),

              // Shipping Address Form
              _buildAddressSection(),

              const SizedBox(height: 16),

              // Payment Options
              _buildPaymentModeSection(),

              const SizedBox(height: 16),

              // Bill Summary
              _buildBillSummary(),

              const SizedBox(height: 90),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomCheckoutBar(),
    );
  }

  Widget _buildCartSection(List<CartItem> cartItems) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              TextButton(
                onPressed: () => controller.clearCart(),
                child: const Text(
                  'Clear Cart',
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (cartItems.isNotEmpty &&
              cartItems.first.medicine.hospital != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: pharmacyTealBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_hospital_rounded,
                      size: 16, color: pharmacyTeal),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Fulfilling Pharmacy: ${cartItems.first.medicine.hospital!.name ?? "Hospital"}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: pharmacyTeal),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ...cartItems.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderGrey),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: pharmacyTealBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.medication_rounded,
                        color: pharmacyTeal, size: 28),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.medicine.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '₹${item.itemPrice} x ${item.qty}',
                          style:
                              const TextStyle(fontSize: 11, color: textMuted),
                        ),
                      ],
                    ),
                  ),

                  // Qty controller
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26),
                        icon: const Icon(Icons.remove_circle_outline,
                            size: 20, color: pharmacyTeal),
                        onPressed: () => controller.updateQuantity(
                            item.cartKey, item.qty - 1),
                      ),
                      Text(
                        '${item.qty}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: textDark),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26),
                        icon: const Icon(Icons.add_circle_outline,
                            size: 20, color: pharmacyTeal),
                        onPressed: () => controller.updateQuantity(
                            item.cartKey, item.qty + 1),
                      ),
                    ],
                  ),

                  const SizedBox(width: 6),

                  Text(
                    '₹${item.totalItemPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: pharmacyTeal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Details',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Customer Full Name',
              hintText: 'Enter name',
              prefixIcon: const Icon(Icons.person_outline, color: pharmacyTeal),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Phone',
                    prefixIcon:
                        const Icon(Icons.phone_outlined, color: pharmacyTeal),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Email',
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: pharmacyTeal),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Shipping / Delivery Address',
              hintText: 'Enter full address',
              prefixIcon: const Icon(Icons.home_outlined, color: pharmacyTeal),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentModeSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Option',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 10),
          _buildPaymentOptionTile(
            title: 'Online Payment (Razorpay / UPI / Card)',
            subtitle: 'Instant confirmation & digital invoice',
            value: 'online',
          ),
          const SizedBox(height: 8),
          _buildPaymentOptionTile(
            title: 'Cash on Delivery / Pay at Pharmacy',
            subtitle: 'Pay when you receive medicines (Cash / COD)',
            value: 'cash',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptionTile({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _paymentMode == value;
    return InkWell(
      onTap: () => setState(() => _paymentMode = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? pharmacyTealBg : backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? pharmacyTeal : borderGrey,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? pharmacyTeal : colorGrey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? pharmacyTeal : textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bill Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Items Subtotal',
              '₹${controller.cartSubtotal.toStringAsFixed(2)}'),
          _buildSummaryRow(
              'Est. Tax / GST', '₹${controller.cartTax.toStringAsFixed(2)}'),
          _buildSummaryRow(
              'Delivery Fee',
              controller.cartDeliveryFee == 0
                  ? 'FREE'
                  : '₹${controller.cartDeliveryFee}'),
          const Divider(height: 20),
          _buildSummaryRow('Grand Total', '₹${controller.cartGrandTotal}',
              isBold: true, color: pharmacyTeal),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: textDark,
            ),
          ),
          Text(
            val,
            style: TextStyle(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar() {
    return Obx(() {
      if (controller.cartCount == 0) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Amount',
                        style: TextStyle(fontSize: 11, color: textMuted)),
                    Text(
                      '₹${controller.cartGrandTotal}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: pharmacyTeal,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: (controller.isPlacingOrder.value ||
                        controller.isVerifyingPayment.value)
                    ? null
                    : _submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pharmacyTeal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: (controller.isPlacingOrder.value ||
                        controller.isVerifyingPayment.value)
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: colorWhite),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              color: colorWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _paymentMode == 'online'
                                ? Icons.payment_rounded
                                : Icons.check_circle_outline_rounded,
                            color: colorWhite,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _paymentMode == 'online'
                                ? 'PAY VIA RAZORPAY'
                                : 'PLACE ORDER (COD)',
                            style: const TextStyle(
                              color: colorWhite,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
