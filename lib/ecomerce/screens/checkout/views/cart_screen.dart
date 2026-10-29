import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/address_controller.dart';
import '../../address/presentation/views/addresses_screen.dart';
import '../../coupon/views/coupon_screen.dart';
import '../widgets/widgets.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _cart = CartController.instance;
  final TextEditingController _couponController = TextEditingController();
  bool _isApplyingCoupon = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String targetDomain = _cart.items.isNotEmpty
          ? (_cart.items.first.domain ?? 'e-team-12')
          : 'e-team-12';
      AddressController.instance.fetchAddresses(domain: targetDomain);
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  String _formatPrice(num? value) {
    if (value == null) return "0.00";
    return value.toStringAsFixed(2);
  }

  void _navigateToCouponScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CouponScreen(),
      ),
    );
  }

  Future<void> _handleApplyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a coupon code"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isApplyingCoupon = true);
    final error = await _cart.applyCouponByCode(code);
    setState(() => _isApplyingCoupon = false);

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _couponController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Coupon '$code' applied successfully! 🎉"),
          backgroundColor: successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openAddressSelection() {
    final String targetDomain = _cart.items.isNotEmpty
        ? (_cart.items.first.domain ?? 'e-team-12')
        : 'e-team-12';
    AddressController.instance.fetchAddresses(domain: targetDomain);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressesScreen(
          selectAndReturn: true,
          storeDomain: targetDomain,
        ),
      ),
    );
  }

  void _confirmClearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        title: const Text(
          "Clear Cart?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          "Are you sure you want to remove all items from your cart?",
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              _cart.clearCart();
              Navigator.pop(context);
            },
            child: const Text(
              "Clear",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? darkGreyColor : whiteColor;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF6F6F9);

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        backgroundColor: bodyBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          tooltip: "Back",
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
        ),
        titleSpacing: 0,
        title: AnimatedBuilder(
          animation: _cart,
          builder: (context, _) {
            return Row(
              children: [
                Text(
                  "Shopping Cart",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                ),
                if (_cart.totalItemCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${_cart.totalItemCount} Items",
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          AnimatedBuilder(
            animation: _cart,
            builder: (context, _) {
              if (_cart.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: _confirmClearCart,
                child: const Text(
                  "Clear All",
                  style: TextStyle(
                    color: errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _cart,
        builder: (context, _) {
          final items = _cart.items;

          if (items.isEmpty) {
            return EmptyCartView(
              onStartShopping: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            );
          }

          final groupedStores = _cart.itemsGroupedByStore;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🏪 1. Store-wise grouped products cards
                      for (final entry in groupedStores.entries) ...[
                        StoreGroupCard(
                          storeName: entry.key,
                          items: entry.value,
                          cart: _cart,
                          cardBg: cardBg,
                          isDark: isDark,
                          formatPrice: _formatPrice,
                        ),
                        const SizedBox(height: 14),
                      ],

                      const SizedBox(height: 8),

                      // 🧾 2. Order summary & Coupon card
                      CartOrderSummaryCard(
                        cart: _cart,
                        couponController: _couponController,
                        isApplyingCoupon: _isApplyingCoupon,
                        onApplyCoupon: _handleApplyCoupon,
                        onViewCoupons: _navigateToCouponScreen,
                        cardBg: cardBg,
                        isDark: isDark,
                        formatPrice: _formatPrice,
                      ),
                    ],
                  ),
                ),
              ),

              // 💳 3. Bottom checkout bar
              BottomCheckoutBar(
                totalAmount: _cart.grandTotal,
                onCheckout: _openAddressSelection,
                cardBg: cardBg,
                formatPrice: _formatPrice,
              ),
            ],
          );
        },
      ),
    );
  }
}
