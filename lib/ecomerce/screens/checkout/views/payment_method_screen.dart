import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../services/theme.dart';
import '../../../components/network_image_with_loader.dart';
import '../../../constants.dart' hide primaryColor;
import '../../../controllers/cart_controller.dart';
import '../../../controllers/address_controller.dart';
import '../../../controllers/store_controller.dart';
import '../../../services/address_service.dart';
import '../../../services/order_service.dart';
import 'thanks_for_order_screen.dart';

enum PaymentType { online, cod, netBanking }

class PaymentMethodScreen extends StatefulWidget {
  final String? storeDomain;
  final int? addressId;

  const PaymentMethodScreen({
    super.key,
    this.storeDomain,
    this.addressId,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final CartController _cart = CartController.instance;

  late final Razorpay _razorpay;

  PaymentType _selectedPaymentType = PaymentType.online;
  bool _isProcessing = false;
  bool _showItemsSummary = false;

  final TextEditingController _orderNoteController =
      TextEditingController(text: "Please deliver before 4 PM");
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _cardNumberController =
      TextEditingController(text: "4532 •••• •••• 8821");
  final TextEditingController _cardHolderController =
      TextEditingController(text: "ALEXANDER SMITH");
  final TextEditingController _cardExpiryController =
      TextEditingController(text: "08/28");
  final TextEditingController _cardCvvController =
      TextEditingController(text: "842");

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpayPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorpayExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _orderNoteController.dispose();
    _upiIdController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (_selectedPaymentType == PaymentType.cod) {
      // Cash on Delivery - directly call order place API
      _executeOrderPlacement(paymentMethod: "cash_on_delivery");
    } else if (_selectedPaymentType == PaymentType.online) {
      // Online Payment - initiate Razorpay checkout
      _startRazorpayPayment();
    }
  }

  void _startRazorpayPayment() {
    setState(() {
      _isProcessing = true;
    });

    final double amountToPay = _cart.grandTotal;
    final int amountInPaise = (amountToPay * 100).toInt();

    final addressCtrl = AddressController.instance;
    final selectedAddr = addressCtrl.selectedAddress ??
        (addressCtrl.addresses.isNotEmpty ? addressCtrl.addresses.first : null);
    final customer = addressCtrl.customer;

    final String contactName =
        selectedAddr?.name ?? customer?.name ?? "Customer";
    final String contactPhone =
        selectedAddr?.phone ?? customer?.phone ?? "9876543210";
    final String contactEmail = customer?.email ?? "customer@feetrack.com";

    final options = {
      'key': 'rzp_test_TWIAoYszpcVthe',
      'amount': amountInPaise > 0 ? amountInPaise : 100,
      'name': 'E-Commerce Store',
      'description': 'Order Payment',
      'prefill': {
        'name': contactName,
        'contact': contactPhone,
        'email': contactEmail,
      },
      'theme': {
        'color': '#7F00FF',
      },
    };

    try {
      debugPrint('[RAZORPAY] Opening checkout with options: $options');
      _razorpay.open(options);
    } catch (e) {
      debugPrint(
          '[RAZORPAY] Open exception (desktop / unsupported target): $e');
      _showRazorpayFallbackDialog();
    }
  }

  void _handleRazorpayPaymentSuccess(PaymentSuccessResponse response) {
    debugPrint(
        '[RAZORPAY] Payment Success: paymentId=${response.paymentId}, orderId=${response.orderId}');
    _executeOrderPlacement(paymentMethod: "razorpay");
  }

  void _handleRazorpayPaymentError(PaymentFailureResponse response) {
    debugPrint(
        '[RAZORPAY] Payment Error: code=${response.code}, message=${response.message}');
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Payment cancelled or failed: ${response.message ?? 'User cancelled'}",
                ),
              ),
            ],
          ),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    debugPrint('[RAZORPAY] External Wallet Selected: ${response.walletName}');
  }

  void _showRazorpayFallbackDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.payment_rounded, color: primaryColor),
            SizedBox(width: 8),
            Text(
              "Razorpay Gateway",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payable Amount: ₹${_cart.grandTotal.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              "Native Razorpay activity could not be launched on this platform. You can simulate test payment success:",
              style: TextStyle(fontSize: 12, color: greyColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (mounted) {
                setState(() {
                  _isProcessing = false;
                });
              }
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _executeOrderPlacement(paymentMethod: "razorpay");
            },
            child: const Text(
              "Simulate Success",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeOrderPlacement({required String paymentMethod}) async {
    setState(() {
      _isProcessing = true;
    });

    final StoreController? storeController = Get.isRegistered<StoreController>()
        ? Get.find<StoreController>()
        : null;
    final String? selectedStoreDomain =
        storeController?.selectedStore.value?.domain;
    int? effectiveShopId = storeController?.selectedStore.value?.shopId;

    String targetDomain = widget.storeDomain ?? "";
    if (targetDomain.isEmpty) {
      for (final item in _cart.items) {
        if (item.domain != null && item.domain!.isNotEmpty) {
          targetDomain = item.domain!;
          break;
        }
      }
    }
    if (targetDomain.isEmpty &&
        selectedStoreDomain != null &&
        selectedStoreDomain.isNotEmpty) {
      targetDomain = selectedStoreDomain;
    }
    if (targetDomain.isEmpty) {
      targetDomain = "e-team-12";
    }

    if (effectiveShopId == null) {
      for (final item in _cart.items) {
        if (item.product.shopId != null) {
          effectiveShopId = item.product.shopId;
          break;
        }
      }
    }

    final addressCtrl = AddressController.instance;
    int? effectiveAddressId = widget.addressId;

    // 1. Check if selected address is valid for targetDomain
    if (effectiveAddressId == null && addressCtrl.selectedAddress?.id != null) {
      if (addressCtrl.selectedAddress!.domain == null ||
          addressCtrl.selectedAddress!.domain == targetDomain) {
        effectiveAddressId = addressCtrl.selectedAddress!.id;
      }
    }

    // 2. Check loaded addresses for a match on targetDomain
    if (effectiveAddressId == null) {
      final match = addressCtrl.addresses.firstWhereOrNull(
        (a) => a.domain == targetDomain && a.id != null,
      );
      if (match != null) {
        effectiveAddressId = match.id;
      }
    }

    // 3. If not found, fetch addresses specifically for targetDomain
    if (effectiveAddressId == null) {
      await addressCtrl.fetchAddresses(domain: targetDomain);
      final match = addressCtrl.addresses.firstWhereOrNull(
        (a) => a.domain == targetDomain && a.id != null,
      );
      if (match != null) {
        effectiveAddressId = match.id;
      } else if (addressCtrl.selectedAddress?.id != null) {
        effectiveAddressId = addressCtrl.selectedAddress!.id;
      } else if (addressCtrl.addresses.isNotEmpty &&
          addressCtrl.addresses.first.id != null) {
        effectiveAddressId = addressCtrl.addresses.first.id;
      }
    }

    // 4. Auto-register fallback address if needed
    if (effectiveAddressId == null) {
      final existing = addressCtrl.selectedAddress ??
          (addressCtrl.addresses.isNotEmpty ? addressCtrl.addresses.first : null);
      if (existing != null) {
        try {
          final res = await AddressService().saveCustomerAddress(
            address: existing,
            domain: targetDomain,
          );
          if (res['status'] == true && res['data'] != null) {
            final rawId = res['data']['id'];
            effectiveAddressId = rawId is int ? rawId : int.tryParse('$rawId');
          }
        } catch (e) {
          debugPrint("[ORDER PLACEMENT] Address auto-save error: $e");
        }
      }
    }

    if (effectiveAddressId == null) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add or select a delivery address first."),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final String note = _orderNoteController.text.trim();
    final orderItems = _cart.getOrderItemsPayload(fallbackDomain: targetDomain);

    try {
      final response = await OrderService().placeOrder(
        domain: targetDomain,
        addressId: effectiveAddressId,
        paymentMethod: paymentMethod,
        orderNote: note.isNotEmpty ? note : "Please deliver before 4 PM",
        shopId: effectiveShopId,
        totalAmount: _cart.grandTotal,
        items: orderItems,
      );

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
      });

      final bool isSuccess = response['status'] == true ||
          (response['data'] is Map && response['data']['success'] == true);

      if (isSuccess) {
        // Clear cart once order is placed
        _cart.clearCart();

        // Navigate directly to ThanksForOrderScreen with response data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ThanksForOrderScreen(orderData: response),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(response['message'] ?? "Failed to place order."),
                ),
              ],
            ),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("[ORDER PLACEMENT] Exception: $e");
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error placing order: $e"),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildPaymentHeader({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(defaultBorderRadious),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? primaryColor : greyColor,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: greyColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? darkGreyColor : whiteColor;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF6F6F9);

    final items = _cart.items;
    final subtotal = _cart.subtotal;
    final deliveryFee = _cart.deliveryFee;
    final discountAmount = _cart.discountAmount;
    final appliedCoupon = _cart.appliedCoupon;
    final grandTotal = _cart.grandTotal;
    final savings = _cart.totalSavings;

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        backgroundColor: bodyBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Payment & Checkout",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Delivery Address Card
            _buildDeliveryAddressCard(cardBg, isDark),

            const SizedBox(height: defaultPadding),

            // 2. Order Items Collapsible Card
            _buildOrderItemsCard(cardBg, isDark, items),

            const SizedBox(height: defaultPadding),

            // 3. Payment Methods Section Title
            Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  color: primaryColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  "Choose Payment Method",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: successColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_rounded, size: 12, color: successColor),
                      SizedBox(width: 4),
                      Text(
                        "100% SECURE",
                        style: TextStyle(
                          color: successColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment Options - Online and Cash on Delivery
            _buildUpiPaymentOption(cardBg, isDark),
            const SizedBox(height: 10),
            _buildCodOption(cardBg, isDark),

            const SizedBox(height: 12),

            // Order Delivery Note Card
            _buildOrderNoteCard(cardBg, isDark),

            const SizedBox(height: defaultPadding * 1.2),

            // 8. Full Bill Details Breakdown ("sara bil dekha de")
            _buildDetailedBillCard(
              cardBg: cardBg,
              isDark: isDark,
              subtotal: subtotal,
              deliveryFee: deliveryFee,
              discountAmount: discountAmount,
              appliedCouponCode: appliedCoupon?.code,
              isFreeDeliveryCoupon: appliedCoupon?.isFreeDelivery ?? false,
              grandTotal: grandTotal,
              savings: savings,
            ),

            const SizedBox(height: defaultPadding * 2),
          ],
        ),
      ),

      // Bottom Sticky Pay Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding * 0.75,
        ),
        decoration: BoxDecoration(
          color: cardBg,
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
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total To Pay",
                    style: TextStyle(
                      fontSize: 10.5,
                      color: greyColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "₹${grandTotal.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: defaultPadding),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedPaymentType == PaymentType.cod
                                  ? Icons.local_shipping_rounded
                                  : Icons.lock_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedPaymentType == PaymentType.cod
                                  ? "CONFIRM ORDER (COD)"
                                  : "PAY VIA RAZORPAY (₹${grandTotal.toStringAsFixed(2)})",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderNoteCard(Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              const Icon(Icons.note_alt_outlined,
                  size: 18, color: primaryColor),
              const SizedBox(width: 8),
              const Text(
                "Order Delivery Note",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                "Optional",
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : greyColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _orderNoteController,
            decoration: InputDecoration(
              hintText: "e.g. Please deliver before 4 PM, ring bell twice",
              hintStyle: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryColor, width: 1.5),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF9F9FC),
            ),
            style: const TextStyle(fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard(Color cardBg, bool isDark) {
    return AnimatedBuilder(
      animation: AddressController.instance,
      builder: (context, _) {
        final selected = AddressController.instance.selectedAddress;
        final title = selected != null
            ? "${selected.addressType.toUpperCase()} (${selected.city != null && selected.city!.isNotEmpty ? selected.city : selected.name})"
            : "Home (New York, USA)";
        final subtitle = selected != null
            ? selected.formattedAddress
            : "⚡ Express 10-15 Mins Delivery";

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(defaultBorderRadious),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  "assets/icons/Location.svg",
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    primaryColor,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Deliver to: ",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : blackColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: selected != null
                            ? (isDark ? Colors.white70 : blackColor60)
                            : const Color(0xFF2962FF),
                        fontSize: 10,
                        fontWeight: selected != null
                            ? FontWeight.normal
                            : FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded,
                  color: successColor, size: 18),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItemsCard(
      Color cardBg, bool isDark, List<CartItemModel> items) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showItemsSummary = !_showItemsSummary;
              });
            },
            borderRadius: BorderRadius.circular(defaultBorderRadious),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: SvgPicture.asset(
                      "assets/icons/Bag.svg",
                      height: 16,
                      colorFilter: const ColorFilter.mode(
                        primaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Order Items (${_cart.totalItemCount})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _showItemsSummary ? "Hide" : "View Details",
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showItemsSummary
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: primaryColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_showItemsSummary) ...[
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 40,
                        height: 40,
                        color:
                            isDark ? Colors.white10 : const Color(0xFFF6F6F9),
                        child: NetworkImageWithLoader(
                          item.product.image,
                          radius: 6,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Qty: ${item.quantity} × ₹${item.unitPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? Colors.white54 : greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${item.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpiPaymentOption(Color cardBg, bool isDark) {
    final isSelected = _selectedPaymentType == PaymentType.online;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : (isDark ? Colors.white10 : const Color(0xFFE5E5EA)),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          _buildPaymentHeader(
            isSelected: isSelected,
            onTap: () {
              setState(() => _selectedPaymentType = PaymentType.online);
            },
            title: const Text(
              "Online Payment (UPI, Cards, Netbanking, Wallets)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
            subtitle: "Pay securely via Razorpay",
          ),
        ],
      ),
    );
  }

  Widget _buildCodOption(Color cardBg, bool isDark) {
    final isSelected = _selectedPaymentType == PaymentType.cod;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : (isDark ? Colors.white10 : const Color(0xFFE5E5EA)),
          width: isSelected ? 1.5 : 1.0,
        ),
      ),
      child: _buildPaymentHeader(
        isSelected: isSelected,
        onTap: () {
          setState(() => _selectedPaymentType = PaymentType.cod);
        },
        title: const Row(
          children: [
            Text(
              "Cash on Delivery (COD)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.handshake_outlined, color: primaryColor, size: 18),
          ],
        ),
        subtitle: "Pay cash at your doorstep",
      ),
    );
  }

  Widget _buildDetailedBillCard({
    required Color cardBg,
    required bool isDark,
    required double subtotal,
    required double deliveryFee,
    required double discountAmount,
    required String? appliedCouponCode,
    required bool isFreeDeliveryCoupon,
    required double grandTotal,
    required double savings,
  }) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bill Details Summary",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
              ),
              if (savings > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: successColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "You Save ₹${savings.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: successColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Subtotal
          _buildBillRow("Item Subtotal", "₹${subtotal.toStringAsFixed(2)}",
              isDark: isDark),
          const SizedBox(height: 8),

          // Delivery
          _buildBillRow(
            "Express Delivery Charge",
            deliveryFee == 0 ? "FREE" : "₹${deliveryFee.toStringAsFixed(2)}",
            isHighlight: deliveryFee == 0,
            isDark: isDark,
          ),

          // Coupon Discount if active
          if (appliedCouponCode != null && discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildBillRow(
              "Coupon Savings ($appliedCouponCode)",
              "-₹${discountAmount.toStringAsFixed(2)}",
              isDiscount: true,
              isDark: isDark,
            ),
          ],

          if (isFreeDeliveryCoupon) ...[
            const SizedBox(height: 8),
            _buildBillRow(
              "Free Delivery Coupon ($appliedCouponCode)",
              "WAIVED",
              isDiscount: true,
              isDark: isDark,
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "₹${grandTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isDiscount = false,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: (isHighlight || isDiscount)
                ? successColor
                : (isDark ? Colors.white : blackColor),
          ),
        ),
      ],
    );
  }
}
